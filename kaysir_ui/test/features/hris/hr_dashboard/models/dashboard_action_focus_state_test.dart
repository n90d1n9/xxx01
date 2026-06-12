import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_focus_state.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  test('dashboard action focus state describes active filters', () {
    const focus = DashboardActionFocusState(
      hideCompleted: true,
      ownerLabel: hrisDashboardCriticalOwnerLabel,
      priority: DashboardActionPriority.critical,
      urgency: DashboardActionUrgencyTier.now,
      visibleCount: 1,
      totalCount: 3,
    );

    expect(focus.hasActiveFocus, isTrue);
    expect(focus.hasOwnerFocus, isTrue);
    expect(focus.hasPriorityFocus, isTrue);
    expect(focus.hasUrgencyFocus, isTrue);
    expect(focus.resultLabel, 'Showing 1 of 3 actions');
    expect(focus.activeLabels, [
      'Done hidden',
      'Urgency: Due now',
      'Priority: Critical',
      'Owner: $hrisDashboardCriticalOwnerLabel',
    ]);
  });

  test('dashboard action focus state stays quiet without filters', () {
    const focus = DashboardActionFocusState(
      hideCompleted: false,
      ownerLabel: 'All owners',
      priority: null,
      urgency: null,
      visibleCount: 3,
      totalCount: 3,
    );

    expect(focus.hasActiveFocus, isFalse);
    expect(focus.resultLabel, 'Showing all 3 actions');
    expect(focus.activeLabels, isEmpty);
  });
}
