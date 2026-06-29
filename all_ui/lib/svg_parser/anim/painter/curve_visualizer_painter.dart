import 'package:flutter/material.dart';

import '../schema/anim/animation_curve_data.dart';

class CurveVisualizerPainter extends CustomPainter {
  final AnimationCurveData curveData;

  CurveVisualizerPainter({required this.curveData});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 0.5;

    for (var i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw curve
    final curvePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);

    for (var i = 0; i <= 100; i++) {
      final t = i / 100;
      final x = size.width * t;
      final y = size.height * (1 - curveData.evaluate(t));
      path.lineTo(x, y);
    }

    canvas.drawPath(path, curvePaint);

    // Draw control points
    _drawControlPoint(canvas, size, curveData.p1, Colors.red, 'P1');
    _drawControlPoint(canvas, size, curveData.p2, Colors.green, 'P2');
  }

  void _drawControlPoint(
    Canvas canvas,
    Size size,
    Offset point,
    Color color,
    String label,
  ) {
    final screenPos = Offset(
      point.dx * size.width,
      (1 - point.dy) * size.height,
    );

    // Draw line from corner
    final linePaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height), screenPos, linePaint);
    canvas.drawLine(Offset(size.width, 0), screenPos, linePaint);

    // Draw point
    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(screenPos, 8, pointPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, screenPos + const Offset(12, -6));
  }

  @override
  bool shouldRepaint(CurveVisualizerPainter oldDelegate) => true;
}
