import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;

class GanttTaskDateRangeValidationService {
  const GanttTaskDateRangeValidationService();

  ky.KyGanttTaskDateRangeValidation validate(
    gantt.GanttTask task, {
    required DateTime startDate,
    required DateTime endDate,
    required List<gantt.GanttTask> tasks,
  }) {
    final flatTasks = _flattenTasks(tasks);
    final normalizedStartDate = DateUtils.dateOnly(startDate);
    final normalizedEndDate = DateUtils.dateOnly(endDate);
    final predecessorId = task.dependsOn?.trim();

    if (predecessorId != null && predecessorId.isNotEmpty) {
      final predecessor = _findTaskById(flatTasks, predecessorId);
      if (predecessor == null) {
        return const ky.KyGanttTaskDateRangeValidation.warning(
          'Predecessor is missing',
        );
      }

      final predecessorEndDate = DateUtils.dateOnly(predecessor.endDate);
      if (normalizedStartDate.isBefore(predecessorEndDate)) {
        return ky.KyGanttTaskDateRangeValidation.blocked(
          'Starts before ${predecessor.title} finishes',
        );
      }
    }

    for (final successor in flatTasks) {
      if (successor.dependsOn?.trim() != task.id) continue;

      final successorStartDate = DateUtils.dateOnly(successor.startDate);
      if (successorStartDate.isBefore(normalizedEndDate)) {
        return ky.KyGanttTaskDateRangeValidation.blocked(
          'Would overlap ${successor.title}',
        );
      }
    }

    return const ky.KyGanttTaskDateRangeValidation.valid();
  }

  List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
    return [
      for (final task in tasks) ...[
        task,
        if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
      ],
    ];
  }

  gantt.GanttTask? _findTaskById(List<gantt.GanttTask> tasks, String taskId) {
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }

    return null;
  }
}
