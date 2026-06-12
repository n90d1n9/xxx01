import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSize;
  final bool isDark;

  GridPainter({required this.gridSize, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isDark ? Colors.grey.shade700 : Colors.grey.shade300
          ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.isDark != isDark;
  }
}
