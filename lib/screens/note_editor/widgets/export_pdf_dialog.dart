import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/services/pdf_export_service.dart';

class ExportPdfDialog extends StatefulWidget {
  final Note note;
  final Subject subject;

  const ExportPdfDialog({
    super.key,
    required this.note,
    required this.subject,
  });

  static Future<void> show(
    BuildContext context, {
    required Note note,
    required Subject subject,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ExportPdfDialog(note: note, subject: subject),
    );
  }

  @override
  State<ExportPdfDialog> createState() => _ExportPdfDialogState();
}

class _ExportPdfDialogState extends State<ExportPdfDialog> {
  PdfExportMode _selectedMode = PdfExportMode.computerized;
  bool _isExporting = false;

  Future<void> _handlePreview() async {
    setState(() => _isExporting = true);
    try {
      await PdfExportService().previewOrPrintPdf(
        note: widget.note,
        subject: widget.subject,
        mode: _selectedMode,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _handleShare() async {
    setState(() => _isExporting = true);
    try {
      await PdfExportService().shareNotePdf(
        note: widget.note,
        subject: widget.subject,
        mode: _selectedMode,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final hasDiagram = widget.note.diagramImagePath != null;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Export to PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select PDF document layout style:',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Option 1: Computerized
            _buildModeCard(
              mode: PdfExportMode.computerized,
              title: 'Computerized Format (Recommended)',
              subtitle: 'Renders typed rich-text content as crisp, selectable, printable text with subject headers.',
              icon: Icons.text_snippet_outlined,
              isDark: isDark,
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 12),

            // Option 2: Handwritten / Diagram
            _buildModeCard(
              mode: PdfExportMode.handwritten,
              title: 'Handwritten / Canvas Format',
              subtitle: hasDiagram
                  ? 'Captures and embeds your full-resolution geometric canvas and diagram drawings.'
                  : 'No diagram sketch attached to this note yet.',
              icon: Icons.gesture_rounded,
              isDark: isDark,
              primaryColor: primaryColor,
              disabled: !hasDiagram,
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _isExporting ? null : _handleShare,
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _handlePreview,
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_rounded, size: 18),
          label: const Text('Preview / Print'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: isDark ? AppColors.darkBackground : AppColors.lightTextPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required PdfExportMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    bool disabled = false,
  }) {
    final isSelected = _selectedMode == mode;

    return InkWell(
      onTap: disabled ? null : () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkSecondary : AppColors.lightSecondary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? primaryColor : (isDark ? Colors.white38 : Colors.black38),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
