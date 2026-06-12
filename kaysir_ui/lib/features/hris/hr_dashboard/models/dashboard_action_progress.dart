import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

class DashboardActionProgress {
  final int openCount;
  final int inProgressCount;
  final int doneCount;

  const DashboardActionProgress({
    required this.openCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  int get totalCount => openCount + inProgressCount + doneCount;

  double get completionRatio {
    return totalCount == 0 ? 0 : doneCount / totalCount;
  }

  factory DashboardActionProgress.fromRecommendations({
    required List<DashboardActionRecommendation> recommendations,
    required Map<String, DashboardActionStatus> statuses,
  }) {
    var openCount = 0;
    var inProgressCount = 0;
    var doneCount = 0;

    for (final recommendation in recommendations) {
      switch (statuses[recommendation.id] ?? DashboardActionStatus.open) {
        case DashboardActionStatus.open:
          openCount++;
        case DashboardActionStatus.inProgress:
          inProgressCount++;
        case DashboardActionStatus.done:
          doneCount++;
      }
    }

    return DashboardActionProgress(
      openCount: openCount,
      inProgressCount: inProgressCount,
      doneCount: doneCount,
    );
  }
}

List<DashboardActionRecommendation> orderDashboardActionsByStatus({
  required List<DashboardActionRecommendation> recommendations,
  required Map<String, DashboardActionStatus> statuses,
}) {
  final ordered = [...recommendations];
  ordered.sort((a, b) {
    final statusComparison = _statusRank(
      statuses[a.id] ?? DashboardActionStatus.open,
    ).compareTo(_statusRank(statuses[b.id] ?? DashboardActionStatus.open));

    if (statusComparison != 0) return statusComparison;

    return recommendations.indexOf(a).compareTo(recommendations.indexOf(b));
  });
  return ordered;
}

int _statusRank(DashboardActionStatus status) {
  return switch (status) {
    DashboardActionStatus.inProgress => 0,
    DashboardActionStatus.open => 1,
    DashboardActionStatus.done => 2,
  };
}
