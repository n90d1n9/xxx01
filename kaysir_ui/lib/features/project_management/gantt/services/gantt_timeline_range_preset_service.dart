import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_schedule_health_service.dart';

enum GanttTimelineRangePreset {
  planningWindow,
  currentMonth,
  attentionWindow,
  nextNinetyDays,
  projectSpan,
}

extension GanttTimelineRangePresetPresentation on GanttTimelineRangePreset {
  String get label {
    switch (this) {
      case GanttTimelineRangePreset.planningWindow:
        return 'Planning Window';
      case GanttTimelineRangePreset.currentMonth:
        return 'This Month';
      case GanttTimelineRangePreset.attentionWindow:
        return 'Attention Window';
      case GanttTimelineRangePreset.nextNinetyDays:
        return 'Next 90 Days';
      case GanttTimelineRangePreset.projectSpan:
        return 'Project Span';
    }
  }

  IconData get icon {
    switch (this) {
      case GanttTimelineRangePreset.planningWindow:
        return Icons.today_outlined;
      case GanttTimelineRangePreset.currentMonth:
        return Icons.calendar_month_outlined;
      case GanttTimelineRangePreset.attentionWindow:
        return Icons.crisis_alert_outlined;
      case GanttTimelineRangePreset.nextNinetyDays:
        return Icons.date_range_outlined;
      case GanttTimelineRangePreset.projectSpan:
        return Icons.fit_screen_outlined;
    }
  }
}

class GanttTimelineRangePresetService {
  const GanttTimelineRangePresetService();

  static const projectSpanPadding = Duration(days: 3);
  static const attentionWindowPadding = Duration(days: 2);
  static const attentionDueSoonDays = 14;

  List<GanttTimelineRangePresetSummary> summariesFor({
    required List<gantt.GanttTask> tasks,
    DateTime? today,
  }) {
    return [
      for (final preset in GanttTimelineRangePreset.values)
        summaryFor(preset: preset, tasks: tasks, today: today),
    ];
  }

  GanttTimelineRangePresetSummary summaryFor({
    required GanttTimelineRangePreset preset,
    required List<gantt.GanttTask> tasks,
    DateTime? today,
  }) {
    final normalizedToday = DateUtils.dateOnly(today ?? DateTime.now());
    final range = rangeFor(
      preset: preset,
      tasks: tasks,
      today: normalizedToday,
    );

    return GanttTimelineRangePresetSummary(
      preset: preset,
      range: range,
      taskCount: _taskCountForPreset(
        preset,
        tasks: tasks,
        range: range,
        today: normalizedToday,
      ),
    );
  }

  DateTimeRange rangeFor({
    required GanttTimelineRangePreset preset,
    required List<gantt.GanttTask> tasks,
    DateTime? today,
  }) {
    final normalizedToday = DateUtils.dateOnly(today ?? DateTime.now());

    switch (preset) {
      case GanttTimelineRangePreset.planningWindow:
        return _planningWindow(normalizedToday);
      case GanttTimelineRangePreset.currentMonth:
        return _currentMonth(normalizedToday);
      case GanttTimelineRangePreset.attentionWindow:
        return _attentionWindow(tasks, normalizedToday) ??
            _planningWindow(normalizedToday);
      case GanttTimelineRangePreset.nextNinetyDays:
        return DateTimeRange(
          start: normalizedToday,
          end: normalizedToday.add(const Duration(days: 90)),
        );
      case GanttTimelineRangePreset.projectSpan:
        return _projectSpan(tasks) ?? _planningWindow(normalizedToday);
    }
  }

  DateTimeRange _planningWindow(DateTime today) {
    return DateTimeRange(
      start: today.subtract(const Duration(days: 7)),
      end: today.add(const Duration(days: 30)),
    );
  }

  DateTimeRange _currentMonth(DateTime today) {
    return DateTimeRange(
      start: DateTime(today.year, today.month),
      end: DateTime(today.year, today.month + 1, 0),
    );
  }

  DateTimeRange? _projectSpan(List<gantt.GanttTask> tasks) {
    final flatTasks = _flattenTasks(tasks);
    if (flatTasks.isEmpty) return null;

    return _rangeForTasks(flatTasks, padding: projectSpanPadding);
  }

  DateTimeRange? _attentionWindow(List<gantt.GanttTask> tasks, DateTime today) {
    final attentionTasks = _attentionTasks(tasks, today);

    if (attentionTasks.isEmpty) return null;

    return _rangeForTasks(attentionTasks, padding: attentionWindowPadding);
  }

  int _taskCountForPreset(
    GanttTimelineRangePreset preset, {
    required List<gantt.GanttTask> tasks,
    required DateTimeRange range,
    required DateTime today,
  }) {
    final flatTasks = _flattenTasks(tasks);

    switch (preset) {
      case GanttTimelineRangePreset.attentionWindow:
        return _attentionTasks(tasks, today).length;
      case GanttTimelineRangePreset.projectSpan:
        return flatTasks.length;
      case GanttTimelineRangePreset.planningWindow:
      case GanttTimelineRangePreset.currentMonth:
      case GanttTimelineRangePreset.nextNinetyDays:
        return flatTasks.where((task) => _intersectsRange(task, range)).length;
    }
  }

  List<gantt.GanttTask> _attentionTasks(
    List<gantt.GanttTask> tasks,
    DateTime today,
  ) {
    return _flattenTasks(tasks).where((task) {
      final health = ganttScheduleHealthFor(
        task,
        today: today,
        dueSoonDays: attentionDueSoonDays,
      );

      return health == GanttScheduleHealth.overdue ||
          health == GanttScheduleHealth.active ||
          health == GanttScheduleHealth.dueSoon;
    }).toList();
  }

  DateTimeRange _rangeForTasks(
    List<gantt.GanttTask> tasks, {
    required Duration padding,
  }) {
    var earliest = _orderedStart(tasks.first);
    var latest = _orderedEnd(tasks.first);

    for (final task in tasks.skip(1)) {
      final taskStart = _orderedStart(task);
      final taskEnd = _orderedEnd(task);
      if (taskStart.isBefore(earliest)) earliest = taskStart;
      if (taskEnd.isAfter(latest)) latest = taskEnd;
    }

    return DateTimeRange(
      start: earliest.subtract(padding),
      end: latest.add(padding),
    );
  }

  List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
    return [
      for (final task in tasks) ...[
        task,
        if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
      ],
    ];
  }

  DateTime _orderedStart(gantt.GanttTask task) {
    final start = DateUtils.dateOnly(task.startDate);
    final end = DateUtils.dateOnly(task.endDate);
    return start.isBefore(end) ? start : end;
  }

  DateTime _orderedEnd(gantt.GanttTask task) {
    final start = DateUtils.dateOnly(task.startDate);
    final end = DateUtils.dateOnly(task.endDate);
    return start.isAfter(end) ? start : end;
  }

  bool _intersectsRange(gantt.GanttTask task, DateTimeRange range) {
    final start = _orderedStart(task);
    final end = _orderedEnd(task);

    return !end.isBefore(range.start) && !start.isAfter(range.end);
  }
}

class GanttTimelineRangePresetSummary {
  const GanttTimelineRangePresetSummary({
    required this.preset,
    required this.range,
    required this.taskCount,
  });

  final GanttTimelineRangePreset preset;
  final DateTimeRange range;
  final int taskCount;

  String get taskCountLabel => taskCount == 1 ? '1 task' : '$taskCount tasks';

  String get optionLabel => '${preset.label} ($taskCountLabel)';
}
