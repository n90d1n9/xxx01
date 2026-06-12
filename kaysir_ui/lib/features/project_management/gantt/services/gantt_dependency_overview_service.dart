import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';

class GanttDependencyOverviewItem {
  const GanttDependencyOverviewItem({
    required this.task,
    required this.insight,
  });

  final gantt.GanttTask task;
  final GanttDependencyInsight insight;

  bool get hasScheduleConflict {
    final dependencyTask = insight.dependencyTask;
    if (dependencyTask == null) return false;

    return ky.hasGanttDependencyConflict(
      task: task,
      predecessor: dependencyTask,
    );
  }

  bool get needsAttention =>
      insight.health == GanttDependencyHealth.blocked ||
      insight.health == GanttDependencyHealth.missing ||
      insight.health == GanttDependencyHealth.waiting;
}

class GanttDependencyOverviewSummary {
  const GanttDependencyOverviewSummary({required this.items});

  final List<GanttDependencyOverviewItem> items;

  int get linkedCount => items.length;
  int get alertCount => items.where((item) => item.insight.isAlert).length;
  int get waitingCount =>
      items
          .where((item) => item.insight.health == GanttDependencyHealth.waiting)
          .length;
  int get readyCount =>
      items
          .where((item) => item.insight.health == GanttDependencyHealth.ready)
          .length;
  int get attentionCount => items.where((item) => item.needsAttention).length;
  int get scheduleConflictCount =>
      items.where((item) => item.hasScheduleConflict).length;

  GanttDependencyHealth get signal {
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

  List<GanttDependencyOverviewItem> get prioritizedItems {
    final sortedItems = [...items]..sort(_compareOverviewItems);
    return List.unmodifiable(sortedItems);
  }
}

GanttDependencyOverviewSummary buildGanttDependencyOverviewSummary({
  required List<gantt.GanttTask> tasks,
  required List<gantt.GanttTask> dependencyTasks,
  DateTime? today,
}) {
  final flatTasks = _flattenTasks(tasks);
  final items = <GanttDependencyOverviewItem>[];

  for (final task in flatTasks) {
    final dependencyId = task.dependsOn?.trim();
    if (dependencyId == null || dependencyId.isEmpty) continue;

    items.add(
      GanttDependencyOverviewItem(
        task: task,
        insight: ganttDependencyInsightFor(task, dependencyTasks, today: today),
      ),
    );
  }

  items.sort(_compareOverviewItems);

  return GanttDependencyOverviewSummary(items: List.unmodifiable(items));
}

String ganttDependencyOverviewDetail(GanttDependencyOverviewItem item) {
  return item.insight.detail;
}

int _compareOverviewItems(
  GanttDependencyOverviewItem left,
  GanttDependencyOverviewItem right,
) {
  final healthCompare = _healthRank(
    left.insight.health,
  ).compareTo(_healthRank(right.insight.health));
  if (healthCompare != 0) return healthCompare;

  final dateCompare = left.task.startDate.compareTo(right.task.startDate);
  if (dateCompare != 0) return dateCompare;

  return left.task.title.compareTo(right.task.title);
}

int _healthRank(GanttDependencyHealth health) {
  switch (health) {
    case GanttDependencyHealth.missing:
      return 0;
    case GanttDependencyHealth.blocked:
      return 1;
    case GanttDependencyHealth.waiting:
      return 2;
    case GanttDependencyHealth.ready:
      return 3;
    case GanttDependencyHealth.independent:
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
