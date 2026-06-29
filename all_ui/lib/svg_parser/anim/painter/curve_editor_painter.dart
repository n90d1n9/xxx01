import 'package:flutter/material.dart';

class CurveEditorPainter extends CustomPainter {
  final Offset controlPoint1;
  final Offset controlPoint2;

  CurveEditorPainter({
    required this.controlPoint1,
    required this.controlPoint2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);

    // Draw curve
    final path = Path();
    path.moveTo(0, size.height);

    for (var i = 0; i <= 100; i++) {
      final t = i / 100;
      final x = size.width * t;
      final y = size.height * (1 - _cubicBezier(t));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final curvePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    canvas.drawPath(path, curvePaint);

    // Draw control points
    _drawControlPoint(canvas, controlPoint1, size, Colors.red);
    _drawControlPoint(canvas, controlPoint2, size, Colors.green);
  }

  double _cubicBezier(double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    return uuu * 0 +
        3 * uu * t * controlPoint1.dy +
        3 * u * tt * controlPoint2.dy +
        ttt * 1;
  }

  void _drawGrid(Canvas canvas, Size size) {
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
  }

  void _drawControlPoint(Canvas canvas, Offset point, Size size, Color color) {
    final screenPos = Offset(
      point.dx * size.width,
      (1 - point.dy) * size.height,
    );

    // Draw line to point
    final linePaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 1;

    canvas.drawLine(Offset(0, size.height), screenPos, linePaint);

    // Draw point
    final pointPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawCircle(screenPos, 8, pointPaint);
  }

  @override
  bool shouldRepaint(CurveEditorPainter oldDelegate) => true;
}
