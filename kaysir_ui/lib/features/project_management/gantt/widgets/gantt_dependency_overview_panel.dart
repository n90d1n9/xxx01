import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_overview_service.dart';
import '../services/gantt_dependency_service.dart';

class GanttDependencyOverviewPanel extends StatelessWidget {
  const GanttDependencyOverviewPanel({
    required this.tasks,
    required this.dependencyTasks,
    this.projectNamesById = const {},
    this.today,
    this.maxItems = 5,
    this.onTaskSelected,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask> dependencyTasks;
  final Map<String, String> projectNamesById;
  final DateTime? today;
  final int maxItems;
  final ValueChanged<String>? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final summary = buildGanttDependencyOverviewSummary(
      tasks: tasks,
      dependencyTasks: dependencyTasks,
      today: today,
    );

    if (summary.linkedCount == 0) {
      return const AppEmptyState(
        icon: Icons.link_off_rounded,
        title: 'No dependency links',
        message: 'Linked tasks will appear here once the roadmap has blockers.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleItems = summary.prioritizedItems.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Dependencies ${summary.signal.label}',
          subtitle:
              '${summary.linkedCount} linked tasks - ${summary.attentionCount} need attention',
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.label,
            icon: summary.signal.icon,
            color: signalColor,
            maxWidth: 130,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Alerts',
              value: summary.alertCount.toString(),
              icon: Icons.report_problem_outlined,
              accentColor:
                  summary.alertCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Waiting',
              value: summary.waitingCount.toString(),
              icon: GanttDependencyHealth.waiting.icon,
              accentColor:
                  summary.waitingCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: GanttDependencyHealth.ready.icon,
              accentColor: Colors.green.shade700,
            ),
            AppMetricGridItem(
              title: 'Linked',
              value: summary.linkedCount.toString(),
              icon: Icons.link_rounded,
              accentColor: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _GanttDependencyOverviewRow(
            item: visibleItems[index],
            projectName: projectNamesById[visibleItems[index].task.projectId],
            onTaskSelected:
                onTaskSelected == null
                    ? null
                    : () => onTaskSelected!(visibleItems[index].task.id),
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GanttDependencyOverviewRow extends StatelessWidget {
  const _GanttDependencyOverviewRow({
    required this.item,
    required this.projectName,
    required this.onTaskSelected,
  });

  final GanttDependencyOverviewItem item;
  final String? projectName;
  final VoidCallback? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = item.insight.health.color(colorScheme);

    return AppInfoRow(
      title: item.task.title,
      subtitle: [
        if (projectName != null) projectName!,
        ganttDependencyOverviewDetail(item),
      ].join(' - '),
      icon: item.insight.health.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: healthColor.withValues(alpha: 0.12),
      iconForegroundColor: healthColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: item.insight.health.label,
            icon: item.insight.health.icon,
            color: healthColor,
            maxWidth: 118,
          ),
          if (onTaskSelected != null)
            AppActionButton(
              label: 'Inspect',
              icon: Icons.manage_search_outlined,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onTaskSelected,
            ),
        ],
      ),
    );
  }
}
