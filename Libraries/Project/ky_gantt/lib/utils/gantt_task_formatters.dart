import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gantt_task.dart';

enum GanttTaskStatus { planned, active, done }

enum GanttTaskScheduleStatus {
  planned,
  inProgress,
  dueToday,
  overdue,
  complete,
}

GanttTaskStatus ganttTaskStatusFor(GanttTask task) {
  final progress = task.progress.clamp(0, 1).toDouble();
  if (progress >= 1) return GanttTaskStatus.done;
  if (progress <= 0) return GanttTaskStatus.planned;
  return GanttTaskStatus.active;
}

String ganttTaskStatusText(GanttTaskStatus status) {
  switch (status) {
    case GanttTaskStatus.planned:
      return 'Planned';
    case GanttTaskStatus.active:
      return 'Active';
    case GanttTaskStatus.done:
      return 'Done';
  }
}

String ganttTaskStatusLabel(GanttTask task) {
  return ganttTaskStatusText(ganttTaskStatusFor(task));
}

GanttTaskScheduleStatus ganttTaskScheduleStatusFor(
  GanttTask task, {
  DateTime? today,
}) {
  if (task.progress.clamp(0, 1) >= 1) {
    return GanttTaskScheduleStatus.complete;
  }

  final normalizedToday = DateUtils.dateOnly(today ?? DateTime.now());
  final dates = _orderedTaskDates(task);

  if (dates.end.isBefore(normalizedToday)) {
    return GanttTaskScheduleStatus.overdue;
  }
  if (dates.end == normalizedToday) {
    return GanttTaskScheduleStatus.dueToday;
  }
  if (dates.start.isAfter(normalizedToday)) {
    return GanttTaskScheduleStatus.planned;
  }

  return GanttTaskScheduleStatus.inProgress;
}

String ganttTaskScheduleStatusText(GanttTaskScheduleStatus status) {
  switch (status) {
    case GanttTaskScheduleStatus.planned:
      return 'Planned';
    case GanttTaskScheduleStatus.inProgress:
      return 'In progress';
    case GanttTaskScheduleStatus.dueToday:
      return 'Due today';
    case GanttTaskScheduleStatus.overdue:
      return 'Overdue';
    case GanttTaskScheduleStatus.complete:
      return 'Complete';
  }
}

String ganttTaskScheduleBadgeText(GanttTaskScheduleStatus status) {
  switch (status) {
    case GanttTaskScheduleStatus.planned:
      return 'Planned';
    case GanttTaskScheduleStatus.inProgress:
      return 'Active';
    case GanttTaskScheduleStatus.dueToday:
      return 'Due';
    case GanttTaskScheduleStatus.overdue:
      return 'Late';
    case GanttTaskScheduleStatus.complete:
      return 'Done';
  }
}

String ganttTaskScheduleStatusLabel(
  GanttTask task, {
  DateTime? today,
}) {
  return ganttTaskScheduleStatusText(
    ganttTaskScheduleStatusFor(task, today: today),
  );
}

String ganttTaskProgressLabel(GanttTask task) {
  final progress = task.progress.clamp(0, 1).toDouble();
  return '${(progress * 100).round()}%';
}

String ganttTaskDateRangeLabel(GanttTask task) {
  final start = DateUtils.dateOnly(task.startDate);
  final end = DateUtils.dateOnly(task.endDate);
  final monthDayFormat = DateFormat.MMMd();

  if (start == end) return monthDayFormat.format(start);
  if (start.year == end.year && start.month == end.month) {
    return '${DateFormat.MMM().format(start)} '
        '${DateFormat.d().format(start)}-${DateFormat.d().format(end)}';
  }

  return '${monthDayFormat.format(start)}-${monthDayFormat.format(end)}';
}

String ganttTaskDurationLabel(GanttTask task) {
  final days = task.durationDays;
  if (days % 7 == 0) return '${days ~/ 7}w';
  return '${days}d';
}

bool ganttTaskHasDependency(GanttTask task) {
  final dependsOn = task.dependsOn?.trim();
  return dependsOn != null && dependsOn.isNotEmpty;
}

_GanttTaskDateRange _orderedTaskDates(GanttTask task) {
  final start = DateUtils.dateOnly(task.startDate);
  final end = DateUtils.dateOnly(task.endDate);

  if (start.isAfter(end)) {
    return _GanttTaskDateRange(start: end, end: start);
  }

  return _GanttTaskDateRange(start: start, end: end);
}

class _GanttTaskDateRange {
  const _GanttTaskDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
