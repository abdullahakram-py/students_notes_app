import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/note_provider.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/note_card.dart';
import '../note_editor/note_editor_screen.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkedNotes = ref.watch(bookmarkedNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookmarksTitle),
      ),
      body: bookmarkedNotes.isEmpty
          ? EmptyStateView(
              icon: Icons.star_outline_rounded,
              title: AppStrings.noBookmarksYet,
              subtitle: AppStrings.noBookmarksSubtitle,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedNotes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = bookmarkedNotes[index];
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
            ),
    );
  }
}
