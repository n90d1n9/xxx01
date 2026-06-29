import 'package:flutter/material.dart';

class DottedGridPainter extends CustomPainter {
  final double dotSpacing;
  final double dotRadius;
  final Color dotColor;

  DottedGridPainter({
    required this.dotSpacing,
    required this.dotRadius,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += dotSpacing) {
      for (double y = 0; y < size.height; y += dotSpacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
