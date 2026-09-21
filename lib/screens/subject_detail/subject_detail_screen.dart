import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/subject_model.dart';
import '../../providers/note_provider.dart';
import '../../providers/subject_provider.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/note_card.dart';
import '../home/widgets/add_subject_dialog.dart';
import '../note_editor/note_editor_screen.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final Subject subject;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
  });

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteSubjectConfirmation(Subject currentSubject) {
    final rootNav = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Subject'),
          content: Text(
            'What would you like to do with notes associated with "${currentSubject.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ref.read(subjectsProvider.notifier).deleteSubject(
                      currentSubject.id,
                      SubjectDeleteStrategy.moveToUncategorized,
                    );
                if (mounted) rootNav.pop();
              },
              child: const Text('Move to Uncategorized'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                await ref.read(subjectsProvider.notifier).deleteSubject(
                      currentSubject.id,
                      SubjectDeleteStrategy.deleteAllNotes,
                    );
                if (mounted) rootNav.pop();
              },
              child: const Text('Delete All Notes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectsState = ref.watch(subjectsProvider);

    // Watch latest subject instance if updated
    final currentSubject = subjectsState.maybeWhen(
      data: (list) => list.firstWhere(
        (s) => s.id == widget.subject.id,
        orElse: () => widget.subject,
      ),
      orElse: () => widget.subject,
    );

    final notesState = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentSubject.name),
        actions: [
          if (currentSubject.id != AppConstants.uncategorizedSubjectId) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Subject',
              onPressed: () {
                AddSubjectDialog.show(
                  context,
                  initialSubject: currentSubject,
                  onSave: (name, colorValue, iconCodePoint) {
                    final updated = currentSubject.copyWith(
                      name: name,
                      colorValue: colorValue,
                      iconCodePoint: iconCodePoint,
                    );
                    ref.read(subjectsProvider.notifier).updateSubject(updated);
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              tooltip: 'Delete Subject',
              onPressed: () => _showDeleteSubjectConfirmation(currentSubject),
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Banner with subject color and icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentSubject.color.withValues(alpha: isDark ? 0.25 : 0.18),
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: currentSubject.color.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(currentSubject.icon, color: currentSubject.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSubject.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, _) {
                          final count = ref.watch(subjectNoteCountProvider(currentSubject.id));
                          return Text(
                            '$count ${count == 1 ? 'study note' : 'study notes'} recorded',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // In-subject search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search within ${currentSubject.name}...',
              onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
          ),

          // Notes List
          Expanded(
            child: notesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading notes: $err')),
              data: (allNotes) {
                final subjectNotes = allNotes.where((n) {
                  if (n.subjectId != currentSubject.id) return false;
                  if (_query.isEmpty) return true;
                  return n.title.toLowerCase().contains(_query) ||
                      n.plainText.toLowerCase().contains(_query);
                }).toList();

                if (subjectNotes.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.note_add_rounded,
                    title: _query.isEmpty ? AppStrings.noNotesYet : AppStrings.noSearchResults,
                    subtitle: _query.isEmpty
                        ? 'Tap the + button to add lecture notes for ${currentSubject.name}.'
                        : AppStrings.noSearchResultsSubtitle,
                    actionText: _query.isEmpty ? 'Add First Note' : null,
                    onAction: _query.isEmpty
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorScreen(
                                  preselectedSubjectId: currentSubject.id,
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: subjectNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = subjectNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(note: note),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteEditorScreen(preselectedSubjectId: currentSubject.id),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Note', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
