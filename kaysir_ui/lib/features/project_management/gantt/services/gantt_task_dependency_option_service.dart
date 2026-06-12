import 'package:ky_gantt/ky_gantt.dart' as ky;

enum GanttTaskDependencyCurrentStatus {
  independent,
  available,
  missing,
  guarded,
}

class GanttTaskDependencyOptions {
  const GanttTaskDependencyOptions({
    required this.candidates,
    required this.currentDependencyId,
    required this.currentDependencyTask,
    required this.currentStatus,
    required this.blockedSelfCount,
    required this.blockedDescendantCount,
    required this.blockedCycleCount,
  });

  final List<ky.GanttTask> candidates;
  final String? currentDependencyId;
  final ky.GanttTask? currentDependencyTask;
  final GanttTaskDependencyCurrentStatus currentStatus;
  final int blockedSelfCount;
  final int blockedDescendantCount;
  final int blockedCycleCount;

  bool get hasMissingDependency =>
      currentStatus == GanttTaskDependencyCurrentStatus.missing;

  bool get hasGuardedCurrentDependency =>
      currentStatus == GanttTaskDependencyCurrentStatus.guarded;

  bool get shouldIncludeCurrentDependencyOption =>
      currentDependencyId != null &&
      (hasMissingDependency || hasGuardedCurrentDependency);

  int get blockedCount =>
      blockedSelfCount + blockedDescendantCount + blockedCycleCount;

  int get guardedOptionCount => blockedDescendantCount + blockedCycleCount;

  String get availabilityLabel {
    final count = candidates.length;
    return count == 1 ? '1 available' : '$count available';
  }

  String get guardLabel {
    if (blockedCycleCount > 0) {
      return blockedCycleCount == 1
          ? '1 cycle guard'
          : '$blockedCycleCount cycle guards';
    }
    if (blockedDescendantCount > 0) return 'Subtree-safe';
    return 'Cycle-safe';
  }

  String get currentGuardLabel {
    if (hasMissingDependency) return 'Missing current';
    if (hasGuardedCurrentDependency) return 'Guarded current';
    return 'Current valid';
  }
}

GanttTaskDependencyOptions buildGanttTaskDependencyOptions({
  required ky.GanttTask task,
  required List<ky.GanttTask> dependencyTasks,
}) {
  final flatTasks = _flattenTasks(dependencyTasks);
  final taskById = {for (final task in flatTasks) task.id: task};
  final descendantIds = _descendantIdsFor(task.id, dependencyTasks);
  final candidates = <ky.GanttTask>[];
  var blockedSelfCount = 0;
  var blockedDescendantCount = 0;
  var blockedCycleCount = 0;

  for (final candidate in flatTasks) {
    if (candidate.id == task.id) {
      blockedSelfCount++;
    } else if (descendantIds.contains(candidate.id)) {
      blockedDescendantCount++;
    } else if (_dependsOnTransitively(candidate, task.id, taskById)) {
      blockedCycleCount++;
    } else {
      candidates.add(candidate);
    }
  }

  final currentDependencyId = _normalizedDependencyId(task.dependsOn);
  final candidateIds = {for (final candidate in candidates) candidate.id};
  final currentDependencyTask =
      currentDependencyId == null ? null : taskById[currentDependencyId];
  final currentStatus =
      currentDependencyId == null
          ? GanttTaskDependencyCurrentStatus.independent
          : candidateIds.contains(currentDependencyId)
          ? GanttTaskDependencyCurrentStatus.available
          : currentDependencyTask == null
          ? GanttTaskDependencyCurrentStatus.missing
          : GanttTaskDependencyCurrentStatus.guarded;

  return GanttTaskDependencyOptions(
    candidates: List.unmodifiable(candidates),
    currentDependencyId: currentDependencyId,
    currentDependencyTask: currentDependencyTask,
    currentStatus: currentStatus,
    blockedSelfCount: blockedSelfCount,
    blockedDescendantCount: blockedDescendantCount,
    blockedCycleCount: blockedCycleCount,
  );
}

String? _normalizedDependencyId(String? dependencyId) {
  final normalized = dependencyId?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

Set<String> _descendantIdsFor(
  String taskId,
  List<ky.GanttTask> dependencyTasks,
) {
  for (final task in dependencyTasks) {
    if (task.id == taskId) {
      return {for (final subtask in _flattenTasks(task.subtasks)) subtask.id};
    }

    final nested = _descendantIdsFor(taskId, task.subtasks);
    if (nested.isNotEmpty) return nested;
  }

  return <String>{};
}

bool _dependsOnTransitively(
  ky.GanttTask candidate,
  String taskId,
  Map<String, ky.GanttTask> taskById,
) {
  final seen = <String>{};
  var dependencyId = _normalizedDependencyId(candidate.dependsOn);

  while (dependencyId != null) {
    if (dependencyId == taskId) return true;
    if (!seen.add(dependencyId)) return false;

    dependencyId = _normalizedDependencyId(taskById[dependencyId]?.dependsOn);
  }

  return false;
}

List<ky.GanttTask> _flattenTasks(List<ky.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}
