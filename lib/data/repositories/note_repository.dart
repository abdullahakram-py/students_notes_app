import '../models/note_model.dart';
import '../services/storage_service.dart';

abstract class INoteRepository {
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<List<Note>> getNotesBySubject(String subjectId);
  Future<List<Note>> getBookmarkedNotes();
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> moveNotesToSubject(String oldSubjectId, String newSubjectId);
  Future<void> deleteNotesBySubject(String subjectId);
}

class NoteRepository implements INoteRepository {
  final StorageService _storageService;

  NoteRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  @override
  Future<List<Note>> getAllNotes() async {
    final box = _storageService.notesBox;
    final List<Note> notes = [];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        notes.add(Note.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    // Sort latest updated first
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final box = _storageService.notesBox;
    final data = box.get(id);
    if (data is Map) {
      return Note.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<List<Note>> getNotesBySubject(String subjectId) async {
    final all = await getAllNotes();
    return all.where((n) => n.subjectId == subjectId).toList();
  }

  @override
  Future<List<Note>> getBookmarkedNotes() async {
    final all = await getAllNotes();
    return all.where((n) => n.isBookmarked).toList();
  }

  @override
  Future<void> saveNote(Note note) async {
    final box = _storageService.notesBox;
    await box.put(note.id, note.toMap());
  }

  @override
  Future<void> deleteNote(String id) async {
    final box = _storageService.notesBox;
    await box.delete(id);
  }

  @override
  Future<void> moveNotesToSubject(String oldSubjectId, String newSubjectId) async {
    final box = _storageService.notesBox;
    final notes = await getNotesBySubject(oldSubjectId);
    for (final note in notes) {
      final updated = note.copyWith(
        subjectId: newSubjectId,
        updatedAt: DateTime.now(),
      );
      await box.put(updated.id, updated.toMap());
    }
  }

  @override
  Future<void> deleteNotesBySubject(String subjectId) async {
    final box = _storageService.notesBox;
    final notes = await getNotesBySubject(subjectId);
    for (final note in notes) {
      await box.delete(note.id);
    }
  }
}
