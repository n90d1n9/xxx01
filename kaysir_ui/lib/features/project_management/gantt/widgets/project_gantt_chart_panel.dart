import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_filter_provider.dart';

class ProjectGanttChartPanel extends StatelessWidget {
  const ProjectGanttChartPanel({
    required this.tasks,
    required this.dateRange,
    required this.viewMode,
    required this.selectedTaskId,
    required this.onTaskSelected,
    this.collapsedTaskIds = const <String>{},
    this.onTaskCollapseToggled,
    this.projectNamesById = const {},
    this.displayOptions = const ky.KyGanttChartDisplayOptions(),
    this.interactionOptions = const ky.KyGanttChartInteractionOptions(),
    this.taskAvatarBuilder,
    this.taskDragPreviewBuilder,
    this.taskDateRangeValidator,
    this.onTaskDateRangeChanged,
    this.onTaskDateRangeChangeRejected,
    this.rowHeight = 58,
    this.headerHeight = 62,
    this.timelineScale = 1,
    this.emptyStateTitle = 'No gantt tasks',
    this.emptyStateMessage =
        'Try a different project, status, or saved timeline view.',
    this.emptyStateAction,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final DateTimeRange dateRange;
  final gantt.ViewMode viewMode;
  final String? selectedTaskId;
  final ValueChanged<String> onTaskSelected;
  final Set<String> collapsedTaskIds;
  final ValueChanged<String>? onTaskCollapseToggled;
  final Map<String, String> projectNamesById;
  final ky.KyGanttChartDisplayOptions displayOptions;
  final ky.KyGanttChartInteractionOptions interactionOptions;
  final ky.KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final ky.KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final ky.KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final ky.KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final ky.KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final double rowHeight;
  final double headerHeight;
  final double timelineScale;
  final String emptyStateTitle;
  final String? emptyStateMessage;
  final Widget? emptyStateAction;

  @override
  Widget build(BuildContext context) {
    final flatTasks = flattenGanttTaskTree(tasks);
    final selectedTask =
        selectedTaskId == null
            ? null
            : findGanttTaskById(flatTasks, selectedTaskId!);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (flatTasks.isEmpty) {
      return _ProjectGanttChartEmptyState(
        title: emptyStateTitle,
        message: emptyStateMessage,
        action: emptyStateAction,
      );
    }

    return ky.KyGanttChart(
      tasks: tasks,
      dateRange: dateRange,
      viewMode: _packageViewMode(viewMode),
      selectedTaskId: selectedTaskId,
      collapsedTaskIds: collapsedTaskIds,
      onTaskSelected: onTaskSelected,
      onTaskCollapseToggled: onTaskCollapseToggled,
      projectNameBuilder: (task) => projectNamesById[task.projectId],
      displayOptions: displayOptions,
      interactionOptions: interactionOptions,
      taskAvatarBuilder: taskAvatarBuilder,
      taskDragPreviewBuilder: taskDragPreviewBuilder,
      taskDateRangeValidator: taskDateRangeValidator,
      onTaskDateRangeChanged: onTaskDateRangeChanged,
      onTaskDateRangeChangeRejected: onTaskDateRangeChangeRejected,
      today: today,
      initialFocusDate: selectedTask?.startDate ?? today,
      dayWidth: _dayWidthFor(viewMode) * timelineScale.clamp(0.6, 1.6),
      rowHeight: rowHeight,
      headerHeight: headerHeight,
    );
  }

  ky.KyGanttViewMode _packageViewMode(gantt.ViewMode mode) {
    switch (mode) {
      case gantt.ViewMode.day:
        return ky.KyGanttViewMode.day;
      case gantt.ViewMode.week:
        return ky.KyGanttViewMode.week;
      case gantt.ViewMode.month:
        return ky.KyGanttViewMode.month;
      case gantt.ViewMode.quarter:
        return ky.KyGanttViewMode.quarter;
    }
  }

  double _dayWidthFor(gantt.ViewMode mode) {
    switch (mode) {
      case gantt.ViewMode.day:
        return 72;
      case gantt.ViewMode.week:
        return 42;
      case gantt.ViewMode.month:
        return 26;
      case gantt.ViewMode.quarter:
        return 18;
    }
  }
}

class _ProjectGanttChartEmptyState extends StatelessWidget {
  const _ProjectGanttChartEmptyState({
    required this.title,
    required this.message,
    required this.action,
  });

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 220 && constraints.maxWidth >= 560) {
          return _CompactGanttChartEmptyState(title: title, action: action);
        }

        final minHeight =
            constraints.hasBoundedHeight ? constraints.maxHeight : 0.0;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: AppEmptyState(
              icon: Icons.view_timeline_outlined,
              title: title,
              message: message,
              action: action,
            ),
          ),
        );
      },
    );
  }
}

class _CompactGanttChartEmptyState extends StatelessWidget {
  const _CompactGanttChartEmptyState({
    required this.title,
    required this.action,
  });

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.view_timeline_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: action!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
