import 'package:flutter/material.dart';

/// Available tools in the diagram canvas
enum DiagramToolType {
  pen,
  rectangle,
  circle,
  line,
  arrow,
  text,
}

/// A 2D point representation serializable to JSON
class OffsetPoint {
  final double dx;
  final double dy;

  const OffsetPoint(this.dx, this.dy);

  Offset toOffset() => Offset(dx, dy);

  Map<String, dynamic> toMap() => {'dx': dx, 'dy': dy};

  factory OffsetPoint.fromMap(Map<String, dynamic> map) {
    return OffsetPoint(
      (map['dx'] as num).toDouble(),
      (map['dy'] as num).toDouble(),
    );
  }

  factory OffsetPoint.fromOffset(Offset offset) {
    return OffsetPoint(offset.dx, offset.dy);
  }
}

/// A single vector element on the diagram canvas
class DiagramElement {
  final String id;
  final DiagramToolType toolType;
  final List<OffsetPoint> points;
  final String? text;
  final int colorValue;
  final double strokeWidth;
  final bool isFilled;

  const DiagramElement({
    required this.id,
    required this.toolType,
    required this.points,
    this.text,
    required this.colorValue,
    required this.strokeWidth,
    this.isFilled = false,
  });

  Color get color => Color(colorValue);

  DiagramElement copyWith({
    String? id,
    DiagramToolType? toolType,
    List<OffsetPoint>? points,
    String? text,
    int? colorValue,
    double? strokeWidth,
    bool? isFilled,
  }) {
    return DiagramElement(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      points: points ?? this.points,
      text: text ?? this.text,
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isFilled: isFilled ?? this.isFilled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toolType': toolType.name,
      'points': points.map((p) => p.toMap()).toList(),
      'text': text,
      'colorValue': colorValue,
      'strokeWidth': strokeWidth,
      'isFilled': isFilled,
    };
  }

  factory DiagramElement.fromMap(Map<String, dynamic> map) {
    return DiagramElement(
      id: map['id'] as String,
      toolType: DiagramToolType.values.firstWhere(
        (e) => e.name == map['toolType'],
        orElse: () => DiagramToolType.pen,
      ),
      points: (map['points'] as List<dynamic>?)
              ?.map((p) => OffsetPoint.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      text: map['text'] as String?,
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFF000000,
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 3.0,
      isFilled: map['isFilled'] as bool? ?? false,
    );
  }
}
