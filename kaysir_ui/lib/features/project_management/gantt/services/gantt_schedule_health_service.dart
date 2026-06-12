import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;

enum GanttScheduleHealth { complete, overdue, active, dueSoon, scheduled }

extension GanttScheduleHealthPresentation on GanttScheduleHealth {
  String get label {
    switch (this) {
      case GanttScheduleHealth.complete:
        return 'Complete';
      case GanttScheduleHealth.overdue:
        return 'Overdue';
      case GanttScheduleHealth.active:
        return 'Active';
      case GanttScheduleHealth.dueSoon:
        return 'Due Soon';
      case GanttScheduleHealth.scheduled:
        return 'Scheduled';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttScheduleHealth.complete:
        return Icons.check_circle_outline;
      case GanttScheduleHealth.overdue:
        return Icons.event_busy_outlined;
      case GanttScheduleHealth.active:
        return Icons.play_circle_outline_rounded;
      case GanttScheduleHealth.dueSoon:
        return Icons.upcoming_outlined;
      case GanttScheduleHealth.scheduled:
        return Icons.event_available_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttScheduleHealth.complete:
        return Colors.green.shade700;
      case GanttScheduleHealth.overdue:
        return colorScheme.error;
      case GanttScheduleHealth.active:
        return colorScheme.primary;
      case GanttScheduleHealth.dueSoon:
        return Colors.orange.shade700;
      case GanttScheduleHealth.scheduled:
        return Colors.indigo.shade600;
    }
  }
}

GanttScheduleHealth ganttScheduleHealthFor(
  gantt.GanttTask task, {
  DateTime? today,
  int dueSoonDays = 7,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final start = DateUtils.dateOnly(task.startDate);
  final end = DateUtils.dateOnly(task.endDate);

  if (task.progress >= 1) return GanttScheduleHealth.complete;
  if (end.isBefore(asOf)) return GanttScheduleHealth.overdue;
  if (!start.isAfter(asOf) && !end.isBefore(asOf)) {
    return GanttScheduleHealth.active;
  }
  if (start.difference(asOf).inDays <= dueSoonDays) {
    return GanttScheduleHealth.dueSoon;
  }
  return GanttScheduleHealth.scheduled;
}

String ganttScheduleHealthDetail(
  gantt.GanttTask task, {
  DateTime? today,
  int dueSoonDays = 7,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final start = DateUtils.dateOnly(task.startDate);
  final end = DateUtils.dateOnly(task.endDate);
  final health = ganttScheduleHealthFor(
    task,
    today: asOf,
    dueSoonDays: dueSoonDays,
  );

  switch (health) {
    case GanttScheduleHealth.complete:
      return 'Completed';
    case GanttScheduleHealth.overdue:
      return _pluralDays(asOf.difference(end).inDays, 'overdue');
    case GanttScheduleHealth.active:
      final remainingDays = end.difference(asOf).inDays;
      return remainingDays <= 0
          ? 'Due today'
          : _pluralDays(remainingDays, 'remaining');
    case GanttScheduleHealth.dueSoon:
      final startInDays = start.difference(asOf).inDays;
      return startInDays <= 0
          ? 'Starts today'
          : 'Starts in ${_pluralDays(startInDays, '')}'.trim();
    case GanttScheduleHealth.scheduled:
      return 'Starts in ${_pluralDays(start.difference(asOf).inDays, '')}'
          .trim();
  }
}

String ganttScheduleDueLabel(gantt.GanttTask task, {DateTime? today}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final end = DateUtils.dateOnly(task.endDate);
  final health = ganttScheduleHealthFor(task, today: asOf);

  if (health == GanttScheduleHealth.complete) return 'Done';

  final days = end.difference(asOf).inDays;
  if (days < 0) return '${days.abs()}d late';
  if (days == 0) return 'Today';
  return '${days}d';
}

String _pluralDays(int days, String suffix) {
  final value = '$days ${days == 1 ? 'day' : 'days'}';
  return suffix.isEmpty ? value : '$value $suffix';
}
