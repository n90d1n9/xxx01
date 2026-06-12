import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_entry.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_attention_spotlight.dart';

void main() {
  testWidgets('workspace attention spotlight renders and focuses attention', (
    tester,
  ) async {
    var focusCount = 0;

    await _pumpSpotlight(
      tester,
      entry: _entryWithRisk(),
      onFocusAttention: () => focusCount++,
    );

    expect(find.text('Top attention'), findsOneWidget);
    expect(find.text('Top attention: People Operations'), findsOneWidget);
    expect(
      find.text('3 blocked onboarding - 3 time-sensitive'),
      findsOneWidget,
    );
    expect(find.text('Critical 8'), findsOneWidget);
    expect(find.text('Show attention'), findsOneWidget);
    expect(find.text('Open People Operations'), findsOneWidget);

    await tester.tap(find.text('Show attention'));
    await tester.pump();

    expect(focusCount, 1);
  });

  testWidgets('workspace attention spotlight opens the workspace route', (
    tester,
  ) async {
    final entry = _entryWithRisk();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => Scaffold(
                body: SizedBox(
                  width: 900,
                  child: DashboardWorkspaceAttentionSpotlight(
                    entry: entry,
                    onFocusAttention: () {},
                  ),
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

    await tester.tap(find.text('Open People Operations'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, entry.path);
    expect(find.text('People Ops opened'), findsOneWidget);
  });

  testWidgets(
    'workspace attention spotlight stays hidden without a risk signal',
    (tester) async {
      await _pumpSpotlight(
        tester,
        entry: _entryWithoutRisk(),
        onFocusAttention: () {},
      );

      expect(find.text('Top attention'), findsNothing);
      expect(find.text('Open People Operations'), findsNothing);
    },
  );
}

Future<void> _pumpSpotlight(
  WidgetTester tester, {
  required DashboardWorkspaceEntry entry,
  required VoidCallback onFocusAttention,
  double width = 900,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: DashboardWorkspaceAttentionSpotlight(
            entry: entry,
            onFocusAttention: onFocusAttention,
          ),
        ),
      ),
    ),
  );
}

DashboardWorkspaceEntry _entryWithRisk() {
  return DashboardWorkspaceEntry(
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
  );
}

DashboardWorkspaceEntry _entryWithoutRisk() {
  return DashboardWorkspaceEntry(
    workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
    description: 'Strategic HR operations',
    metrics: const [
      DashboardWorkspaceMetric(
        icon: Icons.person_search_outlined,
        label: 'Hires',
        value: '3',
      ),
    ],
  );
}
