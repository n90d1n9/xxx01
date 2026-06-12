import 'package:flutter/material.dart';

const defaultMaxGanttTimelineDays = 10000;

class GanttTimelineRange {
  const GanttTimelineRange({
    required this.start,
    required this.end,
    required this.totalDays,
    required this.truncated,
  });

  final DateTime start;
  final DateTime end;
  final int totalDays;
  final bool truncated;
}

GanttTimelineRange resolveGanttTimelineRange({
  required DateTime start,
  required DateTime end,
  int maxDays = defaultMaxGanttTimelineDays,
}) {
  final normalizedMaxDays = maxDays < 1 ? 1 : maxDays;
  final rawStart = DateUtils.dateOnly(start);
  final rawEnd = DateUtils.dateOnly(end);
  final normalizedStart = rawStart.isAfter(rawEnd) ? rawEnd : rawStart;
  final normalizedEnd = rawStart.isAfter(rawEnd) ? rawStart : rawEnd;
  final requestedDays = normalizedEnd.difference(normalizedStart).inDays + 1;
  final totalDays = requestedDays.clamp(1, normalizedMaxDays).toInt();

  return GanttTimelineRange(
    start: normalizedStart,
    end: normalizedStart.add(Duration(days: totalDays - 1)),
    totalDays: totalDays,
    truncated: requestedDays > totalDays,
  );
}
