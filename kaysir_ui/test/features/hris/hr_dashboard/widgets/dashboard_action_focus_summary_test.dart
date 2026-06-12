import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_focus_state.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_focus_summary.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action focus summary clears individual chips', (
    tester,
  ) async {
    final hiddenDoneChanges = <bool>[];
    final urgencyChanges = <DashboardActionUrgencyTier?>[];
    final priorityChanges = <DashboardActionPriority?>[];
    final ownerChanges = <String>[];
    final clearAll = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: DashboardActionFocusSummary(
              focus: const DashboardActionFocusState(
                hideCompleted: true,
                ownerLabel: hrisDashboardCriticalOwnerLabel,
                priority: DashboardActionPriority.critical,
                urgency: DashboardActionUrgencyTier.now,
                visibleCount: 1,
                totalCount: 3,
              ),
              onClear: () => clearAll.add('all'),
              onClearHideCompleted: () => hiddenDoneChanges.add(false),
              onClearUrgency: () => urgencyChanges.add(null),
              onClearPriority: () => priorityChanges.add(null),
              onClearOwner: () => ownerChanges.add('All owners'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Done hidden'), findsOneWidget);
    expect(find.text('Urgency: Due now'), findsOneWidget);
    expect(find.text('Priority: Critical'), findsOneWidget);
    expect(
      find.text('Owner: $hrisDashboardCriticalOwnerLabel'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Show done actions'));
    await tester.tap(find.byTooltip('Clear urgency focus'));
    await tester.tap(find.byTooltip('Clear priority focus'));
    await tester.tap(find.byTooltip('Clear owner focus'));
    await tester.tap(find.text('Clear focus'));
    await tester.pump();

    expect(hiddenDoneChanges, [false]);
    expect(urgencyChanges, [null]);
    expect(priorityChanges, [null]);
    expect(ownerChanges, ['All owners']);
    expect(clearAll, ['all']);
  });
}
