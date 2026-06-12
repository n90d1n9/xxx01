import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_baseline_variance_service.dart';
import 'gantt_schedule_health_service.dart';

enum GanttScheduleFocusLevel { critical, warning, monitor, clear }

class GanttScheduleFocusItem {
  const GanttScheduleFocusItem({
    required this.task,
    required this.level,
    required this.health,
    required this.variance,
    required this.reason,
    required this.action,
  });

  final gantt.GanttTask task;
  final GanttScheduleFocusLevel level;
  final GanttScheduleHealth health;
  final GanttBaselineVariance variance;
  final String reason;
  final String action;
}

class GanttScheduleFocusSummary {
  const GanttScheduleFocusSummary({
    required this.totalTasks,
    required this.items,
  });

  final int totalTasks;
  final List<GanttScheduleFocusItem> items;

  int get focusCount => items.length;

  int get criticalCount {
    return items.where((item) {
      return item.level == GanttScheduleFocusLevel.critical;
    }).length;
  }

  int get warningCount {
    return items.where((item) {
      return item.level == GanttScheduleFocusLevel.warning;
    }).length;
  }

  int get monitorCount {
    return items.where((item) {
      return item.level == GanttScheduleFocusLevel.monitor;
    }).length;
  }

  int get overdueCount {
    return items.where((item) {
      return item.health == GanttScheduleHealth.overdue ||
          item.variance.state == GanttBaselineVarianceState.late;
    }).length;
  }

  int get behindCount {
    return items.where((item) {
      return item.variance.state == GanttBaselineVarianceState.behind;
    }).length;
  }

  int get startingSoonCount {
    return items.where((item) {
      return item.health == GanttScheduleHealth.dueSoon;
    }).length;
  }

  GanttScheduleFocusLevel get level {
    if (criticalCount > 0) return GanttScheduleFocusLevel.critical;
    if (warningCount > 0) return GanttScheduleFocusLevel.warning;
    if (monitorCount > 0) return GanttScheduleFocusLevel.monitor;
    return GanttScheduleFocusLevel.clear;
  }

  List<GanttScheduleFocusItem> get prioritizedItems {
    final sorted = [...items]..sort(_compareFocusItems);
    return List.unmodifiable(sorted);
  }
}

extension GanttScheduleFocusLevelPresentation on GanttScheduleFocusLevel {
  String get label {
    switch (this) {
      case GanttScheduleFocusLevel.critical:
        return 'Critical';
      case GanttScheduleFocusLevel.warning:
        return 'Watch';
      case GanttScheduleFocusLevel.monitor:
        return 'Monitor';
      case GanttScheduleFocusLevel.clear:
        return 'Clear';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttScheduleFocusLevel.critical:
        return Icons.crisis_alert_outlined;
      case GanttScheduleFocusLevel.warning:
        return Icons.report_problem_outlined;
      case GanttScheduleFocusLevel.monitor:
        return Icons.radar_outlined;
      case GanttScheduleFocusLevel.clear:
        return Icons.check_circle_outline;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttScheduleFocusLevel.critical:
        return colorScheme.error;
      case GanttScheduleFocusLevel.warning:
        return Colors.orange.shade700;
      case GanttScheduleFocusLevel.monitor:
        return colorScheme.primary;
      case GanttScheduleFocusLevel.clear:
        return Colors.green.shade700;
    }
  }
}

GanttScheduleFocusSummary buildGanttScheduleFocusSummary({
  required List<gantt.GanttTask> tasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(tasks);
  final items = [
    for (final task in flatTasks)
      if (_focusItemFor(task, today: today) case final item?) item,
  ];

  return GanttScheduleFocusSummary(
    totalTasks: flatTasks.length,
    items: List.unmodifiable(items),
  );
}

String ganttScheduleFocusDetail(GanttScheduleFocusItem item) {
  return '${item.reason} - ${item.action}';
}

GanttScheduleFocusItem? _focusItemFor(gantt.GanttTask task, {DateTime? today}) {
  if (task.progress >= 1) return null;

  final health = ganttScheduleHealthFor(task, today: today);
  final variance = ganttBaselineVarianceFor(task, today: today);

  if (health == GanttScheduleHealth.overdue ||
      variance.state == GanttBaselineVarianceState.late) {
    return GanttScheduleFocusItem(
      task: task,
      level: GanttScheduleFocusLevel.critical,
      health: health,
      variance: variance,
      reason: ganttScheduleHealthDetail(task, today: today),
      action:
          'Reset finish plan or clear the blocking owner before checkpoint.',
    );
  }

  if (variance.state == GanttBaselineVarianceState.behind) {
    return GanttScheduleFocusItem(
      task: task,
      level: GanttScheduleFocusLevel.warning,
      health: health,
      variance: variance,
      reason: '${variance.variancePoints.abs()} pts behind baseline',
      action: 'Recover pace or resequence dependent work this week.',
    );
  }

  if (health == GanttScheduleHealth.dueSoon && task.progress <= 0) {
    return GanttScheduleFocusItem(
      task: task,
      level: GanttScheduleFocusLevel.monitor,
      health: health,
      variance: variance,
      reason: ganttScheduleHealthDetail(task, today: today),
      action: 'Confirm start readiness and owner handoff.',
    );
  }

  return null;
}

int _compareFocusItems(
  GanttScheduleFocusItem left,
  GanttScheduleFocusItem right,
) {
  final levelCompare = _levelRank(
    left.level,
  ).compareTo(_levelRank(right.level));
  if (levelCompare != 0) return levelCompare;

  final endCompare = left.task.endDate.compareTo(right.task.endDate);
  if (endCompare != 0) return endCompare;

  return left.task.title.compareTo(right.task.title);
}

int _levelRank(GanttScheduleFocusLevel level) {
  switch (level) {
    case GanttScheduleFocusLevel.critical:
      return 0;
    case GanttScheduleFocusLevel.warning:
      return 1;
    case GanttScheduleFocusLevel.monitor:
      return 2;
    case GanttScheduleFocusLevel.clear:
      return 3;
  }
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}
