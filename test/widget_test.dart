import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/app.dart';
import 'package:notes_app/core/constants/app_constants.dart';
import 'package:notes_app/data/models/attachment_model.dart';
import 'package:notes_app/data/models/diagram_model.dart';
import 'package:notes_app/data/models/note_model.dart';
import 'package:notes_app/data/models/subject_model.dart';
import 'package:notes_app/data/repositories/note_repository.dart';
import 'package:notes_app/data/repositories/subject_repository.dart';
import 'package:notes_app/data/services/pdf_export_service.dart';
import 'package:notes_app/data/services/storage_service.dart';
import 'package:notes_app/providers/search_provider.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('hive_notes_test_');
    Hive.init(tempDir.path);
    await StorageService().init(isTest: true);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('Domain Models Test', () {
    test('Subject model serialization', () {
      final subject = Subject(
        id: 'sub-1',
        name: 'Physics',
        colorValue: 0xFFFFC107,
        iconCodePoint: 1234,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = subject.toMap();
      final fromMap = Subject.fromMap(map);

      expect(fromMap.id, 'sub-1');
      expect(fromMap.name, 'Physics');
      expect(fromMap.colorValue, 0xFFFFC107);
    });

    test('Attachment model serialization', () {
      final attachment = Attachment(
        id: 'att-1',
        fileName: 'handout.pdf',
        filePath: '/data/user/handout.pdf',
        fileType: AttachmentType.pdf,
        fileSizeBytes: 1024,
        createdAt: DateTime(2026, 1, 1),
      );

      final map = attachment.toMap();
      final fromMap = Attachment.fromMap(map);

      expect(fromMap.id, 'att-1');
      expect(fromMap.fileType, AttachmentType.pdf);
      expect(fromMap.fileSizeBytes, 1024);
    });

    test('Note model serialization and bookmark toggle', () {
      final note = Note(
        id: 'note-1',
        title: 'Newton Laws',
        contentJson: '[]',
        plainText: 'Force equals mass times acceleration',
        subjectId: 'sub-1',
        isBookmarked: true,
        attachments: [],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final map = note.toMap();
      final fromMap = Note.fromMap(map);

      expect(fromMap.id, 'note-1');
      expect(fromMap.title, 'Newton Laws');
      expect(fromMap.isBookmarked, true);
    });

    test('DiagramElement model serialization', () {
      const element = DiagramElement(
        id: 'elem-1',
        toolType: DiagramToolType.rectangle,
        points: [OffsetPoint(0, 0), OffsetPoint(100, 100)],
        colorValue: 0xFF000000,
        strokeWidth: 3.0,
      );

      final map = element.toMap();
      final fromMap = DiagramElement.fromMap(map);

      expect(fromMap.id, 'elem-1');
      expect(fromMap.toolType, DiagramToolType.rectangle);
      expect(fromMap.points.length, 2);
    });
  });

  group('Repositories and Business Logic Tests', () {
    test('SubjectRepository CRUD operations', () async {
      final subjectRepo = SubjectRepository();
      final subject = Subject(
        id: 'test-math-1',
        name: 'Calculus',
        colorValue: 0xFFFF5722,
        iconCodePoint: Icons.functions.codePoint,
        createdAt: DateTime.now(),
      );

      await subjectRepo.saveSubject(subject);
      final fetched = await subjectRepo.getSubjectById('test-math-1');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Calculus');

      final allSubjects = await subjectRepo.getAllSubjects();
      expect(allSubjects.any((s) => s.id == 'test-math-1'), isTrue);

      await subjectRepo.deleteSubject('test-math-1');
      final deleted = await subjectRepo.getSubjectById('test-math-1');
      expect(deleted, isNull);
    });

    test('NoteRepository CRUD and Cascade/Uncategorize Delete Strategies', () async {
      final noteRepo = NoteRepository();
      final subjectRepo = SubjectRepository();

      final chemSubject = Subject(
        id: 'chem-sub-1',
        name: 'Chemistry',
        colorValue: 0xFF4CAF50,
        iconCodePoint: Icons.biotech.codePoint,
        createdAt: DateTime.now(),
      );
      await subjectRepo.saveSubject(chemSubject);

      final note1 = Note(
        id: 'chem-note-1',
        title: 'Organic Chemistry Reactions',
        contentJson: '[]',
        plainText: 'Alkanes, Alkenes and Alkynes mechanism',
        subjectId: 'chem-sub-1',
        isBookmarked: false,
        attachments: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await noteRepo.saveNote(note1);

      final fetched = await noteRepo.getNoteById('chem-note-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Organic Chemistry Reactions');

      // Strategy 1: Move notes to Uncategorized upon subject deletion
      await noteRepo.moveNotesToSubject('chem-sub-1', AppConstants.uncategorizedSubjectId);
      final reassigned = await noteRepo.getNoteById('chem-note-1');
      expect(reassigned!.subjectId, AppConstants.uncategorizedSubjectId);

      // Strategy 2: Delete all notes
      await noteRepo.deleteNotesBySubject(AppConstants.uncategorizedSubjectId);
      final deletedNote = await noteRepo.getNoteById('chem-note-1');
      expect(deletedNote, isNull);
    });

    test('PDF Export Service generates valid computerized bytes', () async {
      final note = Note(
        id: 'pdf-test-note',
        title: 'Physics Summary Sheet',
        contentJson: '[]',
        plainText: 'Kinematics: v = u + at, s = ut + 0.5at^2',
        subjectId: 'sub-phys',
        isBookmarked: true,
        attachments: [],
        createdAt: DateTime(2026, 9, 21),
        updatedAt: DateTime(2026, 9, 21),
      );

      final subject = Subject(
        id: 'sub-phys',
        name: 'Physics',
        colorValue: 0xFF2196F3,
        iconCodePoint: 1234,
        createdAt: DateTime.now(),
      );

      final pdfService = PdfExportService();
      final bytes = await pdfService.generateNotePdf(
        note: note,
        subject: subject,
        mode: PdfExportMode.computerized,
      );

      expect(bytes, isNotEmpty);
      // PDF documents start with '%PDF-'
      expect(bytes.sublist(0, 5), [0x25, 0x50, 0x44, 0x46, 0x2D]);
    });
  });

  group('Search & Filter Tests', () {
    test('SearchFilterNotifier updates query, subject, date, and bookmarks', () {
      final notifier = SearchFilterNotifier();
      expect(notifier.state.query, '');
      expect(notifier.state.selectedSubjectId, isNull);
      expect(notifier.state.onlyBookmarked, isFalse);

      notifier.setQuery('Quantum');
      expect(notifier.state.query, 'Quantum');

      notifier.setSubjectFilter('sub-123');
      expect(notifier.state.selectedSubjectId, 'sub-123');

      notifier.toggleBookmarkedOnly();
      expect(notifier.state.onlyBookmarked, isTrue);

      notifier.setDateFilter(SearchDateFilter.thisWeek);
      expect(notifier.state.dateFilter, SearchDateFilter.thisWeek);

      notifier.clearFilters();
      expect(notifier.state.query, '');
      expect(notifier.state.selectedSubjectId, isNull);
      expect(notifier.state.onlyBookmarked, isFalse);
    });
  });

  group('Widget Tests', () {
    testWidgets('App launches, transitions from splash to main nav, and renders home', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: StudentNotesApp(),
        ),
      );

      // Splash screen display
      expect(find.text(AppConstants.appName), findsWidgets);

      // Advance clock past splash transition (1500ms)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Main navigation and header rendered
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('Add Note'), findsOneWidget);
    });
  });
}
