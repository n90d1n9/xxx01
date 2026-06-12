import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_issue_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_issue_workspace_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('risk issue panel renders critical recovery queue', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectRiskIssueWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 11),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1040,
              child: ProjectRiskIssueWorkspacePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Risk and issues critical'), findsOneWidget);
    expect(find.text('Risk readiness'), findsOneWidget);
    expect(find.text('Budget overrun risk'), findsOneWidget);
    expect(find.text('Spend escalation required'), findsOneWidget);
    expect(find.text('Recover budget'), findsOneWidget);
    expect(find.text('Cash Flow'), findsWidgets);
  });
}
