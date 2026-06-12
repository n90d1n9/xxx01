import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_list_item_parts.dart';

void main() {
  test('workspace category label describes discovery groups', () {
    expect(
      dashboardWorkspaceCategoryLabel(DashboardWorkspaceCategory.strategic),
      'Strategic',
    );
    expect(
      dashboardWorkspaceCategoryLabel(DashboardWorkspaceCategory.operational),
      'Operational',
    );
  });

  testWidgets('workspace list identity parts render copy and risk signal', (
    tester,
  ) async {
    final entry = _entry(
      HrisWorkspaceId.peopleOps,
      riskSignal: const DashboardWorkspaceRiskSignal(
        severity: DashboardRiskSeverity.critical,
        totalRisks: 8,
        timeSensitiveRisks: 3,
        leadingSignal: '3 blocked onboarding',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: Row(
              children: [
                DashboardWorkspaceListIcon(entry: entry),
                const SizedBox(width: 12),
                Expanded(child: DashboardWorkspaceListCopy(entry: entry)),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.hub_outlined), findsOneWidget);
    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Workspace description'), findsOneWidget);
    expect(find.text('Strategic'), findsOneWidget);
    expect(find.text('Critical 8'), findsOneWidget);
  });

  testWidgets('workspace list metrics render compact metric chips', (
    tester,
  ) async {
    final entry = _entry(
      HrisWorkspaceId.attendance,
      metrics: const [
        DashboardWorkspaceMetric(
          icon: Icons.task_alt_outlined,
          label: 'Present',
          value: '18',
        ),
        DashboardWorkspaceMetric(
          icon: Icons.timelapse_outlined,
          label: 'Late',
          value: '2',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: DashboardWorkspaceListMetrics(entry: entry),
          ),
        ),
      ),
    );

    expect(find.text('Present'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Late'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}

DashboardWorkspaceEntry _entry(
  HrisWorkspaceId id, {
  DashboardWorkspaceRiskSignal? riskSignal,
  List<DashboardWorkspaceMetric> metrics = const [
    DashboardWorkspaceMetric(
      icon: Icons.analytics_outlined,
      label: 'Metric',
      value: '1',
    ),
  ],
}) {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(id),
    description: 'Workspace description',
    riskSignal: riskSignal,
    metrics: metrics,
  );
}
