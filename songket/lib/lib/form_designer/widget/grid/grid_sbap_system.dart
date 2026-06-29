import 'package:flutter/material.dart';

import '../../model/form_theme.dart';
import 'grid_painter.dart';

class GridSnapSystem {
  static const double gridSize = 8.0;
  static const bool showGrid = true;
  static const bool snapToGrid = true;

  static Offset snapPosition(Offset position) {
    if (!snapToGrid) return position;

    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  static Widget buildGridOverlay(FormTheme theme) {
    if (!showGrid) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: GridPainter(
          gridSize: gridSize,
          color: theme.colors.border.withOpacity(0.1),
        ),
        child: Container(),
      ),
    );
  }
}
