import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_reconciliation_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_reconciliation_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance reconciliation panel renders evidence readiness', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 780,
              child: ProjectFinanceReconciliationPanel(
                summary: buildProjectFinanceReconciliationSummary(
                  _project(),
                  today: DateTime(2026, 6, 9),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Finance reconciliation blocked'), findsOneWidget);
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Clean'), findsWidgets);
    expect(find.text('Evidence'), findsWidgets);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Reconcile budget exception'), findsOneWidget);
    expect(find.text('Reconcile petty cash evidence'), findsOneWidget);
    expect(find.text('Complete reimbursement proof'), findsOneWidget);
    expect(find.textContaining('Owner: Sponsor'), findsOneWidget);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'project-reconciliation',
    name: 'Project Reconciliation',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: 0.42,
    budgetUsed: 0.74,
    health: ProjectHealth.atRisk,
    milestones: [
      ProjectMilestone(
        label: 'Pilot',
        dueDate: DateTime(2026, 6, 21),
        isComplete: false,
      ),
    ],
  );
}
