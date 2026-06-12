import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_change_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_change_workspace_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('budget change workspace panel renders request queue', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectBudgetChangeWorkspaceSummary(workspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: ProjectBudgetChangeWorkspacePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Budget change approval blocked'), findsOneWidget);
    expect(find.text('Budget variance recovery request'), findsOneWidget);
    expect(find.text('Evidence-bound budget change'), findsOneWidget);
    expect(find.text('Maintain budget change log'), findsOneWidget);
    expect(find.textContaining('Approval:'), findsWidgets);
  });
}
