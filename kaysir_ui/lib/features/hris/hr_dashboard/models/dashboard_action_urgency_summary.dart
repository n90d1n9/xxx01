import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_action_urgency.dart';

class DashboardActionUrgencySummary {
  final DashboardActionUrgencyTier tier;
  final int totalCount;

  const DashboardActionUrgencySummary({
    required this.tier,
    required this.totalCount,
  });

  String get label => dashboardActionUrgencyLabel(tier);
}

List<DashboardActionUrgencySummary> buildDashboardActionUrgencySummaries({
  required List<DashboardActionRecommendation> recommendations,
  required Map<String, DashboardActionStatus> statuses,
}) {
  final counts = {
    for (final tier in DashboardActionUrgencyTier.values) tier: 0,
  };

  for (final item in recommendations) {
    final status = statuses[item.id] ?? DashboardActionStatus.open;
    final urgency =
        DashboardActionUrgency.fromAction(action: item, status: status).tier;
    counts[urgency] = counts[urgency]! + 1;
  }

  return [
    for (final tier in DashboardActionUrgencyTier.values)
      if (counts[tier]! > 0)
        DashboardActionUrgencySummary(tier: tier, totalCount: counts[tier]!),
  ];
}
