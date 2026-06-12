import 'package:flutter/material.dart';

import '../models/gantt_task.dart';

class GanttTaskVisibleSegment {
  const GanttTaskVisibleSegment({
    required this.startOffsetDays,
    required this.durationDays,
    required this.startsBeforeRange,
    required this.endsAfterRange,
  });

  final int startOffsetDays;
  final int durationDays;
  final bool startsBeforeRange;
  final bool endsAfterRange;

  bool get isClipped => startsBeforeRange || endsAfterRange;

  double left(double dayWidth) => startOffsetDays * dayWidth;

  double width(double dayWidth) => durationDays * dayWidth;
}

GanttTaskVisibleSegment? visibleSegmentForTask({
  required GanttTask task,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final rawRangeStart = DateUtils.dateOnly(rangeStart);
  final rawRangeEnd = DateUtils.dateOnly(rangeEnd);
  final normalizedRangeStart =
      rawRangeStart.isAfter(rawRangeEnd) ? rawRangeEnd : rawRangeStart;
  final normalizedRangeEnd =
      rawRangeStart.isAfter(rawRangeEnd) ? rawRangeStart : rawRangeEnd;
  final taskStart = DateUtils.dateOnly(task.startDate);
  final taskEnd = DateUtils.dateOnly(task.endDate);

  final normalizedTaskStart = taskStart.isAfter(taskEnd) ? taskEnd : taskStart;
  final normalizedTaskEnd = taskStart.isAfter(taskEnd) ? taskStart : taskEnd;

  if (normalizedTaskEnd.isBefore(normalizedRangeStart) ||
      normalizedTaskStart.isAfter(normalizedRangeEnd)) {
    return null;
  }

  final visibleStart = normalizedTaskStart.isBefore(normalizedRangeStart)
      ? normalizedRangeStart
      : normalizedTaskStart;
  final visibleEnd = normalizedTaskEnd.isAfter(normalizedRangeEnd)
      ? normalizedRangeEnd
      : normalizedTaskEnd;

  return GanttTaskVisibleSegment(
    startOffsetDays: visibleStart.difference(normalizedRangeStart).inDays,
    durationDays: visibleEnd.difference(visibleStart).inDays + 1,
    startsBeforeRange: normalizedTaskStart.isBefore(normalizedRangeStart),
    endsAfterRange: normalizedTaskEnd.isAfter(normalizedRangeEnd),
  );
}

int? milestoneOffsetDaysForTask({
  required GanttTask task,
  required DateTime rangeStart,
  required DateTime rangeEnd,
}) {
  final rawRangeStart = DateUtils.dateOnly(rangeStart);
  final rawRangeEnd = DateUtils.dateOnly(rangeEnd);
  final normalizedRangeStart =
      rawRangeStart.isAfter(rawRangeEnd) ? rawRangeEnd : rawRangeStart;
  final normalizedRangeEnd =
      rawRangeStart.isAfter(rawRangeEnd) ? rawRangeStart : rawRangeEnd;
  final milestoneDate = DateUtils.dateOnly(task.startDate);

  if (milestoneDate.isBefore(normalizedRangeStart) ||
      milestoneDate.isAfter(normalizedRangeEnd)) {
    return null;
  }

  return milestoneDate.difference(normalizedRangeStart).inDays;
}
