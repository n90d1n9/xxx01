import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/layout_config.dart';
import '../provider/layout_state_provider.dart';
import 'grid_painter.dart';

class GridBackground extends ConsumerWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSettings = ref.watch(
      layoutStateProvider.select((state) => state.gridSettings),
    );
    final config = ref.watch(
      layoutStateProvider.select((state) => state.config),
    );

    if (!gridSettings.enabled) return const SizedBox.expand();

    return CustomPaint(
      painter: switch (config.layoutMechanism) {
        LayoutMechanism.tabularColumns => TabularGridPainter(
          columnCount: config.tabularColumnCount,
          columnGap: config.tabularColumnGap,
          rowHeight: config.tabularRowHeight,
          color: gridSettings.gridColor.withValues(alpha: gridSettings.opacity),
        ),
        LayoutMechanism.autoGrid => AutoGridPainter(
          columnCount: config.autoGridColumnCount,
          gap: config.autoGridGap,
          rowHeight: config.autoGridRowHeight,
          color: gridSettings.gridColor.withValues(alpha: gridSettings.opacity),
        ),
        LayoutMechanism.freeform || LayoutMechanism.grid => GridPainter(
          cellSize: Size.square(gridSettings.gridSize),
          color: gridSettings.gridColor.withValues(alpha: gridSettings.opacity),
          showSubgrid: gridSettings.showSubgrid,
        ),
      },
      child: const SizedBox.expand(),
    );
  }
}
