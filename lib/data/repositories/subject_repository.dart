import '../models/subject_model.dart';
import '../services/storage_service.dart';

abstract class ISubjectRepository {
  Future<List<Subject>> getAllSubjects();
  Future<Subject?> getSubjectById(String id);
  Future<void> saveSubject(Subject subject);
  Future<void> deleteSubject(String id);
}

class SubjectRepository implements ISubjectRepository {
  final StorageService _storageService;

  SubjectRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  @override
  Future<List<Subject>> getAllSubjects() async {
    final box = _storageService.subjectsBox;
    final List<Subject> subjects = [];
    for (var key in box.keys) {
      final data = box.get(key);
      if (data is Map) {
        subjects.add(Subject.fromMap(Map<String, dynamic>.from(data)));
      }
    }
    subjects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return subjects;
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    final box = _storageService.subjectsBox;
    final data = box.get(id);
    if (data is Map) {
      return Subject.fromMap(Map<String, dynamic>.from(data));
    }
    return null;
  }

  @override
  Future<void> saveSubject(Subject subject) async {
    final box = _storageService.subjectsBox;
    await box.put(subject.id, subject.toMap());
  }

  @override
  Future<void> deleteSubject(String id) async {
    final box = _storageService.subjectsBox;
    await box.delete(id);
  }
}
