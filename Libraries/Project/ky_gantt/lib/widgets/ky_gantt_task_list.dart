import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import '../utils/gantt_task_tree.dart';

typedef KyGanttProjectNameBuilder = String? Function(GanttTask task);

class KyGanttTaskList extends StatelessWidget {
  const KyGanttTaskList({
    required this.nodes,
    required this.rowHeight,
    required this.selectedTaskId,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.onTaskSelected,
    this.onTaskCollapseToggled,
    this.projectNameBuilder,
    super.key,
  });

  final List<GanttTaskNode> nodes;
  final double rowHeight;
  final String? selectedTaskId;
  final KyGanttChartDisplayOptions displayOptions;
  final ValueChanged<String>? onTaskSelected;
  final ValueChanged<String>? onTaskCollapseToggled;
  final KyGanttProjectNameBuilder? projectNameBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final node in nodes)
          KyGanttTaskListRow(
            key: ValueKey('ky-gantt-task-list-row-${node.task.id}'),
            node: node,
            height: rowHeight,
            selected: node.task.id == selectedTaskId,
            displayOptions: displayOptions,
            projectName: projectNameBuilder?.call(node.task),
            onTap: onTaskSelected == null
                ? null
                : () => onTaskSelected!(node.task.id),
            onToggleCollapsed: onTaskCollapseToggled == null
                ? null
                : () => onTaskCollapseToggled!(node.task.id),
          ),
      ],
    );
  }
}

class KyGanttTaskListRow extends StatelessWidget {
  const KyGanttTaskListRow({
    required this.node,
    required this.height,
    required this.selected,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.projectName,
    this.onTap,
    this.onToggleCollapsed,
    super.key,
  });

  final GanttTaskNode node;
  final double height;
  final bool selected;
  final KyGanttChartDisplayOptions displayOptions;
  final String? projectName;
  final VoidCallback? onTap;
  final VoidCallback? onToggleCollapsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final task = node.task;
    final trailingLabel = task.isMilestone
        ? 'Milestone'
        : '${(task.progress.clamp(0, 1) * 100).round()}%';
    final selectedHighlightColor =
        displayOptions.selectedTaskRowHighlightColor ?? colorScheme.primary;
    final selectedBackgroundOpacity =
        (displayOptions.selectedTaskRowHighlightOpacity * 1.8)
            .clamp(0.08, 0.22)
            .toDouble();

    return Material(
      color: selected
          ? displayOptions.showSelectedTaskRowHighlight
              ? selectedHighlightColor.withValues(
                  alpha: selectedBackgroundOpacity,
                )
              : colorScheme.surface
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsetsDirectional.only(
            start: 8 + (node.depth * 18),
            end: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
              right: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              _KyGanttTaskTreeToggle(
                task: task,
                collapsed: node.collapsed,
                enabled: onToggleCollapsed != null,
                onPressed: node.hasChildren ? onToggleCollapsed : null,
              ),
              const SizedBox(width: 4),
              _KyGanttTaskListLeadingMark(task: task),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w700,
                          ),
                    ),
                    if (projectName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        projectName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: task.isMilestone ? 64 : 40,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    trailingLabel,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskTreeToggle extends StatelessWidget {
  const _KyGanttTaskTreeToggle({
    required this.task,
    required this.collapsed,
    required this.enabled,
    required this.onPressed,
  });

  final GanttTask task;
  final bool collapsed;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (task.subtasks.isEmpty) return const SizedBox(width: 24, height: 28);

    final tooltip =
        collapsed ? 'Expand ${task.title}' : 'Collapse ${task.title}';

    return Tooltip(
      message: tooltip,
      child: IconButton(
        key: ValueKey('ky-gantt-task-collapse-toggle-${task.id}'),
        onPressed: enabled ? onPressed : null,
        constraints: const BoxConstraints.tightFor(width: 28, height: 28),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        color: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
        icon: Icon(
          collapsed
              ? Icons.keyboard_arrow_right_rounded
              : Icons.keyboard_arrow_down_rounded,
        ),
      ),
    );
  }
}

class _KyGanttTaskListLeadingMark extends StatelessWidget {
  const _KyGanttTaskListLeadingMark({required this.task});

  final GanttTask task;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: task.color,
        borderRadius: BorderRadius.circular(task.isMilestone ? 2 : 3),
      ),
    );

    if (!task.isMilestone) return mark;

    return Transform.rotate(
      angle: math.pi / 4,
      child: mark,
    );
  }
}
