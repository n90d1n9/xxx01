import 'dart:math' as math;

import 'package:ky_gantt/ky_gantt.dart' as ky;

class GanttTaskDragPreviewGhostBarGeometry {
  const GanttTaskDragPreviewGhostBarGeometry({
    required this.originalStartFraction,
    required this.originalWidthFraction,
    required this.targetStartFraction,
    required this.targetWidthFraction,
    required this.hasDateChange,
  });

  final double originalStartFraction;
  final double originalWidthFraction;
  final double targetStartFraction;
  final double targetWidthFraction;
  final bool hasDateChange;

  double get originalEndFraction =>
      (originalStartFraction + originalWidthFraction).clamp(0, 1).toDouble();

  double get targetEndFraction =>
      (targetStartFraction + targetWidthFraction).clamp(0, 1).toDouble();

  double get originalCenterFraction =>
      (originalStartFraction + (originalWidthFraction / 2))
          .clamp(0, 1)
          .toDouble();

  double get targetCenterFraction =>
      (targetStartFraction + (targetWidthFraction / 2)).clamp(0, 1).toDouble();

  double get connectorStartFraction =>
      math.min(originalCenterFraction, targetCenterFraction);

  double get connectorWidthFraction =>
      (targetCenterFraction - originalCenterFraction)
          .abs()
          .clamp(0, 1)
          .toDouble();

  bool get targetMovesLater => targetCenterFraction > originalCenterFraction;
}

class GanttTaskDragPreviewGhostBarGeometryService {
  const GanttTaskDragPreviewGhostBarGeometryService();

  GanttTaskDragPreviewGhostBarGeometry geometryFor(
    ky.KyGanttTaskDragPreview preview,
  ) {
    final originalStart = _dateOnly(preview.task.startDate);
    final originalEnd = _dateOnly(preview.task.endDate);
    final targetStart = _dateOnly(preview.startDate);
    final targetEnd = _dateOnly(preview.endDate);
    final spanStart = _earliestOf(originalStart, targetStart);
    final spanEnd = _latestOf(originalEnd, targetEnd);
    final spanDays = math.max(_inclusiveDays(spanStart, spanEnd), 1);

    return GanttTaskDragPreviewGhostBarGeometry(
      originalStartFraction: _startFraction(
        spanStart: spanStart,
        start: originalStart,
        spanDays: spanDays,
      ),
      originalWidthFraction: _widthFraction(
        start: originalStart,
        end: originalEnd,
        spanDays: spanDays,
      ),
      targetStartFraction: _startFraction(
        spanStart: spanStart,
        start: targetStart,
        spanDays: spanDays,
      ),
      targetWidthFraction: _widthFraction(
        start: targetStart,
        end: targetEnd,
        spanDays: spanDays,
      ),
      hasDateChange:
          originalStart != targetStart ||
          originalEnd != targetEnd ||
          preview.deltaDays != 0,
    );
  }

  double _startFraction({
    required DateTime spanStart,
    required DateTime start,
    required int spanDays,
  }) {
    return (_dayOffset(spanStart, start) / spanDays).clamp(0, 1).toDouble();
  }

  double _widthFraction({
    required DateTime start,
    required DateTime end,
    required int spanDays,
  }) {
    return (_inclusiveDays(start, end) / spanDays).clamp(0, 1).toDouble();
  }

  DateTime _earliestOf(DateTime first, DateTime second) {
    return first.isBefore(second) ? first : second;
  }

  DateTime _latestOf(DateTime first, DateTime second) {
    return first.isAfter(second) ? first : second;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  int _inclusiveDays(DateTime start, DateTime end) {
    return math.max(_dayOffset(start, end) + 1, 1);
  }

  int _dayOffset(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }
}
