import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_priority_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('dashboard action priority summaries count statuses by severity', () {
    final priorities = buildDashboardActionPrioritySummaries(
      recommendations: hrisDashboardActionRecommendations,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
    );

    expect(priorities.map((summary) => summary.priority), [
      DashboardActionPriority.critical,
      DashboardActionPriority.high,
      DashboardActionPriority.medium,
    ]);
    expect(priorities.first.inProgressCount, 1);
    expect(priorities.first.activeCount, 1);
    expect(priorities[1].doneCount, 1);
    expect(priorities[1].totalCount, 1);
  });
}
