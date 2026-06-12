import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('dashboard action owner summaries count statuses by owner', () {
    final owners = buildDashboardActionOwnerSummaries(
      recommendations: hrisDashboardActionRecommendations,
      statuses: hrisDashboardCriticalActiveTimeSensitiveDoneStatuses,
    );

    expect(owners.map((owner) => owner.ownerLabel), [
      hrisDashboardCriticalOwnerLabel,
      hrisDashboardScaleMomentumOwnerLabel,
      hrisDashboardTimeSensitiveOwnerLabel,
    ]);
    expect(owners.first.inProgressCount, 1);
    expect(owners.first.activeCount, 1);
    expect(owners.last.doneCount, 1);
    expect(owners.last.totalCount, 1);
  });
}
