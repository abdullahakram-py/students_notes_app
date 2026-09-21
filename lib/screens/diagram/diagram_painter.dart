import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/diagram_model.dart';

class DiagramPainter extends CustomPainter {
  final List<DiagramElement> elements;
  final DiagramElement? currentElement;

  DiagramPainter({
    required this.elements,
    this.currentElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw all committed elements
    for (final element in elements) {
      _drawElement(canvas, element);
    }

    // 2. Draw currently active drag element if any
    if (currentElement != null) {
      _drawElement(canvas, currentElement!);
    }
  }

  void _drawElement(Canvas canvas, DiagramElement element) {
    final paint = Paint()
      ..color = element.color
      ..strokeWidth = element.strokeWidth
      ..style = element.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (element.toolType) {
      case DiagramToolType.pen:
        if (element.points.length < 2) return;
        final path = Path();
        path.moveTo(element.points.first.dx, element.points.first.dy);
        for (int i = 1; i < element.points.length; i++) {
          path.lineTo(element.points[i].dx, element.points[i].dy);
        }
        canvas.drawPath(path, paint);
        break;

      case DiagramToolType.rectangle:
        if (element.points.length < 2) return;
        final p1 = element.points.first.toOffset();
        final p2 = element.points.last.toOffset();
        final rect = Rect.fromPoints(p1, p2);
        canvas.drawRect(rect, paint);
        break;

      case DiagramToolType.circle:
        if (element.points.length < 2) return;
        final p1 = element.points.first.toOffset();
        final p2 = element.points.last.toOffset();
        final rect = Rect.fromPoints(p1, p2);
        canvas.drawOval(rect, paint);
        break;

      case DiagramToolType.line:
        if (element.points.length < 2) return;
        final p1 = element.points.first.toOffset();
        final p2 = element.points.last.toOffset();
        canvas.drawLine(p1, p2, paint);
        break;

      case DiagramToolType.arrow:
        if (element.points.length < 2) return;
        final p1 = element.points.first.toOffset();
        final p2 = element.points.last.toOffset();
        _drawArrow(canvas, p1, p2, paint);
        break;

      case DiagramToolType.text:
        if (element.points.isEmpty || element.text == null) return;
        final pos = element.points.first.toOffset();
        final textSpan = TextSpan(
          text: element.text,
          style: TextStyle(
            color: element.color,
            fontSize: (element.strokeWidth * 5.0).clamp(14.0, 32.0),
            fontWeight: FontWeight.w600,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, pos);
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    // Draw shaft
    canvas.drawLine(p1, p2, paint);

    // Draw arrowhead
    const arrowLength = 18.0;
    const arrowAngle = 25.0 * (pi / 180.0);

    final angle = atan2(p2.dy - p1.dy, p2.dx - p1.dx);

    final path = Path();
    path.moveTo(p2.dx, p2.dy);
    path.lineTo(
      p2.dx - arrowLength * cos(angle - arrowAngle),
      p2.dy - arrowLength * sin(angle - arrowAngle),
    );
    path.moveTo(p2.dx, p2.dy);
    path.lineTo(
      p2.dx - arrowLength * cos(angle + arrowAngle),
      p2.dy - arrowLength * sin(angle + arrowAngle),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DiagramPainter oldDelegate) => true;
}
