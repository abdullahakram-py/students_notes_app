import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/attachment_model.dart';
import '../data/models/note_model.dart';
import '../data/models/subject_model.dart';
import '../providers/note_provider.dart';
import '../providers/subject_provider.dart';

class NoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectsState = ref.watch(subjectsProvider);

    final subject = subjectsState.maybeWhen(
      data: (subjects) => subjects.firstWhere(
        (s) => s.id == note.subjectId,
        orElse: () => Subject.uncategorized,
      ),
      orElse: () => Subject.uncategorized,
    );

    final imageAttachments = note.attachments.where((a) => a.fileType == AttachmentType.image).length;
    final pdfAttachments = note.attachments.where((a) => a.fileType == AttachmentType.pdf).length;
    final hasDiagram = note.diagramImagePath != null || (note.diagramJson != null && note.diagramJson!.isNotEmpty);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Subject Tag + Bookmark Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Subject Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: subject.color.withValues(alpha: isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: subject.color.withValues(alpha: isDark ? 0.5 : 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(subject.icon, size: 12, color: subject.color),
                        const SizedBox(width: 4),
                        Text(
                          subject.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Star / Bookmark Button
                  IconButton(
                    icon: Icon(
                      note.isBookmarked ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: note.isBookmarked ? AppColors.starActive : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      size: 24,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref.read(notesProvider.notifier).toggleBookmark(note.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                note.title.isNotEmpty ? note.title : 'Untitled Note',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
              ),
              const SizedBox(height: 6),

              // Snippet Preview
              if (note.plainText.trim().isNotEmpty) ...[
                Text(
                  note.plainText.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 6),

              // Bottom Row: Metadata (Date + Attachments indicators)
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatNoteDate(note.updatedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  const Spacer(),

                  // Attachment Badges
                  if (imageAttachments > 0) ...[
                    _buildBadge(
                      icon: Icons.image_rounded,
                      label: '$imageAttachments',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (pdfAttachments > 0) ...[
                    _buildBadge(
                      icon: Icons.picture_as_pdf_rounded,
                      label: '$pdfAttachments',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (hasDiagram) ...[
                    _buildBadge(
                      icon: Icons.draw_rounded,
                      label: 'Diagram',
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimaryDark),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
