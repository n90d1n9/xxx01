import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail_snapshot.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_evidence_timeline.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_evidence_section.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_action_detail_overview_section.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  testWidgets('dashboard action overview section renders narrative context', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: DashboardActionDetailOverviewSection(
              detail: detail,
              snapshot: DashboardActionDetailSnapshot.fromDetail(detail),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Decision snapshot'), findsOneWidget);
    expect(find.text(hrisDashboardCriticalOwnerLabel), findsOneWidget);
    expect(
      find.text('5 critical workspaces need leadership attention.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Critical risk and total-risk pressure are high enough to require leadership attention before routine HR work.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('dashboard action evidence section renders signals and next step', (
    tester,
  ) async {
    final detail = hrisDashboardCriticalDetail();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 720,
              child: DashboardActionDetailEvidenceSection(
                detail: detail,
                timeline: DashboardActionEvidenceTimeline.fromDetail(detail),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Evidence timeline'), findsOneWidget);
    expect(find.text('4 checkpoints'), findsOneWidget);
    expect(find.text('Signal captured'), findsOneWidget);
    expect(find.text('Owner accountable'), findsOneWidget);
    expect(find.text('Recommended next step'), findsOneWidget);
    expect(
      find.text(
        'Open the linked workspace, confirm accountable leadership, and agree the first stabilization move.',
      ),
      findsOneWidget,
    );
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
  });
}
