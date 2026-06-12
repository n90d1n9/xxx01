import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_queue_insight.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_queue_spotlight.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action queue spotlight renders insight copy', (
    tester,
  ) async {
    final ownerFocuses = <String>[];
    final priorityFocuses = <DashboardActionPriority>[];
    const insight = DashboardActionQueueInsight(
      headline:
          '$hrisDashboardCriticalOwnerLabel owns the critical action in focus',
      detail: '2 active actions and 1 done action in the current view.',
      ownerLabel: hrisDashboardCriticalOwnerLabel,
      priority: DashboardActionPriority.critical,
      priorityActionCount: 1,
      activeCount: 2,
      doneCount: 1,
      totalCount: 3,
    );

    await _pumpSpotlight(
      tester,
      insight: insight,
      onFocusOwner: ownerFocuses.add,
      onFocusPriority: priorityFocuses.add,
    );

    expect(find.text('Queue spotlight'), findsOneWidget);
    expect(
      find.text(
        '$hrisDashboardCriticalOwnerLabel owns the critical action in focus',
      ),
      findsOneWidget,
    );
    expect(
      find.text('2 active actions and 1 done action in the current view.'),
      findsOneWidget,
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(find.text('Focus priority'), findsOneWidget);
    expect(find.text('Focus owner'), findsOneWidget);

    await tester.tap(find.text('Focus priority'));
    await tester.tap(find.text('Focus owner'));
    await tester.pump();

    expect(priorityFocuses, [DashboardActionPriority.critical]);
    expect(ownerFocuses, [hrisDashboardCriticalOwnerLabel]);
  });

  testWidgets('dashboard action queue spotlight renders visible queue state', (
    tester,
  ) async {
    const insight = DashboardActionQueueInsight(
      headline: 'Visible actions are complete',
      detail: 'Reopen an item if follow-up is still needed.',
      ownerLabel: null,
      priority: null,
      priorityActionCount: 0,
      activeCount: 0,
      doneCount: 3,
      totalCount: 3,
    );

    await _pumpSpotlight(tester, width: 480, insight: insight);

    expect(find.text('Queue spotlight'), findsOneWidget);
    expect(find.text('Visible actions are complete'), findsOneWidget);
    expect(
      find.text('Reopen an item if follow-up is still needed.'),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Visible'), findsOneWidget);
    expect(find.text('Focus priority'), findsNothing);
    expect(find.text('Focus owner'), findsNothing);
  });
}

Future<void> _pumpSpotlight(
  WidgetTester tester, {
  required DashboardActionQueueInsight insight,
  double width = 900,
  ValueChanged<String>? onFocusOwner,
  ValueChanged<DashboardActionPriority>? onFocusPriority,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: DashboardActionQueueSpotlight(
            insight: insight,
            onFocusOwner: onFocusOwner,
            onFocusPriority: onFocusPriority,
          ),
        ),
      ),
    ),
  );
}
