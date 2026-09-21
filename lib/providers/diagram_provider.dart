import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_colors.dart';
import '../data/models/diagram_model.dart';

class DiagramState {
  final List<DiagramElement> elements;
  final List<List<DiagramElement>> undoStack;
  final List<List<DiagramElement>> redoStack;
  final DiagramToolType selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final bool isFilled;

  const DiagramState({
    this.elements = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.selectedTool = DiagramToolType.pen,
    this.selectedColor = AppColors.lightTextPrimary,
    this.strokeWidth = 3.0,
    this.isFilled = false,
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;

  DiagramState copyWith({
    List<DiagramElement>? elements,
    List<List<DiagramElement>>? undoStack,
    List<List<DiagramElement>>? redoStack,
    DiagramToolType? selectedTool,
    Color? selectedColor,
    double? strokeWidth,
    bool? isFilled,
  }) {
    return DiagramState(
      elements: elements ?? this.elements,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isFilled: isFilled ?? this.isFilled,
    );
  }

  String toJson() {
    return jsonEncode(elements.map((e) => e.toMap()).toList());
  }
}

final diagramProvider = StateNotifierProvider.autoDispose<DiagramNotifier, DiagramState>((ref) {
  return DiagramNotifier();
});

class DiagramNotifier extends StateNotifier<DiagramState> {
  final Uuid _uuid = const Uuid();

  DiagramNotifier() : super(const DiagramState());

  void loadFromJson(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final list = decoded
          .map((item) => DiagramElement.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
      state = state.copyWith(
        elements: list,
        undoStack: [],
        redoStack: [],
      );
    } catch (_) {
      // Ignored if invalid json
    }
  }

  void setTool(DiagramToolType tool) {
    state = state.copyWith(selectedTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void toggleFill() {
    state = state.copyWith(isFilled: !state.isFilled);
  }

  void addElement(DiagramElement element) {
    final newUndo = [...state.undoStack, state.elements];
    state = state.copyWith(
      elements: [...state.elements, element],
      undoStack: newUndo,
      redoStack: [], // clear redo on new action
    );
  }

  void addTextLabel(String text, Offset position) {
    final element = DiagramElement(
      id: _uuid.v4(),
      toolType: DiagramToolType.text,
      points: [OffsetPoint.fromOffset(position)],
      text: text,
      colorValue: state.selectedColor.toARGB32(),
      strokeWidth: state.strokeWidth,
    );
    addElement(element);
  }

  void undo() {
    if (!state.canUndo) return;
    final previousState = state.undoStack.last;
    final newUndo = state.undoStack.sublist(0, state.undoStack.length - 1);
    final newRedo = [...state.redoStack, state.elements];

    state = state.copyWith(
      elements: previousState,
      undoStack: newUndo,
      redoStack: newRedo,
    );
  }

  void redo() {
    if (!state.canRedo) return;
    final nextState = state.redoStack.last;
    final newRedo = state.redoStack.sublist(0, state.redoStack.length - 1);
    final newUndo = [...state.undoStack, state.elements];

    state = state.copyWith(
      elements: nextState,
      undoStack: newUndo,
      redoStack: newRedo,
    );
  }

  void clearCanvas() {
    if (state.elements.isEmpty) return;
    final newUndo = [...state.undoStack, state.elements];
    state = state.copyWith(
      elements: [],
      undoStack: newUndo,
      redoStack: [],
    );
  }
}
