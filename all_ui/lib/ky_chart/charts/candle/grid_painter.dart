import 'package:flutter/material.dart';
import 'package:ky_chart/utils/helper.dart';

import '../../model/grid.dart';

class GridPainter extends CustomPainter {
  final Grid grid;

  GridPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stringToColor(grid.color)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    if (grid.showHorizontalLines) {
      const divisions = 5;
      for (int i = 0; i <= divisions; i++) {
        final y = (i / divisions) * size.height;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }

    // Draw vertical grid lines
    if (grid.showVerticalLines) {
      const divisions = 6;
      for (int i = 0; i <= divisions; i++) {
        final x = (i / divisions) * size.width;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
