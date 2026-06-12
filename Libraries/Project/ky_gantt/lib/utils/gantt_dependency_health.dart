import 'package:flutter/material.dart';

import '../models/gantt_task.dart';
import 'gantt_dependency_focus.dart';
import 'gantt_task_tree.dart';

bool hasGanttDependencyConflict({
  required GanttTask task,
  required GanttTask predecessor,
}) {
  final taskStart = DateUtils.dateOnly(task.startDate);
  final predecessorEnd = DateUtils.dateOnly(predecessor.endDate);
  return !taskStart.isAfter(predecessorEnd);
}

Set<KyGanttDependencyEdge> conflictedGanttDependencyEdges({
  required List<GanttTask> tasks,
}) {
  final flatTasks = flattenGanttTasks(tasks);
  final taskById = {for (final task in flatTasks) task.id: task};
  final conflictedEdges = <KyGanttDependencyEdge>{};

  for (final task in flatTasks) {
    final predecessorId = task.dependsOn?.trim();
    if (predecessorId == null || predecessorId.isEmpty) continue;

    final predecessor = taskById[predecessorId];
    if (predecessor == null) continue;
    if (!hasGanttDependencyConflict(task: task, predecessor: predecessor)) {
      continue;
    }

    conflictedEdges.add(KyGanttDependencyEdge(predecessorId, task.id));
  }

  return conflictedEdges;
}

Set<String> conflictedGanttDependencyTaskIds({
  required List<GanttTask> tasks,
}) {
  return {
    for (final edge in conflictedGanttDependencyEdges(tasks: tasks))
      edge.taskId,
  };
}
