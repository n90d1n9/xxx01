import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;

enum GanttBaselineVarianceState { complete, ahead, onPace, behind, late }

class GanttBaselineVariance {
  const GanttBaselineVariance({
    required this.task,
    required this.expectedProgress,
    required this.actualProgress,
    required this.progressVariance,
    required this.varianceDays,
    required this.state,
  });

  final gantt.GanttTask task;
  final double expectedProgress;
  final double actualProgress;
  final double progressVariance;
  final int varianceDays;
  final GanttBaselineVarianceState state;

  int get variancePoints => (progressVariance * 100).round();
  int get expectedPercent => (expectedProgress * 100).round();
  int get actualPercent => (actualProgress * 100).round();
}

class GanttBaselineVarianceSummary {
  const GanttBaselineVarianceSummary({required this.items});

  final List<GanttBaselineVariance> items;

  int get totalTasks => items.length;
  int get lateCount =>
      items
          .where((item) => item.state == GanttBaselineVarianceState.late)
          .length;
  int get behindCount =>
      items
          .where((item) => item.state == GanttBaselineVarianceState.behind)
          .length;
  int get aheadCount =>
      items
          .where((item) => item.state == GanttBaselineVarianceState.ahead)
          .length;
  int get onPaceCount =>
      items
          .where((item) => item.state == GanttBaselineVarianceState.onPace)
          .length;
  int get attentionCount => lateCount + behindCount;

  int get averageVariancePoints {
    if (items.isEmpty) return 0;

    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.progressVariance,
    );

    return ((total / items.length) * 100).round();
  }

  GanttBaselineVarianceState get signal {
    if (lateCount > 0) return GanttBaselineVarianceState.late;
    if (behindCount > 0) return GanttBaselineVarianceState.behind;
    if (aheadCount > 0 && onPaceCount == 0) {
      return GanttBaselineVarianceState.ahead;
    }
    return GanttBaselineVarianceState.onPace;
  }

  List<GanttBaselineVariance> get prioritizedItems {
    final sorted = [...items]..sort(_compareVarianceItems);
    return List.unmodifiable(sorted);
  }
}

extension GanttBaselineVarianceStatePresentation on GanttBaselineVarianceState {
  String get label {
    switch (this) {
      case GanttBaselineVarianceState.complete:
        return 'Complete';
      case GanttBaselineVarianceState.ahead:
        return 'Ahead';
      case GanttBaselineVarianceState.onPace:
        return 'On Pace';
      case GanttBaselineVarianceState.behind:
        return 'Behind';
      case GanttBaselineVarianceState.late:
        return 'Late';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttBaselineVarianceState.complete:
        return Icons.check_circle_outline;
      case GanttBaselineVarianceState.ahead:
        return Icons.trending_up_rounded;
      case GanttBaselineVarianceState.onPace:
        return Icons.speed_outlined;
      case GanttBaselineVarianceState.behind:
        return Icons.trending_down_rounded;
      case GanttBaselineVarianceState.late:
        return Icons.event_busy_outlined;
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case GanttBaselineVarianceState.complete:
      case GanttBaselineVarianceState.ahead:
        return Colors.green.shade700;
      case GanttBaselineVarianceState.onPace:
        return colorScheme.primary;
      case GanttBaselineVarianceState.behind:
        return Colors.orange.shade700;
      case GanttBaselineVarianceState.late:
        return colorScheme.error;
    }
  }
}

GanttBaselineVariance ganttBaselineVarianceFor(
  gantt.GanttTask task, {
  DateTime? today,
  double tolerance = 0.08,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());
  final start = DateUtils.dateOnly(task.startDate);
  final end = DateUtils.dateOnly(task.endDate);
  final durationDays = _durationDays(start, end);
  final expectedProgress = _expectedProgress(
    start: start,
    end: end,
    today: asOf,
    durationDays: durationDays,
  );
  final actualProgress = task.progress.clamp(0, 1).toDouble();
  final progressVariance = actualProgress - expectedProgress;
  final varianceDays = (progressVariance * durationDays).round();

  return GanttBaselineVariance(
    task: task,
    expectedProgress: expectedProgress,
    actualProgress: actualProgress,
    progressVariance: progressVariance,
    varianceDays: varianceDays,
    state: _stateFor(
      task: task,
      today: asOf,
      end: end,
      progressVariance: progressVariance,
      tolerance: tolerance,
    ),
  );
}

GanttBaselineVarianceSummary buildGanttBaselineVarianceSummary({
  required List<gantt.GanttTask> tasks,
  DateTime? today,
}) {
  final items = [
    for (final task in _flattenTasks(tasks))
      ganttBaselineVarianceFor(task, today: today),
  ];

  return GanttBaselineVarianceSummary(items: List.unmodifiable(items));
}

String ganttBaselineVarianceDetail(GanttBaselineVariance variance) {
  final dayText = _dayVarianceLabel(variance.varianceDays);

  return 'Expected ${variance.expectedPercent}%, actual ${variance.actualPercent}% - $dayText';
}

int _durationDays(DateTime start, DateTime end) {
  final days = end.difference(start).inDays + 1;
  return days < 1 ? 1 : days;
}

double _expectedProgress({
  required DateTime start,
  required DateTime end,
  required DateTime today,
  required int durationDays,
}) {
  if (today.isBefore(start)) return 0;
  if (today.isAfter(end)) return 1;

  final elapsedDays = today.difference(start).inDays + 1;
  return (elapsedDays / durationDays).clamp(0, 1).toDouble();
}

GanttBaselineVarianceState _stateFor({
  required gantt.GanttTask task,
  required DateTime today,
  required DateTime end,
  required double progressVariance,
  required double tolerance,
}) {
  if (task.progress >= 1) return GanttBaselineVarianceState.complete;
  if (end.isBefore(today)) return GanttBaselineVarianceState.late;
  if (progressVariance <= -tolerance) return GanttBaselineVarianceState.behind;
  if (progressVariance >= tolerance) return GanttBaselineVarianceState.ahead;
  return GanttBaselineVarianceState.onPace;
}

String _dayVarianceLabel(int varianceDays) {
  if (varianceDays == 0) return 'on baseline';

  final days = varianceDays.abs();
  final suffix = days == 1 ? 'day' : 'days';

  return varianceDays > 0
      ? '$days $suffix ahead of baseline'
      : '$days $suffix behind baseline';
}

int _compareVarianceItems(
  GanttBaselineVariance left,
  GanttBaselineVariance right,
) {
  final stateCompare = _stateRank(
    left.state,
  ).compareTo(_stateRank(right.state));
  if (stateCompare != 0) return stateCompare;

  final varianceCompare = left.progressVariance.compareTo(
    right.progressVariance,
  );
  if (varianceCompare != 0) return varianceCompare;

  return left.task.title.compareTo(right.task.title);
}

int _stateRank(GanttBaselineVarianceState state) {
  switch (state) {
    case GanttBaselineVarianceState.late:
      return 0;
    case GanttBaselineVarianceState.behind:
      return 1;
    case GanttBaselineVarianceState.onPace:
      return 2;
    case GanttBaselineVarianceState.ahead:
      return 3;
    case GanttBaselineVarianceState.complete:
      return 4;
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
