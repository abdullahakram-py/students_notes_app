import 'attachment_model.dart';

/// Primary Note domain model supporting rich text, attachments, diagrams, and metadata
class Note {
  final String id;
  final String title;
  final String contentJson;
  final String plainText;
  final String subjectId;
  final bool isBookmarked;
  final List<Attachment> attachments;
  final String? diagramJson;
  final String? diagramImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.plainText,
    required this.subjectId,
    required this.isBookmarked,
    required this.attachments,
    this.diagramJson,
    this.diagramImagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? contentJson,
    String? plainText,
    String? subjectId,
    bool? isBookmarked,
    List<Attachment>? attachments,
    String? diagramJson,
    String? diagramImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      plainText: plainText ?? this.plainText,
      subjectId: subjectId ?? this.subjectId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      attachments: attachments ?? this.attachments,
      diagramJson: diagramJson ?? this.diagramJson,
      diagramImagePath: diagramImagePath ?? this.diagramImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'contentJson': contentJson,
      'plainText': plainText,
      'subjectId': subjectId,
      'isBookmarked': isBookmarked,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'diagramJson': diagramJson,
      'diagramImagePath': diagramImagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled Note',
      contentJson: map['contentJson'] as String? ?? '[]',
      plainText: map['plainText'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      isBookmarked: map['isBookmarked'] as bool? ?? false,
      attachments: (map['attachments'] as List<dynamic>?)
              ?.map((a) => Attachment.fromMap(Map<String, dynamic>.from(a as Map)))
              .toList() ??
          [],
      diagramJson: map['diagramJson'] as String?,
      diagramImagePath: map['diagramImagePath'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
