import 'package:flutter/material.dart';

double initialGanttFocusScrollOffset({
  required DateTime focusDate,
  required DateTime rangeStart,
  required int totalDays,
  required double dayWidth,
  required double viewportWidth,
}) {
  if (totalDays <= 0 || dayWidth <= 0 || viewportWidth <= 0) return 0;

  final timelineWidth = totalDays * dayWidth;
  final maxScrollExtent =
      timelineWidth > viewportWidth ? timelineWidth - viewportWidth : 0.0;
  if (maxScrollExtent <= 0) return 0;

  final normalizedFocusDate = DateUtils.dateOnly(focusDate);
  final normalizedRangeStart = DateUtils.dateOnly(rangeStart);
  final rawOffsetDays =
      normalizedFocusDate.difference(normalizedRangeStart).inDays;
  final offsetDays = rawOffsetDays.clamp(0, totalDays - 1).toInt();
  final focusCenter = (offsetDays * dayWidth) + (dayWidth / 2);
  final centeredOffset = focusCenter - (viewportWidth / 2);

  return centeredOffset.clamp(0, maxScrollExtent).toDouble();
}
