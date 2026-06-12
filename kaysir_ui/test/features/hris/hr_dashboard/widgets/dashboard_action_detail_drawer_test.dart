import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_drawer.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_launcher.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action detail drawer renders detail workflow', (
    tester,
  ) async {
    final completed = <String>[];
    final detail = hrisDashboardCriticalDetail();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionDetailDrawer(
            detail: detail,
            onComplete: (action) => completed.add(action.id),
          ),
        ),
      ),
    );

    expect(find.text('Action detail'), findsOneWidget);
    expect(find.text(hrisDashboardCriticalActionTitle), findsOneWidget);
    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Section 1 of 5'), findsOneWidget);
    expect(find.byTooltip('Jump to overview'), findsOneWidget);
    expect(find.byTooltip('Jump to evidence'), findsOneWidget);
    expect(find.byTooltip('Jump to handoff'), findsOneWidget);
    expect(find.byTooltip('Jump to impact'), findsOneWidget);
    expect(find.byTooltip('Jump to playbook'), findsOneWidget);
    expect(find.text('Decision snapshot'), findsOneWidget);
    expect(find.text('Window'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('Execution'), findsOneWidget);
    expect(find.text('Work is moving'), findsOneWidget);
    expect(find.text('Evidence timeline'), findsOneWidget);
    expect(find.text('4 checkpoints'), findsOneWidget);
    expect(find.text('Signal captured'), findsOneWidget);
    expect(find.text('Owner accountable'), findsOneWidget);
    expect(find.text('Current playbook step'), findsOneWidget);
    expect(find.text('Outcome check'), findsOneWidget);
    expect(find.text('Recommended next step'), findsOneWidget);
    expect(find.text('Handoff brief'), findsOneWidget);
    expect(find.text('3 lines'), findsOneWidget);
    expect(find.text('Owner ask'), findsOneWidget);
    expect(find.text('Evidence to share'), findsOneWidget);
    expect(find.text('Review window'), findsOneWidget);
    expect(find.byTooltip('Copy handoff brief'), findsOneWidget);
    expect(find.byTooltip('Copy owner ask'), findsOneWidget);
    expect(find.byTooltip('Copy evidence to share'), findsOneWidget);
    expect(find.byTooltip('Copy review window'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
    expect(find.text('Owner'), findsWidgets);
    expect(find.text(hrisDashboardCriticalOwnerLabel), findsWidgets);
    expect(find.text(hrisDashboardCriticalDueLabel), findsWidgets);
    expect(find.text('Impact preview'), findsOneWidget);
    expect(find.text('Critical risk exposure'), findsOneWidget);
    expect(find.text('Lower critical workspace count'), findsWidgets);
    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('Guided playbook'), findsOneWidget);
    expect(find.text('Confirm risk owner'), findsOneWidget);
    expect(find.text('Sequence stabilization work'), findsWidgets);
    expect(find.text('Set review checkpoint'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Mark $hrisDashboardCriticalActionTitle done'),
    );
    await tester.pump();

    expect(completed, [hrisDashboardCriticalActionId]);
  });

  testWidgets('dashboard action detail drawer updates section progress', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DashboardActionDetailDrawer(detail: detail)),
      ),
    );

    expect(find.text('Section 1 of 5'), findsOneWidget);
    expect(
      find.text('Do next: Confirm the owner, due window, and risk level'),
      findsOneWidget,
    );
    expect(find.byTooltip('First section'), findsOneWidget);
    expect(find.byTooltip('Next section'), findsOneWidget);

    await tester.tap(find.byTooltip('Next section'));
    await tester.pumpAndSettle();

    expect(find.text('Section 2 of 5'), findsOneWidget);
    expect(
      find.text(
        'Do next: Share the evidence timeline with the accountable owner',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Evidence')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );

    await tester.tap(find.byTooltip('Previous section'));
    await tester.pumpAndSettle();

    expect(find.text('Section 1 of 5'), findsOneWidget);
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Overview')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2200),
    );
    await tester.pumpAndSettle();

    expect(find.text('Section 5 of 5'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to overview'));
    await tester.pumpAndSettle();

    expect(find.text('Section 1 of 5'), findsOneWidget);
    expect(
      tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Overview')),
      isA<ChoiceChip>().having((chip) => chip.selected, 'selected', isTrue),
    );
  });

  testWidgets('dashboard action details button opens the drawer', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail(
      status: DashboardActionStatus.open,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: DashboardActionDetailsButton(detail: detail)),
      ),
    );

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(find.text('Action detail'), findsOneWidget);
    expect(find.text(hrisDashboardCriticalActionTitle), findsOneWidget);
  });
}
