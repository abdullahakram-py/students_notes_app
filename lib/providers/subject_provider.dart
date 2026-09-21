import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../data/models/subject_model.dart';
import '../data/repositories/note_repository.dart';
import '../data/repositories/subject_repository.dart';
import 'note_provider.dart';

final subjectRepositoryProvider = Provider<ISubjectRepository>((ref) {
  return SubjectRepository();
});

final subjectsProvider = StateNotifierProvider<SubjectNotifier, AsyncValue<List<Subject>>>((ref) {
  final subjectRepo = ref.watch(subjectRepositoryProvider);
  final noteRepo = ref.watch(noteRepositoryProvider);
  return SubjectNotifier(subjectRepo, noteRepo);
});

enum SubjectDeleteStrategy {
  moveToUncategorized,
  deleteAllNotes,
}

class SubjectNotifier extends StateNotifier<AsyncValue<List<Subject>>> {
  final ISubjectRepository _subjectRepo;
  final INoteRepository _noteRepo;
  final Uuid _uuid = const Uuid();

  SubjectNotifier(this._subjectRepo, this._noteRepo) : super(const AsyncValue.loading()) {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    try {
      final subjects = await _subjectRepo.getAllSubjects();
      state = AsyncValue.data(subjects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Subject> addSubject({
    required String name,
    required int colorValue,
    required int iconCodePoint,
  }) async {
    final newSubject = Subject(
      id: _uuid.v4(),
      name: name.trim(),
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      createdAt: DateTime.now(),
    );
    await _subjectRepo.saveSubject(newSubject);
    await loadSubjects();
    return newSubject;
  }

  Future<void> updateSubject(Subject subject) async {
    await _subjectRepo.saveSubject(subject);
    await loadSubjects();
  }

  Future<void> deleteSubject(String subjectId, SubjectDeleteStrategy strategy) async {
    if (strategy == SubjectDeleteStrategy.moveToUncategorized) {
      // Move all associated notes to Uncategorized
      await _noteRepo.moveNotesToSubject(subjectId, AppConstants.uncategorizedSubjectId);
    } else {
      // Cascade delete notes
      await _noteRepo.deleteNotesBySubject(subjectId);
    }

    await _subjectRepo.deleteSubject(subjectId);
    await loadSubjects();
  }
}
