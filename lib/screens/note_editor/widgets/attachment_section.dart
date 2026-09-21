import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/file_utils.dart';
import '../../../data/models/attachment_model.dart';
import '../../viewers/image_viewer_screen.dart';
import '../../viewers/pdf_viewer_screen.dart';

class AttachmentSection extends StatelessWidget {
  final List<Attachment> attachments;
  final VoidCallback onAddImageCamera;
  final VoidCallback onAddImageGallery;
  final VoidCallback onAddPdf;
  final Function(Attachment attachment) onDeleteAttachment;

  const AttachmentSection({
    super.key,
    required this.attachments,
    required this.onAddImageCamera,
    required this.onAddImageGallery,
    required this.onAddPdf,
    required this.onDeleteAttachment,
  });

  void _showAttachOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Attach Study Materials (Max 20MB)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimaryDark),
                  ),
                  title: const Text('Capture Photo (Whiteboard / Paper)'),
                  onTap: () {
                    Navigator.pop(context);
                    onAddImageCamera();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                  ),
                  title: const Text('Upload Image from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    onAddImageGallery();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                  ),
                  title: const Text('Attach PDF Document / Slides'),
                  onTap: () {
                    Navigator.pop(context);
                    onAddPdf();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  size: 18,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Attachments (${attachments.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAttachOptions(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add File'),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Attachments Carousel / List
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: () => _showAttachOptions(context),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 20,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to attach whiteboard photos or PDF notes',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 95,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final att = attachments[index];
                final isImage = att.fileType == AttachmentType.image;

                return GestureDetector(
                  onTap: () {
                    if (isImage) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageViewerScreen(
                            attachment: att,
                            onDelete: () => onDeleteAttachment(att),
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(
                            attachment: att,
                            onDelete: () => onDeleteAttachment(att),
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: (isImage ? Colors.blue : Colors.red).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isImage ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                                    size: 18,
                                    color: isImage ? Colors.blue : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              att.fileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              FileUtils.formatBytes(att.fileSizeBytes),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                        // Delete Mini Button
                        Positioned(
                          top: -6,
                          right: -6,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 16),
                            onPressed: () => onDeleteAttachment(att),
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
