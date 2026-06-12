import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_schedule_health_service.dart';
import '../services/project_timeline_health_service.dart';
import 'project_timeline_health_issue_list.dart';

class ProjectTimelineHealthPanel extends StatelessWidget {
  const ProjectTimelineHealthPanel({
    required this.tasks,
    this.dependencyTasks,
    this.maxIssues = 5,
    this.today,
    this.onTaskFocus,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask>? dependencyTasks;
  final int maxIssues;
  final DateTime? today;
  final ValueChanged<gantt.GanttTask>? onTaskFocus;

  @override
  Widget build(BuildContext context) {
    final rollup = buildProjectTimelineHealthRollup(
      tasks: tasks,
      dependencyTasks: dependencyTasks,
      today: today,
    );

    if (rollup.totalTasks == 0) {
      return const AppEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No timeline health yet',
        message: 'Linked Gantt tasks will roll up into this health summary.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = rollup.signal.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Timeline ${rollup.signal.label}',
          subtitle:
              '${rollup.totalTasks} linked tasks - ${(rollup.averageProgress * 100).round()}% average progress',
          icon: rollup.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: rollup.signal.label,
            icon: rollup.signal.icon,
            color: signalColor,
            maxWidth: 130,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 3,
          metrics: [
            AppMetricGridItem(
              title: GanttScheduleHealth.overdue.label,
              value: rollup.overdueCount.toString(),
              icon: GanttScheduleHealth.overdue.icon,
              accentColor:
                  rollup.overdueCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: GanttScheduleHealth.active.label,
              value: rollup.activeCount.toString(),
              icon: GanttScheduleHealth.active.icon,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: GanttScheduleHealth.dueSoon.label,
              value: rollup.dueSoonCount.toString(),
              icon: GanttScheduleHealth.dueSoon.icon,
              accentColor:
                  rollup.dueSoonCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Dependency Blocks',
              value: rollup.dependencyBlockCount.toString(),
              icon: Icons.block_outlined,
              accentColor:
                  rollup.dependencyBlockCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: GanttScheduleHealth.complete.label,
              value: rollup.completeCount.toString(),
              icon: GanttScheduleHealth.complete.icon,
              accentColor: Colors.green.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ProjectTimelineHealthIssueList(
          issues: rollup.issues,
          maxItems: maxIssues,
          today: today,
          onTaskFocus: onTaskFocus,
        ),
      ],
    );
  }
}
