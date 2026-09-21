/// Type of media attached to a note
enum AttachmentType { image, pdf }

/// Represents an image or PDF attachment associated with a note
class Attachment {
  final String id;
  final String fileName;
  final String filePath;
  final AttachmentType fileType;
  final int fileSizeBytes;
  final DateTime createdAt;

  const Attachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  Attachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    AttachmentType? fileType,
    int? fileSizeBytes,
    DateTime? createdAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType.name,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      id: map['id'] as String,
      fileName: map['fileName'] as String? ?? 'Untitled Attachment',
      filePath: map['filePath'] as String,
      fileType: AttachmentType.values.firstWhere(
        (e) => e.name == map['fileType'],
        orElse: () => AttachmentType.image,
      ),
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
