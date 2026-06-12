import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_empty_guidance.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_recovery_options.dart';

void main() {
  test('workspace recovery icons match each recovery action', () {
    expect(
      dashboardWorkspaceRecoveryIcon(
        DashboardWorkspaceRecoveryAction.clearSearch,
      ),
      Icons.search_off_outlined,
    );
    expect(
      dashboardWorkspaceRecoveryIcon(
        DashboardWorkspaceRecoveryAction.clearFilter,
      ),
      Icons.filter_alt_off_outlined,
    );
    expect(
      dashboardWorkspaceRecoveryIcon(
        DashboardWorkspaceRecoveryAction.clearSort,
      ),
      Icons.sort_by_alpha_outlined,
    );
    expect(
      dashboardWorkspaceRecoveryIcon(DashboardWorkspaceRecoveryAction.reset),
      Icons.restart_alt_rounded,
    );
  });

  testWidgets('workspace recovery options render and delegate actions', (
    tester,
  ) async {
    final invokedActions = <DashboardWorkspaceRecoveryAction>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardWorkspaceRecoveryOptions(
            options: const [
              DashboardWorkspaceRecoveryOption(
                action: DashboardWorkspaceRecoveryAction.clearSearch,
                label: 'Clear search',
                detail: 'Remove search term.',
              ),
              DashboardWorkspaceRecoveryOption(
                action: DashboardWorkspaceRecoveryAction.clearFilter,
                label: 'Clear filter',
                detail: 'Return to all workspaces.',
              ),
              DashboardWorkspaceRecoveryOption(
                action: DashboardWorkspaceRecoveryAction.reset,
                label: 'Reset discovery',
                detail: 'Clear every active discovery control.',
              ),
            ],
            onAction:
                (action) => () {
                  invokedActions.add(action);
                },
          ),
        ),
      ),
    );

    expect(find.text('Clear search'), findsOneWidget);
    expect(find.text('Clear filter'), findsOneWidget);
    expect(find.text('Reset discovery'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

    await tester.tap(find.text('Clear search'));
    await tester.tap(find.text('Clear filter'));
    await tester.tap(find.text('Reset discovery'));

    expect(invokedActions, [
      DashboardWorkspaceRecoveryAction.clearSearch,
      DashboardWorkspaceRecoveryAction.clearFilter,
      DashboardWorkspaceRecoveryAction.reset,
    ]);
  });
}
