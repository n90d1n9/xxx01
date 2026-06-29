import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final bool isDark;
  final double gridSize;

  GridPainter({this.isDark = false, this.gridSize = 20.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1)
          ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.gridSize != gridSize;
}
