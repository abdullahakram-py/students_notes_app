import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/diagram_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/diagram_provider.dart';
import 'diagram_painter.dart';
import 'widgets/diagram_toolbar.dart';

class DiagramCanvasScreen extends ConsumerStatefulWidget {
  final String? initialDiagramJson;
  final Function(String diagramJson, String diagramImagePath) onSave;

  const DiagramCanvasScreen({
    super.key,
    this.initialDiagramJson,
    required this.onSave,
  });

  @override
  ConsumerState<DiagramCanvasScreen> createState() => _DiagramCanvasScreenState();
}

class _DiagramCanvasScreenState extends ConsumerState<DiagramCanvasScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final Uuid _uuid = const Uuid();
  List<OffsetPoint> _activePoints = [];
  DiagramElement? _activeDragElement;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialDiagramJson != null) {
        ref.read(diagramProvider.notifier).loadFromJson(widget.initialDiagramJson);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    final state = ref.read(diagramProvider);
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    if (state.selectedTool == DiagramToolType.text) {
      _promptTextLabel(localPos);
      return;
    }

    _activePoints = [OffsetPoint.fromOffset(localPos)];
    _activeDragElement = DiagramElement(
      id: _uuid.v4(),
      toolType: state.selectedTool,
      points: List.from(_activePoints),
      colorValue: state.selectedColor.toARGB32(),
      strokeWidth: state.strokeWidth,
      isFilled: state.isFilled,
    );
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeDragElement == null) return;
    final state = ref.read(diagramProvider);
    final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final localPos = renderBox.globalToLocal(details.globalPosition);

    if (state.selectedTool == DiagramToolType.pen) {
      _activePoints.add(OffsetPoint.fromOffset(localPos));
      _activeDragElement = _activeDragElement!.copyWith(
        points: List.from(_activePoints),
      );
    } else {
      // Shapes: p1 is start, p2 is current
      _activeDragElement = _activeDragElement!.copyWith(
        points: [_activePoints.first, OffsetPoint.fromOffset(localPos)],
      );
    }
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeDragElement != null) {
      ref.read(diagramProvider.notifier).addElement(_activeDragElement!);
      _activeDragElement = null;
      _activePoints = [];
      setState(() {});
    }
  }

  void _promptTextLabel(Offset position) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Diagram Label'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter label text...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                ref.read(diagramProvider.notifier).addTextLabel(text, position);
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAndSave() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final imagePath = await FileService().saveDiagramImage(pngBytes);
      final json = ref.read(diagramProvider).toJson();

      widget.onSave(json, imagePath);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save diagram: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagramState = ref.watch(diagramProvider);
    final notifier = ref.read(diagramProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagram & Sketch Canvas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
            onPressed: diagramState.canUndo ? notifier.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Redo',
            onPressed: diagramState.canRedo ? notifier.redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Canvas',
            onPressed: diagramState.elements.isNotEmpty ? notifier.clearCanvas : null,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _exportAndSave,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightTextPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Drawing Canvas Area
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: isDark ? const Color(0xFF181818) : Colors.white,
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: CustomPaint(
                    painter: DiagramPainter(
                      elements: diagramState.elements,
                      currentElement: _activeDragElement,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Toolbar
          const DiagramToolbar(),
        ],
      ),
    );
  }
}
