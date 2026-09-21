import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attachment_model.dart';

class PdfViewerScreen extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onDelete;

  const PdfViewerScreen({
    super.key,
    required this.attachment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(attachment.filePath);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          attachment.fileName,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Delete PDF',
              onPressed: () {
                Navigator.pop(context);
                onDelete!();
              },
            ),
        ],
      ),
      body: file.existsSync()
          ? PdfPreview(
              build: (format) => file.readAsBytesSync(),
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              dynamicLayout: false,
              maxPageWidth: 700,
              pdfFileName: attachment.fileName,
              loadingWidget: const Center(
                child: CircularProgressIndicator(),
              ),
              onError: (context, error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error previewing PDF: $error',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('PDF file not found on device storage.'),
            ),
    );
  }
}
