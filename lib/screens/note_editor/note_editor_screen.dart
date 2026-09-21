import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/debouncer.dart';
import '../../data/models/attachment_model.dart';
import '../../data/models/note_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/services/file_service.dart';
import '../../providers/note_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/confirmation_dialog.dart';
import '../diagram/diagram_canvas_screen.dart';
import 'widgets/attachment_section.dart';
import 'widgets/export_pdf_dialog.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final String? preselectedSubjectId;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.preselectedSubjectId,
  });

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late String _noteId;
  late TextEditingController _titleController;
  late quill.QuillController _quillController;
  late String _subjectId;
  late bool _isBookmarked;
  late List<Attachment> _attachments;
  String? _diagramJson;
  String? _diagramImagePath;
  late DateTime _createdAt;

  final Debouncer _autoSaveDebouncer = Debouncer(milliseconds: AppConstants.autoSaveDebounceMs);
  bool _isSaving = false;
  bool _isNewNote = false;

  @override
  void initState() {
    super.initState();
    _isNewNote = widget.note == null;
    _noteId = widget.note?.id ?? const Uuid().v4();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _subjectId = widget.note?.subjectId ?? widget.preselectedSubjectId ?? AppConstants.uncategorizedSubjectId;
    _isBookmarked = widget.note?.isBookmarked ?? false;
    _attachments = widget.note?.attachments != null ? List.from(widget.note!.attachments) : [];
    _diagramJson = widget.note?.diagramJson;
    _diagramImagePath = widget.note?.diagramImagePath;
    _createdAt = widget.note?.createdAt ?? DateTime.now();

    // Initialize Quill Controller
    _initQuill();

    // Listeners for Auto-save
    _titleController.addListener(_onContentChanged);
    _quillController.document.changes.listen((_) => _onContentChanged());
  }

  void _initQuill() {
    if (widget.note != null && widget.note!.contentJson.isNotEmpty) {
      try {
        final docJson = jsonDecode(widget.note!.contentJson);
        final doc = quill.Document.fromJson(docJson);
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
        return;
      } catch (_) {}
    }
    _quillController = quill.QuillController.basic();
  }

  void _onContentChanged() {
    if (!mounted) return;
    setState(() => _isSaving = true);
    _autoSaveDebouncer.run(() {
      _saveNote(showFeedback: false);
    });
  }

  Future<void> _saveNote({bool showFeedback = true}) async {
    final title = _titleController.text.trim();
    final plainText = _quillController.document.toPlainText().trim();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    // Skip saving empty brand new notes if unmodified
    if (_isNewNote && title.isEmpty && plainText.isEmpty && _attachments.isEmpty && _diagramJson == null) {
      if (mounted) setState(() => _isSaving = false);
      return;
    }

    final noteToSave = Note(
      id: _noteId,
      title: title.isNotEmpty ? title : 'Untitled Note',
      contentJson: contentJson,
      plainText: plainText,
      subjectId: _subjectId,
      isBookmarked: _isBookmarked,
      attachments: _attachments,
      diagramJson: _diagramJson,
      diagramImagePath: _diagramImagePath,
      createdAt: _createdAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(notesProvider.notifier).saveOrUpdateNote(noteToSave);
    _isNewNote = false;

    if (mounted) {
      setState(() => _isSaving = false);
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully!'),
            duration: Duration(milliseconds: 1000),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoSaveDebouncer.cancel();
    _saveNote(showFeedback: false);
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  // --- Attachment Actions ---
  Future<void> _addPhotoCamera() async {
    try {
      final att = await FileService().capturePhoto();
      if (att != null) {
        setState(() => _attachments.add(att));
        _onContentChanged();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _addImageGallery() async {
    try {
      final att = await FileService().pickImage();
      if (att != null) {
        setState(() => _attachments.add(att));
        _onContentChanged();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _addPdf() async {
    try {
      final att = await FileService().pickPdf();
      if (att != null) {
        setState(() => _attachments.add(att));
        _onContentChanged();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteAttachment(Attachment att) async {
    setState(() => _attachments.removeWhere((a) => a.id == att.id));
    await FileService().deleteFile(att.filePath);
    _onContentChanged();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final subjectsState = ref.watch(subjectsProvider);
    final subjects = subjectsState.valueOrNull ?? [Subject.uncategorized];

    final currentSubject = subjects.firstWhere(
      (s) => s.id == _subjectId,
      orElse: () => subjects.isNotEmpty ? subjects.first : Subject.uncategorized,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            // Subject Dropdown Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: currentSubject.color.withValues(alpha: isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: currentSubject.color.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: subjects.any((s) => s.id == _subjectId) ? _subjectId : subjects.first.id,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: currentSubject.color),
                  isDense: true,
                  borderRadius: BorderRadius.circular(16),
                  dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                  items: subjects.map((sub) {
                    return DropdownMenuItem<String>(
                      value: sub.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(sub.icon, size: 14, color: sub.color),
                          const SizedBox(width: 6),
                          Text(
                            sub.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _subjectId = val);
                      _onContentChanged();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Auto-save indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.cloud_done_rounded, size: 18, color: Colors.green.shade400),
            ),
          ),

          // Bookmark Toggle
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isBookmarked ? AppColors.starActive : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            ),
            tooltip: _isBookmarked ? 'Bookmarked' : 'Bookmark Note',
            onPressed: () {
              setState(() => _isBookmarked = !_isBookmarked);
              _onContentChanged();
            },
          ),

          // Action Menu (Export, Delete)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'export') {
                final currentNote = Note(
                  id: _noteId,
                  title: _titleController.text.trim(),
                  contentJson: jsonEncode(_quillController.document.toDelta().toJson()),
                  plainText: _quillController.document.toPlainText().trim(),
                  subjectId: _subjectId,
                  isBookmarked: _isBookmarked,
                  attachments: _attachments,
                  diagramJson: _diagramJson,
                  diagramImagePath: _diagramImagePath,
                  createdAt: _createdAt,
                  updatedAt: DateTime.now(),
                );
                ExportPdfDialog.show(context, note: currentNote, subject: currentSubject);
              } else if (val == 'delete') {
                final nav = Navigator.of(context);
                ConfirmationDialog.show(
                  context,
                  title: 'Delete Note',
                  message: 'Are you sure you want to delete this study note?',
                  confirmText: 'Delete',
                  isDestructive: true,
                  onConfirm: () async {
                    await ref.read(notesProvider.notifier).deleteNote(_noteId);
                    if (mounted) nav.pop();
                  },
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
              if (!_isNewNote)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Note', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quill Simple Toolbar
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: quill.QuillSimpleToolbar(
                controller: _quillController,
                config: quill.QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showAlignmentButtons: false,
                  showHeaderStyle: true,
                  showListBullets: true,
                  showListNumbers: true,
                  showListCheck: true,
                  showCodeBlock: true,
                  showQuote: true,
                  showLink: false,
                  showUndo: true,
                  showRedo: true,
                  buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                    base: quill.QuillToolbarBaseButtonOptions(
                      iconTheme: quill.QuillIconTheme(
                        iconButtonSelectedData: quill.IconButtonData(
                          style: IconButton.styleFrom(
                            backgroundColor: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Main Note Content Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Title Input
                TextField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                  decoration: InputDecoration(
                    hintText: 'Note Title...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 12),

                // Quill Rich Text Editor
                quill.QuillEditor.basic(
                  controller: _quillController,
                  config: quill.QuillEditorConfig(
                    placeholder: 'Type your lecture notes, formulas, revision points here...',
                    scrollable: false,
                    autoFocus: false,
                    expands: false,
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 24),

                // Diagram & Canvas Section
                _buildDiagramSection(isDark, primaryColor),
                const SizedBox(height: 24),

                // Multimedia Attachments Section
                AttachmentSection(
                  attachments: _attachments,
                  onAddImageCamera: _addPhotoCamera,
                  onAddImageGallery: _addImageGallery,
                  onAddPdf: _addPdf,
                  onDeleteAttachment: _deleteAttachment,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramSection(bool isDark, Color primaryColor) {
    final hasDiagram = _diagramImagePath != null && File(_diagramImagePath!).existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.draw_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Diagram & Geometry Sketch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagramCanvasScreen(
                      initialDiagramJson: _diagramJson,
                      onSave: (json, imagePath) {
                        setState(() {
                          _diagramJson = json;
                          _diagramImagePath = imagePath;
                        });
                        _onContentChanged();
                      },
                    ),
                  ),
                );
              },
              icon: Icon(hasDiagram ? Icons.edit_rounded : Icons.add_rounded, size: 16),
              label: Text(hasDiagram ? 'Edit Sketch' : 'Open Canvas'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (hasDiagram)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiagramCanvasScreen(
                    initialDiagramJson: _diagramJson,
                    onSave: (json, imagePath) {
                      setState(() {
                        _diagramJson = json;
                        _diagramImagePath = imagePath;
                      });
                      _onContentChanged();
                    },
                  ),
                ),
              );
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_diagramImagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiagramCanvasScreen(
                      initialDiagramJson: _diagramJson,
                      onSave: (json, imagePath) {
                        setState(() {
                          _diagramJson = json;
                          _diagramImagePath = imagePath;
                        });
                        _onContentChanged();
                      },
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gesture_rounded,
                    size: 20,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to draw geometric shapes, arrows & flowcharts',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
