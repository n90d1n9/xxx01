import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_risk_rollup_panel.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_risk_severity_summary.dart';

void main() {
  testWidgets('risk rollup action opens the selected workspace', (
    tester,
  ) async {
    final rollup = DashboardRiskRollup(
      items: [
        DashboardRiskItem(
          workspace: hrisWorkspaceById(HrisWorkspaceId.manager),
          totalRisks: 12,
          timeSensitiveRisks: 4,
          leadingSignal: '2 urgent approvals',
        ),
        DashboardRiskItem(
          workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
          totalRisks: 7,
          timeSensitiveRisks: 6,
          leadingSignal: '1 blocked onboarding',
        ),
        DashboardRiskItem(
          workspace: hrisWorkspaceById(HrisWorkspaceId.payroll),
          totalRisks: 6,
          timeSensitiveRisks: 3,
          leadingSignal: '3 pending payments',
        ),
        DashboardRiskItem(
          workspace: hrisWorkspaceById(HrisWorkspaceId.employeeDirectory),
          totalRisks: 3,
          timeSensitiveRisks: 1,
          leadingSignal: '1 watchlist profile',
        ),
      ],
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => Scaffold(
                body: SingleChildScrollView(
                  child: DashboardRiskRollupPanel(rollup: rollup),
                ),
              ),
        ),
        GoRoute(
          path: '/manager',
          builder:
              (context, state) =>
                  const Scaffold(body: Text('Manager workspace opened')),
        ),
        GoRoute(
          path: '/employee',
          builder:
              (context, state) => const Scaffold(
                body: Text('Employee directory workspace opened'),
              ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.byType(DashboardRiskSeveritySummary), findsOneWidget);
    expect(find.text('Critical'), findsNWidgets(2));
    expect(find.text('Elevated'), findsNWidgets(3));
    expect(find.text('Stable'), findsOneWidget);
    expect(find.text('View all 4 workspaces'), findsOneWidget);
    expect(find.text('Employee Directory'), findsNothing);

    await tester.tap(find.text('View all 4 workspaces'));
    await tester.pumpAndSettle();

    expect(find.text('Risk queue'), findsOneWidget);
    expect(find.text('Employee Directory'), findsOneWidget);

    await tester.tap(find.byTooltip('Open Employee Directory workspace'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/employee');
    expect(find.text('Employee directory workspace opened'), findsOneWidget);

    router.go('/');
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open Manager workspace'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/manager');
    expect(find.text('Manager workspace opened'), findsOneWidget);
  });
}
