import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_triage_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_triage_strip.dart';

void main() {
  testWidgets(
    'workspace triage strip renders summary tiles and delegates taps',
    (tester) async {
      var riskTapCount = 0;
      var timeTapCount = 0;
      var nextTapCount = 0;

      await _pumpTriageStrip(
        tester,
        width: 900,
        summary: _summaryWithRisk(),
        onRiskPressureTap: () => riskTapCount++,
        onTimeSensitiveTap: () => timeTapCount++,
        onNextFocusTap: () => nextTapCount++,
      );

      expect(find.text('In view'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('2 need attention'), findsOneWidget);
      expect(find.text('Risk pressure'), findsOneWidget);
      expect(find.text('1 critical'), findsOneWidget);
      expect(find.text('1 elevated'), findsOneWidget);
      expect(find.text('Time-sensitive'), findsOneWidget);
      expect(find.text('4 time-sensitive'), findsOneWidget);
      expect(find.text('12 total risks'), findsOneWidget);
      expect(find.text('Next focus: People Operations'), findsOneWidget);
      expect(find.text('3 blocked onboarding'), findsOneWidget);

      await tester.tap(find.byTooltip('Show highest risk pressure'));
      await tester.tap(find.byTooltip('Show attention queue'));
      await tester.tap(find.byTooltip('Show next focus queue'));
      await tester.pump();

      expect(riskTapCount, 1);
      expect(timeTapCount, 1);
      expect(nextTapCount, 1);
    },
  );

  testWidgets('workspace triage strip renders compact stable state inertly', (
    tester,
  ) async {
    await _pumpTriageStrip(
      tester,
      width: 420,
      summary: DashboardWorkspaceTriageSummary.fromEntries([
        _entry(HrisWorkspaceId.attendance),
      ]),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('All stable'), findsOneWidget);
    expect(find.text('0 critical'), findsOneWidget);
    expect(find.text('0 elevated'), findsOneWidget);
    expect(find.text('0 time-sensitive'), findsOneWidget);
    expect(find.text('0 total risks'), findsOneWidget);
    expect(find.text('Next focus: Stable'), findsOneWidget);
    expect(find.text('No escalation queued'), findsOneWidget);
    expect(find.byTooltip('Show highest risk pressure'), findsNothing);
    expect(find.byTooltip('Show attention queue'), findsNothing);
    expect(find.byTooltip('Show next focus queue'), findsNothing);
  });
}

Future<void> _pumpTriageStrip(
  WidgetTester tester, {
  required DashboardWorkspaceTriageSummary summary,
  required double width,
  VoidCallback? onRiskPressureTap,
  VoidCallback? onTimeSensitiveTap,
  VoidCallback? onNextFocusTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: DashboardWorkspaceTriageStrip(
            summary: summary,
            onRiskPressureTap: onRiskPressureTap,
            onTimeSensitiveTap: onTimeSensitiveTap,
            onNextFocusTap: onNextFocusTap,
          ),
        ),
      ),
    ),
  );
}

DashboardWorkspaceTriageSummary _summaryWithRisk() {
  return DashboardWorkspaceTriageSummary.fromEntries([
    _entry(
      HrisWorkspaceId.peopleOps,
      riskSignal: const DashboardWorkspaceRiskSignal(
        severity: DashboardRiskSeverity.critical,
        totalRisks: 8,
        timeSensitiveRisks: 3,
        leadingSignal: '3 blocked onboarding',
      ),
    ),
    _entry(
      HrisWorkspaceId.attendance,
      riskSignal: const DashboardWorkspaceRiskSignal(
        severity: DashboardRiskSeverity.elevated,
        totalRisks: 4,
        timeSensitiveRisks: 1,
        leadingSignal: '1 late record',
      ),
    ),
  ]);
}

DashboardWorkspaceEntry _entry(
  HrisWorkspaceId id, {
  DashboardWorkspaceRiskSignal? riskSignal,
}) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    riskSignal: riskSignal,
    metrics: const [
      DashboardWorkspaceMetric(
        icon: Icons.analytics_outlined,
        label: 'Open',
        value: '1',
      ),
    ],
  );
}
