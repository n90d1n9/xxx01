import '../gantt_dashboard.dart' as gantt;
import 'gantt_dependency_service.dart';
import 'gantt_schedule_focus_service.dart';

class GanttScheduleDependencyImpactItem {
  const GanttScheduleDependencyImpactItem({
    required this.focusItem,
    required this.insight,
  });

  final GanttScheduleFocusItem focusItem;
  final GanttDependencyInsight insight;
}

class GanttScheduleDependencyImpactSummary {
  const GanttScheduleDependencyImpactSummary({required this.items});

  final List<GanttScheduleDependencyImpactItem> items;

  int get impactCount => items.length;

  int get alertCount {
    return items.where((item) => item.insight.isAlert).length;
  }

  int get waitingCount {
    return items.where((item) {
      return item.insight.health == GanttDependencyHealth.waiting;
    }).length;
  }

  bool get hasImpact => items.isNotEmpty;

  GanttDependencyHealth? get leadingHealth {
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.blocked,
    )) {
      return GanttDependencyHealth.blocked;
    }
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.missing,
    )) {
      return GanttDependencyHealth.missing;
    }
    if (items.any(
      (item) => item.insight.health == GanttDependencyHealth.waiting,
    )) {
      return GanttDependencyHealth.waiting;
    }

    return null;
  }

  String get metricHelper {
    if (alertCount > 0) {
      return '$alertCount blocked or missing';
    }
    if (waitingCount > 0) return '$waitingCount waiting';
    return 'Clear';
  }
}

GanttScheduleDependencyImpactSummary buildGanttScheduleDependencyImpactSummary({
  required List<GanttScheduleFocusItem> focusItems,
  required List<gantt.GanttTask> dependencyTasks,
  DateTime? today,
}) {
  final items = [
    for (final item in focusItems)
      if (_impactItemFor(item, dependencyTasks: dependencyTasks, today: today)
          case final impact?)
        impact,
  ]..sort(_compareImpactItems);

  return GanttScheduleDependencyImpactSummary(items: List.unmodifiable(items));
}

GanttScheduleDependencyImpactItem? _impactItemFor(
  GanttScheduleFocusItem item, {
  required List<gantt.GanttTask> dependencyTasks,
  required DateTime? today,
}) {
  final insight = ganttDependencyInsightFor(
    item.task,
    dependencyTasks,
    today: today,
  );

  if (insight.health == GanttDependencyHealth.independent ||
      insight.health == GanttDependencyHealth.ready) {
    return null;
  }

  return GanttScheduleDependencyImpactItem(focusItem: item, insight: insight);
}

int _compareImpactItems(
  GanttScheduleDependencyImpactItem left,
  GanttScheduleDependencyImpactItem right,
) {
  final healthCompare = _dependencyRank(
    left.insight.health,
  ).compareTo(_dependencyRank(right.insight.health));
  if (healthCompare != 0) return healthCompare;

  final endCompare = left.focusItem.task.endDate.compareTo(
    right.focusItem.task.endDate,
  );
  if (endCompare != 0) return endCompare;

  return left.focusItem.task.title.compareTo(right.focusItem.task.title);
}

int _dependencyRank(GanttDependencyHealth health) {
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
