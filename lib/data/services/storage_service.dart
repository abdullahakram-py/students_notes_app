import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../models/note_model.dart';
import '../models/subject_model.dart';

/// Low-level Hive storage manager for notes and subjects
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box<dynamic>? _subjectsBox;
  Box<dynamic>? _notesBox;

  Future<void> init({bool isTest = false}) async {
    if (!isTest) {
      await Hive.initFlutter();
    }
    _subjectsBox = await Hive.openBox(AppConstants.subjectsBoxName);
    _notesBox = await Hive.openBox(AppConstants.notesBoxName);

    // Seed default subjects and sample notes if fresh installation
    if (_subjectsBox!.isEmpty) {
      await _seedDefaultData();
    }
  }

  Box<dynamic> get subjectsBox {
    if (_subjectsBox != null && _subjectsBox!.isOpen) {
      return _subjectsBox!;
    }
    if (Hive.isBoxOpen(AppConstants.subjectsBoxName)) {
      _subjectsBox = Hive.box(AppConstants.subjectsBoxName);
      return _subjectsBox!;
    }
    throw StateError('Subjects box not initialized. Call init() first.');
  }

  Box<dynamic> get notesBox {
    if (_notesBox != null && _notesBox!.isOpen) {
      return _notesBox!;
    }
    if (Hive.isBoxOpen(AppConstants.notesBoxName)) {
      _notesBox = Hive.box(AppConstants.notesBoxName);
      return _notesBox!;
    }
    throw StateError('Notes box not initialized. Call init() first.');
  }

  // --- Seed Initial Academic Subjects & Welcome Note ---
  Future<void> _seedDefaultData() async {
    final now = DateTime.now();
    const uuid = Uuid();

    // Default Uncategorized
    final uncategorized = Subject.uncategorized;
    await subjectsBox.put(uncategorized.id, uncategorized.toMap());

    // Sample Academic Subjects
    final physics = Subject(
      id: uuid.v4(),
      name: 'Physics',
      colorValue: const Color(0xFF42A5F5).toARGB32(),
      iconCodePoint: Icons.science_rounded.codePoint,
      createdAt: now.subtract(const Duration(days: 3)),
    );

    final mathematics = Subject(
      id: uuid.v4(),
      name: 'Mathematics',
      colorValue: const Color(0xFFFFC107).toARGB32(),
      iconCodePoint: Icons.calculate_rounded.codePoint,
      createdAt: now.subtract(const Duration(days: 2)),
    );

    final biology = Subject(
      id: uuid.v4(),
      name: 'Biology',
      colorValue: const Color(0xFF66BB6A).toARGB32(),
      iconCodePoint: Icons.biotech_rounded.codePoint,
      createdAt: now.subtract(const Duration(days: 1)),
    );

    final history = Subject(
      id: uuid.v4(),
      name: 'History',
      colorValue: const Color(0xFFFF7043).toARGB32(),
      iconCodePoint: Icons.auto_stories_rounded.codePoint,
      createdAt: now,
    );

    for (final sub in [physics, mathematics, biology, history]) {
      await subjectsBox.put(sub.id, sub.toMap());
    }

    // Welcome Sample Note
    final sampleNote = Note(
      id: uuid.v4(),
      title: 'Welcome to Student Notes! 🎓',
      contentJson: r'[{"insert":"Welcome to your all-in-one Academic Notes app!\n\n"},{"insert":"Key Features to explore:\n","attributes":{"bold":true}},{"insert":"1. Organize by Subjects (Physics, Math, History, etc.)\n2. Draw Diagrams & Geometric Shapes with the built-in Canvas\n3. Attach whiteboard photos and PDF handouts\n4. Bookmark important lecture notes for exam revision\n5. Export study notes directly to PDF format\n\n"},{"insert":"Pro-Tip: ","attributes":{"bold":true,"italic":true}},{"insert":"Tap the Star icon to pin this note to your Bookmarks tab!\n"}]',
      plainText: 'Welcome to your all-in-one Academic Notes app! Key Features to explore: 1. Organize by Subjects 2. Draw Diagrams 3. Attach whiteboard photos & PDFs 4. Bookmark key notes 5. Export to PDF.',
      subjectId: physics.id,
      isBookmarked: true,
      attachments: [],
      createdAt: now,
      updatedAt: now,
    );

    await notesBox.put(sampleNote.id, sampleNote.toMap());
  }
}
