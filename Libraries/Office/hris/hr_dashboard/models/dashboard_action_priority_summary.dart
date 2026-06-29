import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

const dashboardActionAllPriorities = 'All priorities';

class DashboardActionPrioritySummary {
  final DashboardActionPriority priority;
  final int openCount;
  final int inProgressCount;
  final int doneCount;

  const DashboardActionPrioritySummary({
    required this.priority,
    required this.openCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  int get totalCount => openCount + inProgressCount + doneCount;

  int get activeCount => openCount + inProgressCount;
}

List<DashboardActionPrioritySummary> buildDashboardActionPrioritySummaries({
  required List<DashboardActionRecommendation> recommendations,
  required Map<String, DashboardActionStatus> statuses,
}) {
  final countsByPriority = <DashboardActionPriority, _PriorityActionCounts>{};

  for (final recommendation in recommendations) {
    final counts = countsByPriority.putIfAbsent(
      recommendation.priority,
      () => _PriorityActionCounts(),
    );
    counts.add(statuses[recommendation.id] ?? DashboardActionStatus.open);
  }

  return DashboardActionPriority.values
      .where((priority) => countsByPriority.containsKey(priority))
      .map((priority) {
        final counts = countsByPriority[priority]!;
        return DashboardActionPrioritySummary(
          priority: priority,
          openCount: counts.openCount,
          inProgressCount: counts.inProgressCount,
          doneCount: counts.doneCount,
        );
      })
      .toList();
}

class _PriorityActionCounts {
  var openCount = 0;
  var inProgressCount = 0;
  var doneCount = 0;

  void add(DashboardActionStatus status) {
    switch (status) {
      case DashboardActionStatus.open:
        openCount++;
      case DashboardActionStatus.inProgress:
        inProgressCount++;
      case DashboardActionStatus.done:
        doneCount++;
    }
  }
}
