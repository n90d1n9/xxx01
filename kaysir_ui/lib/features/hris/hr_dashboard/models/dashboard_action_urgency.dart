import 'dashboard_action_status.dart';
import 'dashboard_action_summary.dart';

const dashboardActionAllUrgencies = 'All urgency';

enum DashboardActionUrgencyTier { now, soon, planned, closed }

class DashboardActionUrgency {
  final DashboardActionUrgencyTier tier;
  final String label;
  final String helper;

  const DashboardActionUrgency({
    required this.tier,
    required this.label,
    required this.helper,
  });

  factory DashboardActionUrgency.fromTier(DashboardActionUrgencyTier tier) {
    return switch (tier) {
      DashboardActionUrgencyTier.now => const DashboardActionUrgency(
        tier: DashboardActionUrgencyTier.now,
        label: 'Due now',
        helper: 'Needs same-day attention',
      ),
      DashboardActionUrgencyTier.soon => const DashboardActionUrgency(
        tier: DashboardActionUrgencyTier.soon,
        label: 'Due soon',
        helper: 'Protect the current review window',
      ),
      DashboardActionUrgencyTier.planned => const DashboardActionUrgency(
        tier: DashboardActionUrgencyTier.planned,
        label: 'Planned',
        helper: 'Track at the next operating rhythm',
      ),
      DashboardActionUrgencyTier.closed => const DashboardActionUrgency(
        tier: DashboardActionUrgencyTier.closed,
        label: 'Closed',
        helper: 'Action completed',
      ),
    };
  }

  factory DashboardActionUrgency.fromAction({
    required DashboardActionRecommendation action,
    required DashboardActionStatus status,
  }) {
    if (status == DashboardActionStatus.done) {
      return DashboardActionUrgency.fromTier(DashboardActionUrgencyTier.closed);
    }

    final due = action.dueLabel.toLowerCase();
    if (due.contains('today') || due.contains('48 hour')) {
      return DashboardActionUrgency.fromTier(DashboardActionUrgencyTier.now);
    }

    if (due.contains('week') || due.contains('soon')) {
      return DashboardActionUrgency.fromTier(DashboardActionUrgencyTier.soon);
    }

    return DashboardActionUrgency.fromTier(DashboardActionUrgencyTier.planned);
  }
}

String dashboardActionUrgencyLabel(DashboardActionUrgencyTier tier) {
  return DashboardActionUrgency.fromTier(tier).label;
}
