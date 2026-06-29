import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

const dashboardActionAllOwners = 'All owners';

class DashboardActionOwnerSummary {
  final String ownerLabel;
  final int openCount;
  final int inProgressCount;
  final int doneCount;

  const DashboardActionOwnerSummary({
    required this.ownerLabel,
    required this.openCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  int get totalCount => openCount + inProgressCount + doneCount;

  int get activeCount => openCount + inProgressCount;
}

List<DashboardActionOwnerSummary> buildDashboardActionOwnerSummaries({
  required List<DashboardActionRecommendation> recommendations,
  required Map<String, DashboardActionStatus> statuses,
}) {
  final countsByOwner = <String, _OwnerActionCounts>{};
  final firstIndexByOwner = <String, int>{};

  for (var index = 0; index < recommendations.length; index++) {
    final recommendation = recommendations[index];
    final owner = recommendation.ownerLabel;
    final counts = countsByOwner.putIfAbsent(owner, () => _OwnerActionCounts());
    firstIndexByOwner.putIfAbsent(owner, () => index);
    counts.add(statuses[recommendation.id] ?? DashboardActionStatus.open);
  }

  final summaries =
      countsByOwner.entries
          .map(
            (entry) => DashboardActionOwnerSummary(
              ownerLabel: entry.key,
              openCount: entry.value.openCount,
              inProgressCount: entry.value.inProgressCount,
              doneCount: entry.value.doneCount,
            ),
          )
          .toList();

  summaries.sort((a, b) {
    final activeComparison = b.activeCount.compareTo(a.activeCount);
    if (activeComparison != 0) return activeComparison;

    return firstIndexByOwner[a.ownerLabel]!.compareTo(
      firstIndexByOwner[b.ownerLabel]!,
    );
  });

  return summaries;
}

class _OwnerActionCounts {
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
