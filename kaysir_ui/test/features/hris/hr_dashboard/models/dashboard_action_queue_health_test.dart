import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_progress.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_health.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency_summary.dart';

void main() {
  test('dashboard action queue health flags due-now work without owners', () {
    final health = DashboardActionQueueHealth.fromSignals(
      progress: const DashboardActionProgress(
        openCount: 2,
        inProgressCount: 0,
        doneCount: 0,
      ),
      urgencies: const [
        DashboardActionUrgencySummary(
          tier: DashboardActionUrgencyTier.now,
          totalCount: 1,
        ),
      ],
    );

    expect(health.tone, DashboardActionQueueHealthTone.atRisk);
    expect(health.label, 'At risk');
    expect(health.headline, '1 due-now action needs ownership');
    expect(health.focusUrgency, DashboardActionUrgencyTier.now);
    expect(health.actionLabel, 'Focus due now');
  });

  test('dashboard action queue health recognizes active and clear queues', () {
    final active = DashboardActionQueueHealth.fromSignals(
      progress: const DashboardActionProgress(
        openCount: 1,
        inProgressCount: 1,
        doneCount: 0,
      ),
      urgencies: const [
        DashboardActionUrgencySummary(
          tier: DashboardActionUrgencyTier.now,
          totalCount: 1,
        ),
      ],
    );
    final clear = DashboardActionQueueHealth.fromSignals(
      progress: const DashboardActionProgress(
        openCount: 0,
        inProgressCount: 0,
        doneCount: 2,
      ),
      urgencies: const [
        DashboardActionUrgencySummary(
          tier: DashboardActionUrgencyTier.closed,
          totalCount: 2,
        ),
      ],
    );

    expect(active.tone, DashboardActionQueueHealthTone.active);
    expect(active.label, 'In motion');
    expect(active.actionLabel, 'Review due now');
    expect(clear.tone, DashboardActionQueueHealthTone.clear);
    expect(clear.headline, 'Action queue is closed');
    expect(clear.focusUrgency, isNull);
  });
}
