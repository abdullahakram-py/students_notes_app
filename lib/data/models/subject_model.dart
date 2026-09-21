import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Subject category model for grouping academic notes
class Subject {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final DateTime createdAt;

  const Subject({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    required this.createdAt,
  });

  Color get color => Color(colorValue);
  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Fallback default subject for orphaned notes
  static Subject get uncategorized => Subject(
        id: AppConstants.uncategorizedSubjectId,
        name: AppConstants.uncategorizedSubjectName,
        colorValue: AppColors.lightPrimary.toARGB32(),
        iconCodePoint: Icons.folder_outlined.codePoint,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  Subject copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Untitled Subject',
      colorValue: (map['colorValue'] as num?)?.toInt() ?? AppColors.lightPrimary.toARGB32(),
      iconCodePoint: (map['iconCodePoint'] as num?)?.toInt() ?? Icons.menu_book_rounded.codePoint,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
