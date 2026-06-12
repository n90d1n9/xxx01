import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_focus_state.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_owner_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_focus_chips.dart';

void main() {
  testWidgets('action focus chips render and clear every active focus', (
    tester,
  ) async {
    final cleared = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionFocusChips(
            focus: const DashboardActionFocusState(
              hideCompleted: true,
              ownerLabel: 'People Ops',
              priority: DashboardActionPriority.critical,
              urgency: DashboardActionUrgencyTier.now,
              visibleCount: 2,
              totalCount: 5,
            ),
            onClearHideCompleted: () => cleared.add('done'),
            onClearUrgency: () => cleared.add('urgency'),
            onClearPriority: () => cleared.add('priority'),
            onClearOwner: () => cleared.add('owner'),
          ),
        ),
      ),
    );

    expect(find.text('Done hidden'), findsOneWidget);
    expect(find.text('Urgency: Due now'), findsOneWidget);
    expect(find.text('Priority: Critical'), findsOneWidget);
    expect(find.text('Owner: People Ops'), findsOneWidget);
    expect(find.byType(DashboardActionFocusChip), findsNWidgets(4));

    await tester.tap(find.byTooltip('Show done actions'));
    await tester.tap(find.byTooltip('Clear urgency focus'));
    await tester.tap(find.byTooltip('Clear priority focus'));
    await tester.tap(find.byTooltip('Clear owner focus'));
    await tester.pump();

    expect(cleared, ['done', 'urgency', 'priority', 'owner']);
  });

  testWidgets('action focus chips stay empty without active focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardActionFocusChips(
            focus: DashboardActionFocusState(
              hideCompleted: false,
              ownerLabel: dashboardActionAllOwners,
              priority: null,
              urgency: null,
              visibleCount: 5,
              totalCount: 5,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DashboardActionFocusChips), findsOneWidget);
    expect(find.byType(DashboardActionFocusChip), findsNothing);
    expect(find.text('Done hidden'), findsNothing);
  });
}
