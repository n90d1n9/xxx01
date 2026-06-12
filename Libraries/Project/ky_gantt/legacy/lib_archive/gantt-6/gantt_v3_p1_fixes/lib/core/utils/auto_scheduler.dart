import '../models/task_model.dart';
import 'date_utils.dart';

/// Auto-Scheduling Engine
///
/// When a task is rescheduled/resized, propagates the change forward through
/// the dependency graph, respecting task constraints.
///
/// Algorithm:
///   1. Topological sort starting from changed task
///   2. For each successor: compute earliest allowed start from all predecessors
///   3. Apply constraint overrides
///   4. Update start/end, preserving duration
class AutoScheduler {
  AutoScheduler._();

  /// Returns a new task list with successor dates propagated.
  /// Only modifies tasks with [autoSchedule] = true.
  /// [changedId] is the task whose dates just changed.
  static List<Task> propagate(List<Task> tasks, String changedId) {
    final taskMap = {for (final t in tasks) t.id: t};
    if (!taskMap.containsKey(changedId)) return tasks;

    // Build successor index: id → list of tasks that depend on it
    final successors = <String, List<Task>>{};
    for (final t in tasks) {
      for (final dep in t.dependencies) {
        successors.putIfAbsent(dep.predecessorId, () => []).add(t);
      }
    }

    // BFS forward from changedId
    final queue = <String>[changedId];
    final visited = <String>{};
    final updates = <String, Task>{};

    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      if (visited.contains(currentId)) continue;
      visited.add(currentId);

      final successorList = successors[currentId] ?? [];
      for (final succ in successorList) {
        if (!succ.autoSchedule) continue;
        final updatedSucc = _computeNewDates(succ, taskMap, updates);
        if (updatedSucc != null) {
          updates[succ.id] = updatedSucc;
          // Merge into taskMap for next iteration
          taskMap[succ.id] = updatedSucc;
          if (!visited.contains(succ.id)) queue.add(succ.id);
        }
      }
    }

    if (updates.isEmpty) return tasks;
    return tasks.map((t) => updates[t.id] ?? t).toList();
  }

  static Task? _computeNewDates(
    Task task,
    Map<String, Task> taskMap,
    Map<String, Task> updates,
  ) {
    DateTime? earliestStart;

    for (final dep in task.dependencies) {
      final pred = updates[dep.predecessorId] ?? taskMap[dep.predecessorId];
      if (pred == null) continue;

      final candidate = switch (dep.type) {
        DependencyType.fs => pred.endDate.add(Duration(days: dep.lagDays + 1)),
        DependencyType.ss => pred.startDate.add(Duration(days: dep.lagDays)),
        DependencyType.ff => pred.endDate.subtract(Duration(days: task.durationDays - 1 - dep.lagDays)),
        DependencyType.sf => pred.startDate.subtract(Duration(days: task.durationDays - 1 - dep.lagDays)),
      };

      if (earliestStart == null || candidate.isAfter(earliestStart)) {
        earliestStart = candidate;
      }
    }

    if (earliestStart == null) return null;

    // Apply constraint overrides
    final constrainedStart = _applyConstraint(task, earliestStart);

    if (GanttDateUtils.isSameDay(constrainedStart, task.startDate)) return null;

    final duration = task.durationDays - 1;
    return task.copyWith(
      startDate: constrainedStart,
      endDate: constrainedStart.add(Duration(days: duration)),
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _applyConstraint(Task task, DateTime proposed) {
    switch (task.constraint) {
      case TaskConstraint.mustStartOn:
        return task.constraintDate ?? proposed;
      case TaskConstraint.mustFinishOn:
        if (task.constraintDate != null) {
          return task.constraintDate!.subtract(Duration(days: task.durationDays - 1));
        }
        return proposed;
      case TaskConstraint.startNoEarlierThan:
        if (task.constraintDate != null && proposed.isBefore(task.constraintDate!)) {
          return task.constraintDate!;
        }
        return proposed;
      case TaskConstraint.finishNoLaterThan:
        if (task.constraintDate != null) {
          final latest = task.constraintDate!.subtract(Duration(days: task.durationDays - 1));
          return proposed.isAfter(latest) ? latest : proposed;
        }
        return proposed;
      case TaskConstraint.asap:
      case TaskConstraint.alap:
        return proposed;
    }
  }
}
