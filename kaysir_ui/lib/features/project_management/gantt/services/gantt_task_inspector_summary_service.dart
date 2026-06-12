import 'package:intl/intl.dart';

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_filter_provider.dart';
import 'gantt_dependency_service.dart';
import 'gantt_schedule_health_service.dart';

class GanttTaskInspectorSummary {
  const GanttTaskInspectorSummary({
    required this.status,
    required this.scheduleHealth,
    required this.dependencyInsight,
    required this.progressValue,
    required this.durationValue,
    required this.dueValue,
    required this.scheduleRangeLabel,
    required this.scheduleDetail,
    required this.durationDays,
  });

  final GanttTaskStatusFilter status;
  final GanttScheduleHealth scheduleHealth;
  final GanttDependencyInsight dependencyInsight;
  final String progressValue;
  final String durationValue;
  final String dueValue;
  final String scheduleRangeLabel;
  final String scheduleDetail;
  final int durationDays;

  bool get hasVisibleDependencyStatus =>
      dependencyInsight.health != GanttDependencyHealth.independent;
}

class GanttTaskInspectorSummaryService {
  const GanttTaskInspectorSummaryService();

  GanttTaskInspectorSummary build({
    required gantt.GanttTask task,
    required List<gantt.GanttTask> dependencyTasks,
    DateTime? today,
    String? fallbackDependencyTitle,
  }) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final scheduleHealth = ganttScheduleHealthFor(task, today: today);
    final dependencyInsight = ganttDependencyInsightFor(
      task,
      dependencyTasks,
      today: today,
      fallbackDependencyTitle: fallbackDependencyTitle,
    );

    return GanttTaskInspectorSummary(
      status: ganttTaskStatusFor(task),
      scheduleHealth: scheduleHealth,
      dependencyInsight: dependencyInsight,
      progressValue: '${(task.progress * 100).round()}%',
      durationValue: '${task.durationDays} d',
      dueValue: ganttScheduleDueLabel(task, today: today),
      scheduleRangeLabel:
          '${dateFormat.format(task.startDate)} - '
          '${dateFormat.format(task.endDate)}',
      scheduleDetail: ganttScheduleHealthDetail(task, today: today),
      durationDays: task.durationDays,
    );
  }
}
