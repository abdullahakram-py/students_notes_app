import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/attachment_model.dart';
import '../data/models/note_model.dart';
import '../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider<INoteRepository>((ref) {
  return NoteRepository();
});

final notesProvider = StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
  final noteRepo = ref.watch(noteRepositoryProvider);
  return NotesNotifier(noteRepo);
});

/// Computes notes count for a given subjectId
final subjectNoteCountProvider = Provider.family<int, String>((ref, subjectId) {
  final notesState = ref.watch(notesProvider);
  return notesState.maybeWhen(
    data: (notes) => notes.where((n) => n.subjectId == subjectId).length,
    orElse: () => 0,
  );
});

/// Filtered list of bookmarked notes
final bookmarkedNotesProvider = Provider<List<Note>>((ref) {
  final notesState = ref.watch(notesProvider);
  return notesState.maybeWhen(
    data: (notes) => notes.where((n) => n.isBookmarked).toList(),
    orElse: () => [],
  );
});

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final INoteRepository _noteRepo;
  final Uuid _uuid = const Uuid();

  NotesNotifier(this._noteRepo) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final notes = await _noteRepo.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Note> createNote({
    required String title,
    required String contentJson,
    required String plainText,
    required String subjectId,
    bool isBookmarked = false,
    List<Attachment> attachments = const [],
    String? diagramJson,
    String? diagramImagePath,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title.trim().isNotEmpty ? title.trim() : 'Untitled Note',
      contentJson: contentJson,
      plainText: plainText,
      subjectId: subjectId,
      isBookmarked: isBookmarked,
      attachments: attachments,
      diagramJson: diagramJson,
      diagramImagePath: diagramImagePath,
      createdAt: now,
      updatedAt: now,
    );

    await _noteRepo.saveNote(note);
    await loadNotes();
    return note;
  }

  Future<void> saveOrUpdateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    await _noteRepo.saveNote(updated);
    await loadNotes();
  }

  Future<void> toggleBookmark(String noteId) async {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final note = currentList[index];
      final updated = note.copyWith(
        isBookmarked: !note.isBookmarked,
        updatedAt: DateTime.now(),
      );
      await _noteRepo.saveNote(updated);
      await loadNotes();
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _noteRepo.deleteNote(noteId);
    await loadNotes();
  }

  Future<void> moveNoteSubject(String noteId, String newSubjectId) async {
    final note = await _noteRepo.getNoteById(noteId);
    if (note != null) {
      final updated = note.copyWith(
        subjectId: newSubjectId,
        updatedAt: DateTime.now(),
      );
      await _noteRepo.saveNote(updated);
      await loadNotes();
    }
  }
}
