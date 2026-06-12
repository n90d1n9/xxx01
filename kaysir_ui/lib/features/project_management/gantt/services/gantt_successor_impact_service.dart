import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';

class GanttSuccessorImpactItem {
  const GanttSuccessorImpactItem({
    required this.task,
    required this.directPredecessor,
    required this.depth,
    required this.insight,
    required this.hasScheduleConflict,
  });

  final gantt.GanttTask task;
  final gantt.GanttTask directPredecessor;
  final int depth;
  final GanttDependencyInsight insight;
  final bool hasScheduleConflict;

  bool get isDirect => depth == 1;
  bool get needsAttention =>
      hasScheduleConflict ||
      insight.health == GanttDependencyHealth.blocked ||
      insight.health == GanttDependencyHealth.missing ||
      insight.health == GanttDependencyHealth.waiting;

  String get relationshipLabel => isDirect ? 'Direct' : 'Indirect';

  String get detail {
    if (hasScheduleConflict) {
      return '${task.title} starts before ${directPredecessor.title} clears.';
    }
    if (!isDirect) {
      return 'Linked through ${directPredecessor.title}; ${insight.detail}';
    }
    return insight.detail;
  }
}

class GanttSuccessorImpactSummary {
  const GanttSuccessorImpactSummary({required this.items});

  final List<GanttSuccessorImpactItem> items;

  bool get hasImpact => items.isNotEmpty;
  int get totalCount => items.length;
  int get directCount => items.where((item) => item.isDirect).length;
  int get indirectCount => totalCount - directCount;
  int get scheduleConflictCount =>
      items.where((item) => item.hasScheduleConflict).length;
  int get alertCount => items.where((item) => item.insight.isAlert).length;
  int get waitingCount =>
      items
          .where((item) => item.insight.health == GanttDependencyHealth.waiting)
          .length;
  int get attentionCount => items.where((item) => item.needsAttention).length;

  String get impactLabel =>
      totalCount == 1 ? '1 successor' : '$totalCount successors';

  String get summaryText {
    if (!hasImpact) return 'No downstream successors depend on this task.';
    if (scheduleConflictCount > 0) {
      return scheduleConflictCount == 1
          ? '1 downstream schedule conflict needs review.'
          : '$scheduleConflictCount downstream schedule conflicts need review.';
    }
    if (alertCount > 0) {
      return alertCount == 1
          ? '1 downstream successor is blocked or missing a predecessor.'
          : '$alertCount downstream successors are blocked or missing predecessors.';
    }
    if (waitingCount > 0) {
      return waitingCount == 1
          ? '1 downstream successor is waiting on this chain.'
          : '$waitingCount downstream successors are waiting on this chain.';
    }
    return '$impactLabel are clear after this task.';
  }

  GanttDependencyHealth get signal {
    if (scheduleConflictCount > 0) return GanttDependencyHealth.blocked;
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.missing,
    )) {
      return GanttDependencyHealth.missing;
    }
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.blocked,
    )) {
      return GanttDependencyHealth.blocked;
    }
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.waiting,
    )) {
      return GanttDependencyHealth.waiting;
    }
    if (items.isNotEmpty) return GanttDependencyHealth.ready;
    return GanttDependencyHealth.independent;
  }

  List<GanttSuccessorImpactItem> get prioritizedItems {
    final sortedItems = [...items]..sort(_compareSuccessorItems);
    return List.unmodifiable(sortedItems);
  }
}

GanttSuccessorImpactSummary buildGanttSuccessorImpactSummary({
  required gantt.GanttTask task,
  required List<gantt.GanttTask> dependencyTasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(dependencyTasks);
  final taskById = {
    task.id: task,
    for (final dependencyTask in flatTasks) dependencyTask.id: dependencyTask,
  };
  final items = <GanttSuccessorImpactItem>[];

  for (final candidate in flatTasks) {
    if (candidate.id == task.id) continue;

    final path = _dependencyPathTo(
      candidate,
      targetTaskId: task.id,
      taskById: taskById,
    );
    if (path == null || path.isEmpty) continue;

    final directPredecessor = path.first;
    final insight = ganttDependencyInsightFor(
      candidate,
      dependencyTasks,
      today: today,
      fallbackDependencyTitle: directPredecessor.title,
    );

    items.add(
      GanttSuccessorImpactItem(
        task: candidate,
        directPredecessor: directPredecessor,
        depth: path.length,
        insight: insight,
        hasScheduleConflict: ky.hasGanttDependencyConflict(
          task: candidate,
          predecessor: directPredecessor,
        ),
      ),
    );
  }

  items.sort(_compareSuccessorItems);

  return GanttSuccessorImpactSummary(items: List.unmodifiable(items));
}

List<gantt.GanttTask>? _dependencyPathTo(
  gantt.GanttTask task, {
  required String targetTaskId,
  required Map<String, gantt.GanttTask> taskById,
}) {
  final path = <gantt.GanttTask>[];
  final seen = <String>{task.id};
  var dependencyId = _normalizedDependencyId(task.dependsOn);

  while (dependencyId != null) {
    final predecessor = taskById[dependencyId];
    if (predecessor == null || !seen.add(dependencyId)) return null;

    path.add(predecessor);
    if (dependencyId == targetTaskId) return path;

    dependencyId = _normalizedDependencyId(predecessor.dependsOn);
  }

  return null;
}

int _compareSuccessorItems(
  GanttSuccessorImpactItem left,
  GanttSuccessorImpactItem right,
) {
  final conflictCompare = _boolRank(
    right.hasScheduleConflict,
  ).compareTo(_boolRank(left.hasScheduleConflict));
  if (conflictCompare != 0) return conflictCompare;

  final healthCompare = _healthRank(
    left.insight.health,
  ).compareTo(_healthRank(right.insight.health));
  if (healthCompare != 0) return healthCompare;

  final depthCompare = left.depth.compareTo(right.depth);
  if (depthCompare != 0) return depthCompare;

  final startCompare = left.task.startDate.compareTo(right.task.startDate);
  if (startCompare != 0) return startCompare;

  return left.task.title.compareTo(right.task.title);
}

int _boolRank(bool value) => value ? 1 : 0;

int _healthRank(GanttDependencyHealth health) {
  switch (health) {
    case GanttDependencyHealth.blocked:
      return 0;
    case GanttDependencyHealth.missing:
      return 1;
    case GanttDependencyHealth.waiting:
      return 2;
    case GanttDependencyHealth.ready:
      return 3;
    case GanttDependencyHealth.independent:
      return 4;
  }
}

String? _normalizedDependencyId(String? dependencyId) {
  final normalized = dependencyId?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

List<gantt.GanttTask> _flattenTasks(List<gantt.GanttTask> tasks) {
  return [
    for (final task in tasks) ...[
      task,
      if (task.subtasks.isNotEmpty) ..._flattenTasks(task.subtasks),
    ],
  ];
}
