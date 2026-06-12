import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_approval_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_approval_workspace_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('approval workspace panel renders approval queue', (
    tester,
  ) async {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectApprovalWorkspaceSummary(workspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 1040,
              child: ProjectApprovalWorkspacePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Approval route blocked'), findsOneWidget);
    expect(find.text('Approval readiness'), findsOneWidget);
    expect(find.text('Budget variance recovery request'), findsOneWidget);
    expect(find.text('Freight acceleration exception'), findsOneWidget);
    expect(find.text('Resolve block'), findsOneWidget);
    expect(find.text('Budget Change'), findsWidgets);
  });
}
