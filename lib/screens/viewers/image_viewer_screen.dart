import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/attachment_model.dart';

class ImageViewerScreen extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback? onDelete;

  const ImageViewerScreen({
    super.key,
    required this.attachment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(attachment.filePath);
    final exists = file.existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        title: Text(
          attachment.fileName,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        actions: [
          if (exists)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Image',
              onPressed: () {
                Share.shareXFiles([XFile(attachment.filePath)], text: attachment.fileName);
              },
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Delete Image',
              onPressed: () {
                Navigator.pop(context);
                onDelete!();
              },
            ),
        ],
      ),
      body: Center(
        child: exists
            ? InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Failed to load image file',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            : const Text(
                'Image file not found on device.',
                style: TextStyle(color: Colors.white70),
              ),
      ),
    );
  }
}
