import 'package:flutter/material.dart';

import 'ky_gantt_grid_painter.dart';

class KyGanttGrid extends StatelessWidget {
  const KyGanttGrid({
    required this.rangeStart,
    required this.totalDays,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowCount,
    this.showWeekendBands = true,
    this.weekendBandColor,
    this.weekendBandOpacity = 0.5,
    this.gridKey = defaultGridKey,
    super.key,
  });

  static const defaultGridKey = ValueKey('ky-gantt-grid');

  final DateTime rangeStart;
  final int totalDays;
  final double dayWidth;
  final double rowHeight;
  final int rowCount;
  final bool showWeekendBands;
  final Color? weekendBandColor;
  final double weekendBandOpacity;
  final Key? gridKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = Size(totalDays * dayWidth, rowCount * rowHeight);
    final bandOpacity = weekendBandOpacity.clamp(0, 1).toDouble();
    final bandColor = weekendBandColor ?? colorScheme.surfaceContainerHighest;

    return CustomPaint(
      key: gridKey,
      size: size,
      isComplex: true,
      painter: KyGanttGridPainter(
        rangeStart: rangeStart,
        totalDays: totalDays,
        dayWidth: dayWidth,
        rowHeight: rowHeight,
        rowCount: rowCount,
        showWeekendBands: showWeekendBands,
        weekendColor: bandColor.withValues(alpha: bandOpacity),
        verticalLineColor: colorScheme.outlineVariant.withValues(alpha: 0.62),
        horizontalLineColor: colorScheme.outlineVariant,
      ),
    );
  }
}
