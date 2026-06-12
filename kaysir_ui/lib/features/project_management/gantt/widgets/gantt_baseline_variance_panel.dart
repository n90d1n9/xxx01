import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_baseline_variance_service.dart';

class GanttBaselineVariancePanel extends StatelessWidget {
  const GanttBaselineVariancePanel({
    required this.tasks,
    this.projectNamesById = const {},
    this.today,
    this.maxItems = 5,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final Map<String, String> projectNamesById;
  final DateTime? today;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final summary = buildGanttBaselineVarianceSummary(
      tasks: tasks,
      today: today,
    );

    if (summary.totalTasks == 0) {
      return const AppEmptyState(
        icon: Icons.stacked_line_chart_outlined,
        title: 'No baseline variance yet',
        message: 'Timeline tasks will appear here once a schedule is linked.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleItems = summary.prioritizedItems.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Baseline ${summary.signal.label}',
          subtitle:
              '${summary.totalTasks} tasks tracked - ${_signedPoints(summary.averageVariancePoints)} avg variance',
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
              title: 'Behind',
              value: summary.behindCount.toString(),
              icon: GanttBaselineVarianceState.behind.icon,
              accentColor:
                  summary.behindCount == 0
                      ? Colors.green.shade700
                      : GanttBaselineVarianceState.behind.color(colorScheme),
            ),
            AppMetricGridItem(
              title: 'Late',
              value: summary.lateCount.toString(),
              icon: GanttBaselineVarianceState.late.icon,
              accentColor:
                  summary.lateCount == 0
                      ? Colors.green.shade700
                      : GanttBaselineVarianceState.late.color(colorScheme),
            ),
            AppMetricGridItem(
              title: 'Ahead',
              value: summary.aheadCount.toString(),
              icon: GanttBaselineVarianceState.ahead.icon,
              accentColor: GanttBaselineVarianceState.ahead.color(colorScheme),
            ),
            AppMetricGridItem(
              title: 'Avg Variance',
              value: _signedPoints(summary.averageVariancePoints),
              icon: Icons.speed_outlined,
              accentColor:
                  summary.averageVariancePoints < -8
                      ? Colors.orange.shade700
                      : colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _GanttBaselineVarianceRow(
            variance: visibleItems[index],
            projectName: projectNamesById[visibleItems[index].task.projectId],
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _signedPoints(int points) {
    if (points == 0) return '0 pts';
    return '${points > 0 ? '+' : ''}$points pts';
  }
}

class _GanttBaselineVarianceRow extends StatelessWidget {
  const _GanttBaselineVarianceRow({
    required this.variance,
    required this.projectName,
  });

  final GanttBaselineVariance variance;
  final String? projectName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = variance.state.color(colorScheme);

    return AppInfoRow(
      title: variance.task.title,
      subtitle: [
        if (projectName != null) projectName!,
        ganttBaselineVarianceDetail(variance),
      ].join(' - '),
      icon: variance.state.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: stateColor.withValues(alpha: 0.12),
      iconForegroundColor: stateColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: AppStatusPill(
        label: variance.state.label,
        icon: variance.state.icon,
        color: stateColor,
        maxWidth: 130,
      ),
    );
  }
}
