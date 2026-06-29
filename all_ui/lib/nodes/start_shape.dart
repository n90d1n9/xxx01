import 'package:flutter/material.dart';

class StartShapePainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  StartShapePainter({
    this.borderColor = const Color(0xFF979797),
    this.fillColor = const Color(0xFF40E65F),
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final path = Path();

    // Translated path to 0,0 origin based on your SVG
    path.moveTo(80, 0);
    path.lineTo(80, 48);
    path.lineTo(26.363636, 48);
    path.cubicTo(19.083519, 48, 12.49261, 45.313708, 7.72173, 40.970563);
    path.cubicTo(2.950851, 36.627417, 0, 30.627417, 0, 24);
    path.cubicTo(0, 17.372583, 2.950851, 11.372583, 7.72173, 7.029437);
    path.cubicTo(12.49261, 2.686291, 19.083519, 0, 26.363636, 0);
    path.close();

    // Draw fill first, then stroke (to avoid clipping)
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
