import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';
import 'gantt_schedule_health_service.dart';

/// Timeline lens presets used to filter Gantt tasks without changing data.
enum GanttTimelineViewPreset {
  all,
  activeNow,
  dueSoon,
  dependencyWatch,
  readyNext,
}

bool ganttTaskMatchesTimelineView(
  gantt.GanttTask task,
  GanttTimelineViewPreset preset,
  List<gantt.GanttTask> dependencyTasks, {
  DateTime? today,
  int dueSoonDays = 7,
  int readyWindowDays = 14,
}) {
  final asOf = DateUtils.dateOnly(today ?? DateTime.now());

  switch (preset) {
    case GanttTimelineViewPreset.all:
      return true;
    case GanttTimelineViewPreset.activeNow:
      return ganttScheduleHealthFor(task, today: asOf) ==
          GanttScheduleHealth.active;
    case GanttTimelineViewPreset.dueSoon:
      return _isDueSoon(task, today: asOf, dueSoonDays: dueSoonDays);
    case GanttTimelineViewPreset.dependencyWatch:
      return _needsDependencyWatch(task, dependencyTasks, today: asOf);
    case GanttTimelineViewPreset.readyNext:
      return _isReadyNext(
        task,
        dependencyTasks,
        today: asOf,
        readyWindowDays: readyWindowDays,
      );
  }
}

List<gantt.GanttTask> filterGanttTimelineView({
  required List<gantt.GanttTask> tasks,
  required GanttTimelineViewPreset preset,
  List<gantt.GanttTask>? dependencyTasks,
  DateTime? today,
}) {
  final dependencyPool = dependencyTasks ?? tasks;

  return _flattenTasks(tasks)
      .where(
        (task) => ganttTaskMatchesTimelineView(
          task,
          preset,
          dependencyPool,
          today: today,
        ),
      )
      .toList();
}

Map<GanttTimelineViewPreset, int> countGanttTimelineViews(
  List<gantt.GanttTask> tasks, {
  List<gantt.GanttTask>? dependencyTasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(tasks);
  final dependencyPool = dependencyTasks ?? tasks;

  return {
    for (final preset in GanttTimelineViewPreset.values)
      preset:
          preset == GanttTimelineViewPreset.all
              ? flatTasks.length
              : flatTasks
                  .where(
                    (task) => ganttTaskMatchesTimelineView(
                      task,
                      preset,
                      dependencyPool,
                      today: today,
                    ),
                  )
                  .length,
  };
}

bool _isDueSoon(
  gantt.GanttTask task, {
  required DateTime today,
  required int dueSoonDays,
}) {
  if (task.progress >= 1) return false;

  final end = DateUtils.dateOnly(task.endDate);
  final dueInDays = end.difference(today).inDays;

  return dueInDays >= 0 && dueInDays <= dueSoonDays;
}

bool _needsDependencyWatch(
  gantt.GanttTask task,
  List<gantt.GanttTask> dependencyTasks, {
  required DateTime today,
}) {
  final health =
      ganttDependencyInsightFor(task, dependencyTasks, today: today).health;

  return health == GanttDependencyHealth.waiting ||
      health == GanttDependencyHealth.blocked ||
      health == GanttDependencyHealth.missing;
}

bool _isReadyNext(
  gantt.GanttTask task,
  List<gantt.GanttTask> dependencyTasks, {
  required DateTime today,
  required int readyWindowDays,
}) {
  if (task.progress >= 1) return false;

  final start = DateUtils.dateOnly(task.startDate);
  final startInDays = start.difference(today).inDays;
  if (startInDays < 0 || startInDays > readyWindowDays) return false;

  final dependencyHealth =
      ganttDependencyInsightFor(task, dependencyTasks, today: today).health;

  return dependencyHealth == GanttDependencyHealth.independent ||
      dependencyHealth == GanttDependencyHealth.ready;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}
