import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/subject_model.dart';
import '../../providers/note_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/note_card.dart';
import '../note_editor/note_editor_screen.dart';
import '../search/search_screen.dart';
import '../subject_detail/subject_detail_screen.dart';
import 'widgets/add_subject_dialog.dart';
import 'widgets/subject_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Subject subject) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Subject'),
          content: Text(
            'What would you like to do with notes associated with "${subject.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(subjectsProvider.notifier).deleteSubject(
                      subject.id,
                      SubjectDeleteStrategy.moveToUncategorized,
                    );
              },
              child: const Text('Move to Uncategorized'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(subjectsProvider.notifier).deleteSubject(
                      subject.id,
                      SubjectDeleteStrategy.deleteAllNotes,
                    );
              },
              child: const Text('Delete All Notes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final subjectsState = ref.watch(subjectsProvider);
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(subjectsProvider.notifier).loadSubjects();
            await ref.read(notesProvider.notifier).loadNotes();
          },
          child: CustomScrollView(
            slivers: [
              // Top App Bar / Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Day, Student 👋',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Theme Toggle Icon Button
                      IconButton(
                        icon: Icon(
                          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimaryDark,
                        ),
                        tooltip: 'Toggle Theme',
                        onPressed: () {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Search Trigger Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
                    },
                    child: const AbsorbPointer(
                      child: CustomSearchBar(readOnly: true),
                    ),
                  ),
                ),
              ),

              // Subjects Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.subjectsTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          AddSubjectDialog.show(
                            context,
                            onSave: (name, colorValue, iconCodePoint) {
                              ref.read(subjectsProvider.notifier).addSubject(
                                    name: name,
                                    colorValue: colorValue,
                                    iconCodePoint: iconCodePoint,
                                  );
                            },
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Subject'),
                        style: TextButton.styleFrom(foregroundColor: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),

              // Subjects List / Carousel
              SliverToBoxAdapter(
                child: subjectsState.when(
                  loading: () => const SizedBox(
                    height: 136,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Center(child: Text('Error: $err')),
                  data: (subjects) {
                    if (subjects.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Text(
                          AppStrings.noSubjectsYet,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }

                    // Soft warning if >50 subjects as recommended in PRD 3.1
                    final showWarning = subjects.length > AppConstants.subjectWarningThreshold;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showWarning)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            child: Text(
                              'Tip: You have >50 subjects. Consider organizing into key courses.',
                              style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                            ),
                          ),
                        SizedBox(
                          height: 136,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: subjects.length + 1,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              if (index == subjects.length) {
                                // Add Subject Card CTA
                                return InkWell(
                                  onTap: () {
                                    AddSubjectDialog.show(
                                      context,
                                      onSave: (name, colorValue, iconCodePoint) {
                                        ref.read(subjectsProvider.notifier).addSubject(
                                              name: name,
                                              colorValue: colorValue,
                                              iconCodePoint: iconCodePoint,
                                            );
                                      },
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 28,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'New Subject',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final subject = subjects[index];
                              final isUncategorized = subject.id == AppConstants.uncategorizedSubjectId;

                              return SubjectCard(
                                subject: subject,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SubjectDetailScreen(subject: subject),
                                    ),
                                  );
                                },
                                onEdit: isUncategorized
                                    ? null
                                    : () {
                                        AddSubjectDialog.show(
                                          context,
                                          initialSubject: subject,
                                          onSave: (name, colorValue, iconCodePoint) {
                                            final updated = subject.copyWith(
                                              name: name,
                                              colorValue: colorValue,
                                              iconCodePoint: iconCodePoint,
                                            );
                                            ref.read(subjectsProvider.notifier).updateSubject(updated);
                                          },
                                        );
                                      },
                                onDelete: isUncategorized
                                    ? null
                                    : () => _showDeleteConfirmation(context, ref, subject),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Recent Notes Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.recentNotesTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final notesCount = ref.watch(notesProvider).valueOrNull?.length ?? 0;
                          return Text(
                            '$notesCount notes',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Notes Sliver List
              notesState.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Error: $err')),
                ),
                data: (notes) {
                  if (notes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.note_alt_outlined,
                        title: 'No study notes yet',
                        subtitle: 'Start creating organized lecture notes and diagrams for your courses.',
                        actionText: 'Create First Note',
                        onAction: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
                          );
                        },
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = notes[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NoteCard(
                              note: note,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NoteEditorScreen(note: note),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: notes.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Note', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}
