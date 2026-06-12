import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_insight.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test(
    'dashboard action queue insight highlights the highest priority owner',
    () {
      final insight = DashboardActionQueueInsight.fromRecommendations(
        recommendations: hrisDashboardActionRecommendations,
        statuses: hrisDashboardTimeSensitiveDoneStatuses,
      );

      expect(
        insight.headline,
        '$hrisDashboardCriticalOwnerLabel owns the critical action in focus',
      );
      expect(
        insight.detail,
        '2 active actions and 1 done action in the current view.',
      );
      expect(insight.ownerLabel, hrisDashboardCriticalOwnerLabel);
      expect(insight.priority, DashboardActionPriority.critical);
      expect(insight.priorityActionCount, 1);
      expect(insight.activeCount, 2);
      expect(insight.doneCount, 1);
      expect(insight.totalCount, 3);
    },
  );

  test('dashboard action queue insight handles empty focus', () {
    final insight = DashboardActionQueueInsight.fromRecommendations(
      recommendations: const [],
      statuses: const {},
    );

    expect(insight.hasActions, isFalse);
    expect(insight.headline, 'No actions in focus');
    expect(insight.priority, isNull);
    expect(insight.ownerLabel, isNull);
  });

  test('dashboard action queue insight handles completed focus', () {
    final insight = DashboardActionQueueInsight.fromRecommendations(
      recommendations: const [hrisDashboardCriticalAction],
      statuses: hrisDashboardCriticalDoneStatuses,
    );

    expect(insight.hasActions, isTrue);
    expect(insight.hasActiveActions, isFalse);
    expect(insight.headline, 'Visible actions are complete');
    expect(insight.ownerLabel, hrisDashboardCriticalOwnerLabel);
    expect(insight.priority, isNull);
    expect(insight.doneCount, 1);
  });
}
