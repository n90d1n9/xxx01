import 'package:flutter/material.dart';

class SelectionRectanglePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  SelectionRectanglePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, end);

    // Draw selection rectangle fill
    final fillPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.2)
          ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Draw selection rectangle border
    final borderPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
    canvas.drawRect(rect, borderPaint);

    // Draw dashed border effect
    final dashPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.square;

    // Create dashed effect
    _drawDashedRect(canvas, rect, dashPaint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;

    // Top line
    _drawDashedLine(
      canvas,
      rect.topLeft,
      rect.topRight,
      dashWidth,
      dashSpace,
      paint,
    );

    // Right line
    _drawDashedLine(
      canvas,
      rect.topRight,
      rect.bottomRight,
      dashWidth,
      dashSpace,
      paint,
    );

    // Bottom line
    _drawDashedLine(
      canvas,
      rect.bottomRight,
      rect.bottomLeft,
      dashWidth,
      dashSpace,
      paint,
    );

    // Left line
    _drawDashedLine(
      canvas,
      rect.bottomLeft,
      rect.topLeft,
      dashWidth,
      dashSpace,
      paint,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    double dashWidth,
    double dashSpace,
    Paint paint,
  ) {
    final path = Path();
    final distance = (end - start).distance;
    final direction = (end - start) / distance;

    double drawn = 0.0;
    while (drawn < distance) {
      final segmentEnd = drawn + dashWidth;
      if (segmentEnd > distance) {
        path.moveTo(
          start.dx + direction.dx * drawn,
          start.dy + direction.dy * drawn,
        );
        path.lineTo(end.dx, end.dy);
      } else {
        path.moveTo(
          start.dx + direction.dx * drawn,
          start.dy + direction.dy * drawn,
        );
        path.lineTo(
          start.dx + direction.dx * segmentEnd,
          start.dy + direction.dy * segmentEnd,
        );
      }
      drawn += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SelectionRectanglePainter oldDelegate) {
    return start != oldDelegate.start || end != oldDelegate.end;
  }
}
