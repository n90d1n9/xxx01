import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final Offset offset;
  final double zoom;
  final double gridSpacing;
  final Color gridColor;

  GridPainter({
    required this.offset,
    required this.zoom,
    this.gridSpacing = 10.0,
    this.gridColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;
    final effectiveGridSize = gridSize * zoom;

    for (
      double x = offset.dx % effectiveGridSize;
      x < size.width;
      x += effectiveGridSize
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (
      double y = offset.dy % effectiveGridSize;
      y < size.height;
      y += effectiveGridSize
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.zoom != zoom;
}
