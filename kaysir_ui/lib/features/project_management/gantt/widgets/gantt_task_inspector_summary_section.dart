import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_icon_badge.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_service.dart';
import '../services/gantt_schedule_health_service.dart';
import '../services/gantt_task_inspector_summary_service.dart';
import '../states/gantt_filter_provider.dart';

class GanttTaskInspectorSummarySection extends StatelessWidget {
  const GanttTaskInspectorSummarySection({
    required this.task,
    required this.summary,
    this.projectName,
    super.key,
  });

  final gantt.GanttTask task;
  final GanttTaskInspectorSummary summary;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = summary.status.color(colorScheme);
    final scheduleColor = summary.scheduleHealth.color(colorScheme);
    final dependencyColor = summary.dependencyInsight.health.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(
              icon:
                  task.isMilestone
                      ? Icons.diamond_outlined
                      : Icons.timeline_outlined,
              size: 44,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppStatusPill(
                        label: summary.status.label,
                        icon: summary.status.icon,
                        color: statusColor,
                        tooltip: '${summary.progressValue} complete',
                      ),
                      AppStatusPill(
                        label: summary.scheduleHealth.label,
                        icon: summary.scheduleHealth.icon,
                        color: scheduleColor,
                        tooltip: summary.scheduleDetail,
                      ),
                      if (summary.hasVisibleDependencyStatus)
                        AppStatusPill(
                          label: summary.dependencyInsight.health.label,
                          icon: summary.dependencyInsight.health.icon,
                          color: dependencyColor,
                          tooltip: summary.dependencyInsight.detail,
                        ),
                      if (projectName != null)
                        AppStatusPill(
                          label: projectName!,
                          icon: Icons.workspaces_outline,
                          color: colorScheme.primary,
                          maxWidth: 220,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppMetricGrid(
          minTileWidth: 130,
          metrics: [
            AppMetricGridItem(
              title: 'Progress',
              value: summary.progressValue,
              icon: Icons.trending_up_rounded,
              accentColor: task.color,
            ),
            AppMetricGridItem(
              title: 'Duration',
              value: summary.durationValue,
              icon:
                  task.isMilestone
                      ? Icons.diamond_outlined
                      : Icons.date_range_outlined,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: 'Due',
              value: summary.dueValue,
              icon: summary.scheduleHealth.icon,
              accentColor: scheduleColor,
            ),
          ],
        ),
      ],
    );
  }
}
