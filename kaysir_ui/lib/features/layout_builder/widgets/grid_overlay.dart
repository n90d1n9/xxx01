import 'package:flutter/material.dart';

import '../models/layout_config.dart';
import 'grid_painter.dart';

class GridOverlay extends StatelessWidget {
  final LayoutConfig config;
  final double opacity;

  const GridOverlay({super.key, required this.config, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: switch (config.layoutMechanism) {
          LayoutMechanism.tabularColumns => TabularGridPainter(
            columnCount: config.tabularColumnCount,
            columnGap: config.tabularColumnGap,
            rowHeight: config.tabularRowHeight,
            color: Colors.grey.withValues(alpha: opacity),
          ),
          LayoutMechanism.autoGrid => AutoGridPainter(
            columnCount: config.autoGridColumnCount,
            gap: config.autoGridGap,
            rowHeight: config.autoGridRowHeight,
            color: Colors.grey.withValues(alpha: opacity),
          ),
          LayoutMechanism.freeform || LayoutMechanism.grid => GridPainter(
            cellSize: Size.square(config.gridSize),
            color: Colors.grey.withValues(alpha: opacity),
            showSubgrid: true,
          ),
        },
        child: const SizedBox.expand(),
      ),
    );
  }
}
