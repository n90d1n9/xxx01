import '../models/task_model.dart';

/// CPM (Critical Path Method) implementation.
/// Returns the set of task IDs that lie on the critical path.
class CriticalPathCalculator {
  CriticalPathCalculator._();

  static Set<String> calculate(List<Task> tasks) {
    if (tasks.isEmpty) return {};

    final taskMap = {for (final t in tasks) t.id: t};

    // ── Forward Pass: compute Earliest Start (ES) and Earliest Finish (EF) ──
    final es = <String, int>{};
    final ef = <String, int>{};

    // Topological sort
    final sorted = _topologicalSort(tasks, taskMap);

    for (final task in sorted) {
      final predecessors = task.dependencyIds
          .where((id) => taskMap.containsKey(id))
          .map((id) => taskMap[id]!);

      final maxEf = predecessors.isEmpty
          ? 0
          : predecessors.map((p) => ef[p.id] ?? 0).reduce((a, b) => a > b ? a : b);

      es[task.id] = maxEf;
      ef[task.id] = maxEf + task.durationDays;
    }

    // Project duration
    final projectEnd = ef.values.isEmpty ? 0 : ef.values.reduce((a, b) => a > b ? a : b);

    // ── Backward Pass: compute Latest Start (LS) and Latest Finish (LF) ──
    final ls = <String, int>{};
    final lf = <String, int>{};

    for (final task in sorted.reversed) {
      final successors = tasks
          .where((t) => t.dependencyIds.contains(task.id))
          .toList();

      final minLs = successors.isEmpty
          ? projectEnd
          : successors
              .map((s) => ls[s.id] ?? projectEnd)
              .reduce((a, b) => a < b ? a : b);

      lf[task.id] = minLs;
      ls[task.id] = minLs - task.durationDays;
    }

    // ── Float and Critical Path ───────────────────────────────────────────
    final criticalIds = <String>{};
    for (final task in tasks) {
      final float = (ls[task.id] ?? 0) - (es[task.id] ?? 0);
      if (float == 0) {
        criticalIds.add(task.id);
      }
    }

    return criticalIds;
  }

  static List<Task> _topologicalSort(
    List<Task> tasks,
    Map<String, Task> taskMap,
  ) {
    final visited = <String>{};
    final result = <Task>[];

    void visit(Task task) {
      if (visited.contains(task.id)) return;
      visited.add(task.id);
      for (final depId in task.dependencyIds) {
        if (taskMap.containsKey(depId)) {
          visit(taskMap[depId]!);
        }
      }
      result.add(task);
    }

    for (final task in tasks) {
      visit(task);
    }

    return result;
  }
}
