import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import 'ky_gantt_selection_focus.dart';

class KyGanttMilestoneMarker extends StatelessWidget {
  const KyGanttMilestoneMarker({
    required this.task,
    required this.selected,
    this.size = 20,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.semanticLabel,
    this.onTap,
    super.key,
  });

  final GanttTask task;
  final bool selected;
  final double size;
  final KyGanttChartDisplayOptions displayOptions;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected ? colorScheme.primary : task.color;

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel ?? '${task.title}, milestone',
      child: Tooltip(
        message: '${task.title} - milestone',
        waitDuration: const Duration(milliseconds: 350),
        child: Material(
          color: Colors.transparent,
          child: InkResponse(
            onTap: onTap,
            radius: size,
            child: Center(
              child: Transform.rotate(
                angle: math.pi / 4,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: task.color.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: borderColor,
                      width: selected ? 2.4 : 1.2,
                    ),
                    boxShadow: selected && displayOptions.showSelectedTaskFocus
                        ? kyGanttSelectedTaskFocusShadows(colorScheme)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
