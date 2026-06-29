import 'dashboard_action_progress.dart';
import 'dashboard_action_urgency.dart';
import 'dashboard_action_urgency_summary.dart';

enum DashboardActionQueueHealthTone { atRisk, active, planned, clear }

class DashboardActionQueueHealth {
  final DashboardActionQueueHealthTone tone;
  final String label;
  final String headline;
  final String detail;
  final DashboardActionUrgencyTier? focusUrgency;
  final String? actionLabel;

  const DashboardActionQueueHealth({
    required this.tone,
    required this.label,
    required this.headline,
    required this.detail,
    this.focusUrgency,
    this.actionLabel,
  });

  factory DashboardActionQueueHealth.fromSignals({
    required DashboardActionProgress progress,
    required List<DashboardActionUrgencySummary> urgencies,
  }) {
    final dueNow = _countFor(DashboardActionUrgencyTier.now, urgencies);
    final dueSoon = _countFor(DashboardActionUrgencyTier.soon, urgencies);

    if (progress.totalCount == 0 || progress.doneCount == progress.totalCount) {
      return const DashboardActionQueueHealth(
        tone: DashboardActionQueueHealthTone.clear,
        label: 'Clear',
        headline: 'Action queue is closed',
        detail:
            'All visible recommendations are complete, so the next refresh can validate the signal movement.',
      );
    }

    if (dueNow > 0 && progress.inProgressCount == 0) {
      return DashboardActionQueueHealth(
        tone: DashboardActionQueueHealthTone.atRisk,
        label: 'At risk',
        headline: '$dueNow due-now action needs ownership',
        detail:
            'Start or assign the same-day work before expanding the rest of the HR action queue.',
        focusUrgency: DashboardActionUrgencyTier.now,
        actionLabel: 'Focus due now',
      );
    }

    if (dueNow > 0) {
      return DashboardActionQueueHealth(
        tone: DashboardActionQueueHealthTone.active,
        label: 'In motion',
        headline: '$dueNow due-now action is being worked',
        detail:
            'Keep blockers visible and close the action only when the expected dashboard signal moves.',
        focusUrgency: DashboardActionUrgencyTier.now,
        actionLabel: 'Review due now',
      );
    }

    if (dueSoon > 0) {
      return DashboardActionQueueHealth(
        tone: DashboardActionQueueHealthTone.planned,
        label: 'Plan next',
        headline: '$dueSoon due-soon action needs scheduling',
        detail:
            'Reserve owner capacity now so upcoming HR work does not become same-day pressure.',
        focusUrgency: DashboardActionUrgencyTier.soon,
        actionLabel: 'Focus due soon',
      );
    }

    return const DashboardActionQueueHealth(
      tone: DashboardActionQueueHealthTone.planned,
      label: 'Stable',
      headline: 'Action queue is planned',
      detail:
          'No urgent items are visible; keep planned work moving through the normal operating rhythm.',
    );
  }

  static int _countFor(
    DashboardActionUrgencyTier tier,
    List<DashboardActionUrgencySummary> urgencies,
  ) {
    for (final urgency in urgencies) {
      if (urgency.tier == tier) {
        return urgency.totalCount;
      }
    }

    return 0;
  }
}
