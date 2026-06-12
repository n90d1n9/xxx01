import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_dependency_service.dart';
import '../services/gantt_schedule_health_service.dart';
import '../services/gantt_task_inspector_summary_service.dart';
import 'gantt_task_dependency_editor.dart';

class GanttTaskInspectorReadinessSection extends StatelessWidget {
  const GanttTaskInspectorReadinessSection({
    required this.task,
    required this.summary,
    required this.dependencyTasks,
    this.dependencyTitle,
    this.onDependencyChanged,
    super.key,
  });

  final gantt.GanttTask task;
  final GanttTaskInspectorSummary summary;
  final List<gantt.GanttTask> dependencyTasks;
  final String? dependencyTitle;
  final ValueChanged<String?>? onDependencyChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scheduleColor = summary.scheduleHealth.color(colorScheme);
    final dependencyColor = summary.dependencyInsight.health.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Schedule Health',
          subtitle: '${summary.scheduleRangeLabel} - ${summary.scheduleDetail}',
          icon: summary.scheduleHealth.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: scheduleColor.withValues(alpha: 0.12),
          iconForegroundColor: scheduleColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 10),
        GanttTaskDependencyEditor(
          task: task,
          dependencyTasks: dependencyTasks,
          dependencyTitle: dependencyTitle,
          onDependencyChanged: onDependencyChanged,
        ),
        const SizedBox(height: 10),
        AppInfoRow(
          title: 'Dependency Readiness',
          subtitle: summary.dependencyInsight.detail,
          icon: summary.dependencyInsight.health.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: dependencyColor.withValues(alpha: 0.12),
          iconForegroundColor: dependencyColor,
          titleMaxLines: 1,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: summary.dependencyInsight.health.label,
            icon: summary.dependencyInsight.health.icon,
            color: dependencyColor,
            maxWidth: 130,
          ),
        ),
      ],
    );
  }
}
