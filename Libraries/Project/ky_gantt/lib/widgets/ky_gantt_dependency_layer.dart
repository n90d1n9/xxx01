import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import 'ky_gantt_dependency_painter.dart';

class KyGanttDependencyLayer extends StatelessWidget {
  const KyGanttDependencyLayer({
    required this.tasks,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalDays,
    required this.dayWidth,
    required this.rowHeight,
    this.selectedTaskId,
    this.highlightSelectedTask = true,
    this.highlightConflictedDependencies = true,
    this.focusScope = KyGanttDependencyLineFocusScope.direct,
    this.color,
    this.highlightColor,
    this.conflictColor,
    this.lineOpacity = 0.62,
    this.inactiveLineOpacity = 0.16,
    this.highlightLineOpacity = 0.9,
    this.conflictLineOpacity = 0.92,
    this.strokeWidth = 1.6,
    this.highlightStrokeWidth = 2.4,
    this.conflictStrokeWidth = 2.2,
    this.layerKey = defaultLayerKey,
    super.key,
  });

  static const defaultLayerKey = ValueKey('ky-gantt-dependency-layer');

  final List<GanttTask> tasks;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int totalDays;
  final double dayWidth;
  final double rowHeight;
  final String? selectedTaskId;
  final bool highlightSelectedTask;
  final bool highlightConflictedDependencies;
  final KyGanttDependencyLineFocusScope focusScope;
  final Color? color;
  final Color? highlightColor;
  final Color? conflictColor;
  final double lineOpacity;
  final double inactiveLineOpacity;
  final double highlightLineOpacity;
  final double conflictLineOpacity;
  final double strokeWidth;
  final double highlightStrokeWidth;
  final double conflictStrokeWidth;
  final Key? layerKey;

  @override
  Widget build(BuildContext context) {
    final size = Size(totalDays * dayWidth, tasks.length * rowHeight);
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedColor = color ?? colorScheme.primary;

    return CustomPaint(
      key: layerKey,
      size: size,
      isComplex: true,
      painter: KyGanttDependencyPainter(
        tasks: tasks,
        rangeStart: rangeStart,
        rangeEnd: rangeEnd,
        dayWidth: dayWidth,
        rowHeight: rowHeight,
        selectedTaskId: selectedTaskId,
        highlightSelectedTask: highlightSelectedTask,
        highlightConflictedDependencies: highlightConflictedDependencies,
        focusScope: focusScope,
        color: resolvedColor,
        highlightColor: highlightColor,
        conflictColor: conflictColor ?? colorScheme.error,
        lineOpacity: lineOpacity,
        inactiveLineOpacity: inactiveLineOpacity,
        highlightLineOpacity: highlightLineOpacity,
        conflictLineOpacity: conflictLineOpacity,
        strokeWidth: strokeWidth,
        highlightStrokeWidth: highlightStrokeWidth,
        conflictStrokeWidth: conflictStrokeWidth,
      ),
    );
  }
}
