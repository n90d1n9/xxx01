import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_service.dart';
import '../services/gantt_schedule_health_service.dart';
import '../states/gantt_filter_provider.dart';

class GanttOverviewSummaryGrid extends StatelessWidget {
  const GanttOverviewSummaryGrid({
    required this.tasks,
    required this.dateRange,
    this.dependencyTasks,
    this.today,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final DateTimeRange dateRange;
  final List<gantt.GanttTask>? dependencyTasks;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flatTasks = flattenGanttTasks(tasks);
    final totalTasks = flatTasks.length;
    final averageProgress =
        flatTasks.isEmpty
            ? 0
            : flatTasks.fold<double>(0, (sum, task) => sum + task.progress) /
                flatTasks.length;
    final dependentCount =
        flatTasks.where((task) => task.dependsOn != null).length;
    final dependencyAlertCount = ganttDependencyAlertCount(
      tasks,
      dependencyTasks ?? tasks,
      today: today,
    );
    final activeCount =
        flatTasks.where((task) => _isActiveInRange(task, dateRange)).length;
    final scheduleAlertCount =
        flatTasks.where((task) {
          final health = ganttScheduleHealthFor(task, today: today);
          return health == GanttScheduleHealth.overdue ||
              health == GanttScheduleHealth.dueSoon;
        }).length;

    return AppMetricGrid(
      minTileWidth: 180,
      metrics: [
        AppMetricGridItem(
          title: 'Timeline Tasks',
          value: totalTasks.toString(),
          icon: Icons.account_tree_outlined,
          accentColor: colorScheme.primary,
        ),
        AppMetricGridItem(
          title: 'Average Progress',
          value: '${(averageProgress * 100).round()}%',
          icon: Icons.trending_up_rounded,
          accentColor: Colors.green.shade700,
        ),
        AppMetricGridItem(
          title: 'Active In Range',
          value: activeCount.toString(),
          icon: Icons.calendar_month_outlined,
          accentColor: Colors.indigo.shade600,
        ),
        AppMetricGridItem(
          title: 'Schedule Alerts',
          value: scheduleAlertCount.toString(),
          icon: Icons.event_busy_outlined,
          accentColor:
              scheduleAlertCount == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Dependency Alerts',
          value: dependencyAlertCount.toString(),
          helper: '$dependentCount linked',
          icon: Icons.link_rounded,
          accentColor:
              dependencyAlertCount == 0
                  ? Colors.green.shade700
                  : colorScheme.error,
        ),
      ],
    );
  }
}

class GanttRoadmapPanel extends StatelessWidget {
  const GanttRoadmapPanel({
    required this.tasks,
    required this.selectedTaskId,
    required this.onTaskSelected,
    this.dependencyTasks,
    this.projectNamesById = const {},
    this.today,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final String? selectedTaskId;
  final ValueChanged<String> onTaskSelected;
  final List<gantt.GanttTask>? dependencyTasks;
  final Map<String, String> projectNamesById;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final flatTasks = flattenGanttTasks(tasks);
    final resolvedDependencyTasks = dependencyTasks ?? tasks;

    if (flatTasks.isEmpty) {
      return const AppEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No timeline tasks',
        message: 'Try a different task search.',
      );
    }

    return Column(
      children: [
        for (var index = 0; index < flatTasks.length; index++) ...[
          GanttRoadmapTaskTile(
            task: flatTasks[index],
            isSelected: flatTasks[index].id == selectedTaskId,
            onTap: () => onTaskSelected(flatTasks[index].id),
            projectName: projectNamesById[flatTasks[index].projectId],
            dependencyTasks: resolvedDependencyTasks,
            today: today,
          ),
          if (index != flatTasks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class GanttRoadmapTaskTile extends StatelessWidget {
  const GanttRoadmapTaskTile({
    required this.task,
    required this.isSelected,
    required this.onTap,
    this.dependencyTasks = const [],
    this.projectName,
    this.today,
    super.key,
  });

  final gantt.GanttTask task;
  final bool isSelected;
  final VoidCallback onTap;
  final List<gantt.GanttTask> dependencyTasks;
  final String? projectName;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');
    final status = _statusFor(task);
    final statusColor = _statusColor(context, status);
    final scheduleHealth = ganttScheduleHealthFor(task, today: today);
    final scheduleColor = scheduleHealth.color(colorScheme);
    final dependencyInsight = ganttDependencyInsightFor(
      task,
      dependencyTasks,
      today: today,
    );

    return Material(
      color:
          isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.56)
              : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIconBadge(
                    icon: Icons.timeline_outlined,
                    size: 40,
                    backgroundColor: task.color.withValues(alpha: 0.14),
                    foregroundColor: task.color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            '${dateFormat.format(task.startDate)} - ${dateFormat.format(task.endDate)}',
                            if (projectName != null) projectName!,
                          ].join(' - '),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppStatusPill(
                    label: status,
                    icon: _statusIcon(status),
                    color: statusColor,
                    maxWidth: 130,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: task.progress.clamp(0, 1),
                  color: task.color,
                  backgroundColor: task.color.withValues(alpha: 0.14),
                ),
              ),
              const SizedBox(height: 10),
              AppInfoRow(
                title: '${(task.progress * 100).round()}% complete',
                subtitle:
                    '${task.endDate.difference(task.startDate).inDays + 1} days - ${ganttScheduleHealthDetail(task, today: today)}${dependencyInsight.health == GanttDependencyHealth.independent ? '' : ' - ${dependencyInsight.detail}'}',
                icon: Icons.schedule_outlined,
                iconStyle: AppInfoRowIconStyle.badge,
                contained: true,
                iconBackgroundColor: scheduleColor.withValues(alpha: 0.12),
                iconForegroundColor: scheduleColor,
                trailing: AppStatusPill(
                  label: scheduleHealth.label,
                  icon: scheduleHealth.icon,
                  color: scheduleColor,
                  maxWidth: 130,
                ),
                subtitleMaxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<gantt.GanttTask> flattenGanttTasks(List<gantt.GanttTask> tasks) {
  return flattenGanttTaskTree(tasks);
}

bool _isActiveInRange(gantt.GanttTask task, DateTimeRange range) {
  return !task.endDate.isBefore(range.start) &&
      !task.startDate.isAfter(range.end);
}

String _statusFor(gantt.GanttTask task) {
  return ganttTaskStatusFor(task).label;
}

IconData _statusIcon(String status) {
  return _statusFilterForLabel(status).icon;
}

Color _statusColor(BuildContext context, String status) {
  return _statusFilterForLabel(status).color(Theme.of(context).colorScheme);
}

GanttTaskStatusFilter _statusFilterForLabel(String status) {
  return GanttTaskStatusFilter.values.firstWhere(
    (filter) => filter.label == status,
    orElse: () => GanttTaskStatusFilter.inProgress,
  );
}
