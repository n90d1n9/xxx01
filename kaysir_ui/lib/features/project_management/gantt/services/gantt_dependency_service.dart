import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_schedule_health_service.dart';

enum GanttDependencyHealth { independent, ready, waiting, blocked, missing }

class GanttDependencyInsight {
  const GanttDependencyInsight({
    required this.health,
    required this.title,
    required this.detail,
    this.dependencyTask,
  });

  final GanttDependencyHealth health;
  final String title;
  final String detail;
  final gantt.GanttTask? dependencyTask;

  bool get isAlert =>
      health == GanttDependencyHealth.blocked ||
      health == GanttDependencyHealth.missing;
}

extension GanttDependencyHealthPresentation on GanttDependencyHealth {
  String get label {
    switch (this) {
      case GanttDependencyHealth.independent:
        return 'Independent';
      case GanttDependencyHealth.ready:
        return 'Ready';
      case GanttDependencyHealth.waiting:
        return 'Waiting';
      case GanttDependencyHealth.blocked:
        return 'Blocked';
      case GanttDependencyHealth.missing:
        return 'Missing';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttDependencyHealth.independent:
        return Icons.link_off_rounded;
      case GanttDependencyHealth.ready:
        return Icons.check_circle_outline;
      case GanttDependencyHealth.waiting:
        return Icons.pending_actions_outlined;
      case GanttDependencyHealth.blocked:
        return Icons.block_outlined;
      case GanttDependencyHealth.missing:
        return Icons.report_problem_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttDependencyHealth.independent:
        return colorScheme.onSurfaceVariant;
      case GanttDependencyHealth.ready:
        return Colors.green.shade700;
      case GanttDependencyHealth.waiting:
        return Colors.orange.shade700;
      case GanttDependencyHealth.blocked:
      case GanttDependencyHealth.missing:
        return colorScheme.error;
    }
  }
}

GanttDependencyInsight ganttDependencyInsightFor(
  gantt.GanttTask task,
  List<gantt.GanttTask> dependencyTasks, {
  DateTime? today,
  String? fallbackDependencyTitle,
}) {
  final dependencyId = task.dependsOn?.trim();
  if (dependencyId == null || dependencyId.isEmpty) {
    return const GanttDependencyInsight(
      health: GanttDependencyHealth.independent,
      title: 'Independent task',
      detail: 'No predecessor blocks this task.',
    );
  }

  final dependency = _findTaskById(
    _flattenTasks(dependencyTasks),
    dependencyId,
  );
  final dependencyLabel = fallbackDependencyTitle ?? 'Task $dependencyId';

  if (dependency == null) {
    return GanttDependencyInsight(
      health: GanttDependencyHealth.missing,
      title: 'Missing dependency',
      detail: '$dependencyLabel is not available in this roadmap.',
    );
  }

  if (dependency.progress >= 1) {
    return GanttDependencyInsight(
      health: GanttDependencyHealth.ready,
      title: dependency.title,
      detail: '${dependency.title} is complete; this task can proceed.',
      dependencyTask: dependency,
    );
  }

  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final taskStart = DateUtils.dateOnly(task.startDate);
  final dependencyHealth = ganttScheduleHealthFor(dependency, today: asOf);

  if (dependencyHealth == GanttScheduleHealth.overdue ||
      !taskStart.isAfter(asOf)) {
    return GanttDependencyInsight(
      health: GanttDependencyHealth.blocked,
      title: dependency.title,
      detail: '${dependency.title} is incomplete and now blocks this task.',
      dependencyTask: dependency,
    );
  }

  return GanttDependencyInsight(
    health: GanttDependencyHealth.waiting,
    title: dependency.title,
    detail:
        'Waiting for ${dependency.title}; ${ganttScheduleHealthDetail(dependency, today: asOf).toLowerCase()}.',
    dependencyTask: dependency,
  );
}

int ganttDependencyAlertCount(
  List<gantt.GanttTask> tasks,
  List<gantt.GanttTask> dependencyTasks, {
  DateTime? today,
}) {
  return _flattenTasks(tasks)
      .where(
        (task) =>
            ganttDependencyInsightFor(
              task,
              dependencyTasks,
              today: today,
            ).isAlert,
      )
      .length;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}

gantt.GanttTask? _findTaskById(List<gantt.GanttTask> tasks, String taskId) {
  for (final task in tasks) {
    if (task.id == taskId) return task;
  }
  return null;
}
