import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_card.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_card_parts.dart';

void main() {
  testWidgets('workspace card renders and opens the workspace route', (
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
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => Scaffold(
                body: SizedBox(
                  width: 360,
                  height: 220,
                  child: DashboardWorkspaceCard(entry: entry),
                ),
              ),
        ),
        GoRoute(
          path: entry.path,
          builder:
              (context, state) =>
                  const Scaffold(body: Text('People Ops opened')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('People Operations'), findsOneWidget);
    expect(find.text('Workspace description'), findsOneWidget);
    expect(find.text('Critical 8'), findsOneWidget);
    expect(find.text('Metric'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('workspace-card-${entry.path}')));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, entry.path);
    expect(find.text('People Ops opened'), findsOneWidget);
  });

  testWidgets('workspace card header hides a stable risk badge', (
    tester,
  ) async {
    final entry = _entry(
      HrisWorkspaceId.leave,
      riskSignal: const DashboardWorkspaceRiskSignal(
        severity: DashboardRiskSeverity.stable,
        totalRisks: 1,
        timeSensitiveRisks: 0,
        leadingSignal: '1 balance warning',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: DashboardWorkspaceCardHeader(entry: entry),
          ),
        ),
      ),
    );

    expect(find.text('Leave'), findsOneWidget);
    expect(find.text('Stable 1'), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('workspace card metrics render full metric chips', (
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
            width: 360,
            child: DashboardWorkspaceCardMetrics(entry: entry),
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
