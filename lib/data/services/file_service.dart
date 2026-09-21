import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../models/attachment_model.dart';

/// Exception thrown when file exceeds 20MB limit
class FileSizeExceededException implements Exception {
  final String message;
  FileSizeExceededException([this.message = AppStrings.fileTooLarge]);
  @override
  String toString() => message;
}

/// Service managing file picks, local storage copying, and size limits
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Returns base directory for storing note attachments
  Future<Directory> _getAttachmentsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'student_notes', 'attachments'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns directory for storing diagram snapshot images
  Future<Directory> _getDiagramsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'student_notes', 'diagrams'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Capture photo from Camera
  Future<Attachment?> capturePhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return null;
    return _processFile(File(file.path), AttachmentType.image, file.name);
  }

  /// Pick image from device Gallery
  Future<Attachment?> pickImage() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return null;
    return _processFile(File(file.path), AttachmentType.image, file.name);
  }

  /// Pick PDF document from file system
  Future<Attachment?> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return null;

    final singleFile = result.files.single;
    if (singleFile.path == null) return null;

    return _processFile(
      File(singleFile.path!),
      AttachmentType.pdf,
      singleFile.name,
    );
  }

  /// Validates 20MB limit, copies file to app directory, returns Attachment entity
  Future<Attachment> _processFile(
    File sourceFile,
    AttachmentType type,
    String originalName,
  ) async {
    final size = await sourceFile.length();
    if (size > AppConstants.maxFileSizeBytes) {
      throw FileSizeExceededException();
    }

    final targetDir = await _getAttachmentsDir();
    final extension = p.extension(sourceFile.path);
    final uniqueId = _uuid.v4();
    final newFileName = 'att_$uniqueId$extension';
    final targetPath = p.join(targetDir.path, newFileName);

    final savedFile = await sourceFile.copy(targetPath);

    return Attachment(
      id: uniqueId,
      fileName: originalName.isNotEmpty ? originalName : newFileName,
      filePath: savedFile.path,
      fileType: type,
      fileSizeBytes: size,
      createdAt: DateTime.now(),
    );
  }

  /// Save raw diagram PNG bytes into app storage
  Future<String> saveDiagramImage(Uint8List bytes) async {
    final dir = await _getDiagramsDir();
    final id = _uuid.v4();
    final filePath = p.join(dir.path, 'diag_$id.png');
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Delete attachment file from disk
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Ignored if already removed
    }
  }
}
