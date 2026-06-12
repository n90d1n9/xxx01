import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_handoff_brief.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_handoff_brief_card.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('handoff brief card copies formatted owner note', (tester) async {
    final copiedNotes = <String>[];
    final brief = DashboardActionHandoffBrief.fromDetail(
      hrisDashboardCriticalDetail(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionHandoffBriefCard(
            brief: brief,
            onCopy: copiedNotes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Copy handoff brief'));
    await tester.pump();

    expect(copiedNotes, hasLength(1));
    expect(
      copiedNotes.single,
      contains('Handoff: $hrisDashboardCriticalActionTitle'),
    );
    expect(
      copiedNotes.single,
      contains('Owner ask: $hrisDashboardCriticalOwnerLabel'),
    );
    expect(copiedNotes.single, contains('Evidence to share: 5 Critical'));
    expect(find.text('Handoff brief copied'), findsOneWidget);
  });

  testWidgets('handoff brief card copies individual handoff lines', (
    tester,
  ) async {
    final copiedNotes = <String>[];
    final brief = DashboardActionHandoffBrief.fromDetail(
      hrisDashboardCriticalDetail(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardActionHandoffBriefCard(
            brief: brief,
            onCopy: copiedNotes.add,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Copy owner ask'));
    await tester.pump();

    expect(copiedNotes, hasLength(1));
    expect(
      copiedNotes.single,
      startsWith('Owner ask: $hrisDashboardCriticalOwnerLabel'),
    );
    expect(copiedNotes.single, contains('Open the linked workspace'));
    expect(find.text('Owner ask copied'), findsOneWidget);
  });
}
