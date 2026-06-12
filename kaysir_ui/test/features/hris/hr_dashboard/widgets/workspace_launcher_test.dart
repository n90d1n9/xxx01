import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/workspace_launcher.dart';

void main() {
  testWidgets('workspace launcher filters entries by category', (tester) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 late record',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Strategic 1'), findsOneWidget);
    expect(find.text('Operational 1'), findsOneWidget);
    expect(find.text('Attention 2'), findsOneWidget);
    expect(find.text('Time-sensitive 2'), findsOneWidget);
    expect(find.text('Critical 1'), findsOneWidget);
    expect(find.text('Elevated 1'), findsOneWidget);
    expect(find.text('Sort: Recommended'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('All workspaces'), findsOneWidget);
    expect(find.text('2 of 2 in scope'), findsOneWidget);
    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('Top attention'), findsOneWidget);
    expect(find.text('Top attention: People Operations'), findsOneWidget);
    expect(
      find.text('3 blocked onboarding - 3 time-sensitive'),
      findsOneWidget,
    );
    expect(find.text('In view'), findsOneWidget);
    expect(find.text('2 need attention'), findsOneWidget);
    expect(find.text('1 critical'), findsOneWidget);
    expect(find.text('1 elevated'), findsOneWidget);
    expect(find.text('4 time-sensitive'), findsOneWidget);
    expect(find.text('12 total risks'), findsOneWidget);
    expect(find.text('Next focus: People Operations'), findsOneWidget);
    expect(find.text('Critical 8'), findsWidgets);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Critical 1');

    expect(find.text('Showing 1 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Critical'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsNothing);

    await _tapVisibleText(tester, 'Elevated 1');

    expect(find.text('Showing 1 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Elevated'), findsOneWidget);
    expect(find.text('People Operations'), findsNothing);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'All 2');

    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Elevated'), findsNothing);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Show attention');

    expect(find.text('Sort: Risk pressure'), findsOneWidget);
    expect(find.text('Risk pressure order'), findsOneWidget);
    expect(find.text('Risk focus'), findsOneWidget);
    expect(
      find.text('2 of 2 in scope - Attention, Risk pressure'),
      findsOneWidget,
    );
    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Attention'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove workspace filter'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Attention'), findsNothing);
    expect(find.text('Risk pressure order'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove workspace sort'));
    await tester.pumpAndSettle();

    expect(find.text('Sort: Recommended'), findsOneWidget);
    expect(find.text('Risk pressure order'), findsNothing);

    await tester.enterText(find.byType(TextField), 'attendance');
    await tester.pumpAndSettle();

    expect(find.text('Showing 1 of 2 workspaces'), findsOneWidget);
    expect(find.text('Search: attendance'), findsOneWidget);
    expect(find.text('1 of 2 in scope - Search "attendance"'), findsOneWidget);
    expect(find.text('Next focus: Attendance'), findsOneWidget);
    expect(find.text('People Operations'), findsNothing);
    expect(find.text('Attendance'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove search constraint'));
    await tester.pumpAndSettle();

    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Attention 2');

    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('Filter: Attention'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Operational 1');

    expect(find.text('People Operations'), findsNothing);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Strategic 1');

    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsNothing);

    await tester.enterText(find.byType(TextField), 'not-a-workspace');
    await tester.pumpAndSettle();

    expect(find.text('People Operations'), findsNothing);
    expect(find.text('No match in Strategic'), findsOneWidget);
    expect(
      find.text('The search term does not match the selected workspace scope.'),
      findsOneWidget,
    );
    expect(find.text('Search: not-a-workspace'), findsWidgets);
    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('Clear filter'), findsOneWidget);
    expect(find.text('Reset discovery'), findsOneWidget);

    await tester.ensureVisible(find.text('Reset discovery'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset discovery'));
    await tester.pumpAndSettle();

    expect(find.text('Showing 2 of 2 workspaces'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
  });

  testWidgets('workspace launcher can sort entries by name', (tester) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Sort workspaces'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name A-Z'));
    await tester.pumpAndSettle();

    expect(find.text('Sort: Name A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Attendance')).dx,
      lessThan(tester.getTopLeft(find.text('People Operations')).dx),
    );
  });

  testWidgets('workspace launcher can switch to compact list view', (
    tester,
  ) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('workspace-card-/hris-people-ops')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-list-/hris-people-ops')),
      findsNothing,
    );

    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('workspace-card-/hris-people-ops')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('workspace-list-/hris-people-ops')),
      findsOneWidget,
    );
    expect(find.text('Strategic'), findsOneWidget);
    expect(find.text('Operational'), findsOneWidget);
  });

  testWidgets('workspace launcher applies saved workspace views', (
    tester,
  ) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 late record',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Saved views'), findsOneWidget);
    expect(find.text('Command center'), findsOneWidget);
    expect(find.text('Critical risks'), findsOneWidget);
    expect(find.text('Operational queue'), findsOneWidget);

    await _tapVisibleText(tester, 'Operational queue');

    expect(find.text('Filter: Operational'), findsOneWidget);
    expect(find.text('Category order'), findsOneWidget);
    expect(find.text('Showing 1 of 2 workspaces'), findsOneWidget);
    expect(find.text('People Operations'), findsNothing);
    expect(find.text('Attendance'), findsOneWidget);

    await _tapVisibleText(tester, 'Critical risks');

    expect(find.text('Filter: Critical'), findsOneWidget);
    expect(find.text('Risk pressure order'), findsOneWidget);
    expect(find.text('Critical workspaces'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('workspace-list-/hris-people-ops')),
      findsOneWidget,
    );
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsNothing);
  });

  testWidgets('workspace launcher triage strip focuses risk queues', (
    tester,
  ) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 late record',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.leave),
        description: 'Leave requests and balances',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.event_available_outlined,
            label: 'Pending',
            value: '0',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    await _tapVisibleText(tester, 'Risk pressure');

    expect(find.text('Sort: Risk pressure'), findsOneWidget);
    expect(find.text('Filter: Critical'), findsOneWidget);
    expect(find.text('Showing 1 of 3 workspaces'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsNothing);

    await _tapVisibleText(tester, 'Time-sensitive');

    expect(find.text('Filter: Time-sensitive'), findsOneWidget);
    expect(find.text('Sort: Risk pressure'), findsOneWidget);
    expect(find.text('Showing 2 of 3 workspaces'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Leave'), findsNothing);

    await _tapVisibleText(tester, 'Next focus: People Operations');

    expect(find.text('Sort: Risk pressure'), findsOneWidget);
    expect(find.text('Filter: Attention'), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
  });

  testWidgets('workspace launcher groups list view by risk severity', (
    tester,
  ) async {
    final entries = [
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        description: 'Strategic HR operations',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.critical,
          totalRisks: 8,
          timeSensitiveRisks: 3,
          leadingSignal: '3 blocked onboarding',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.person_search_outlined,
            label: 'Hires',
            value: '3',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        description: 'Operational attendance records',
        riskSignal: const DashboardWorkspaceRiskSignal(
          severity: DashboardRiskSeverity.elevated,
          totalRisks: 4,
          timeSensitiveRisks: 1,
          leadingSignal: '1 late record',
        ),
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.timelapse_outlined,
            label: 'Late',
            value: '1',
          ),
        ],
      ),
      DashboardWorkspaceEntry(
        workspace: hrisWorkspaceById(HrisWorkspaceId.leave),
        description: 'Leave requests and balances',
        metrics: const [
          DashboardWorkspaceMetric(
            icon: Icons.event_available_outlined,
            label: 'Pending',
            value: '0',
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: WorkspaceLauncher(entries: entries),
            ),
          ),
        ),
      ),
    );

    await _tapVisibleText(tester, 'Show attention');
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();

    expect(find.text('Critical workspaces'), findsOneWidget);
    expect(find.text('Elevated workspaces'), findsOneWidget);
    expect(find.text('Stable workspaces'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Critical workspaces')).dy,
      lessThan(tester.getTopLeft(find.text('Elevated workspaces')).dy),
    );
  });
}

Future<void> _tapVisibleText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
