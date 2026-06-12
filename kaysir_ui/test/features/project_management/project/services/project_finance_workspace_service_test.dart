import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds a complete finance workspace summary for a project', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );

    final summary = buildProjectFinanceWorkspaceSummary(project!);

    expect(summary.project.id, 'retail-modernization');
    expect(summary.budgetOverview.projectId, project.id);
    expect(summary.financeLedger.projectId, project.id);
    expect(summary.financeControls.projectId, project.id);
    expect(summary.costStructure.projectId, project.id);
    expect(summary.expenseIntake.projectId, project.id);
    expect(summary.spendAuthority.projectId, project.id);
    expect(summary.cashFlowForecast.projectId, project.id);
    expect(summary.financeReconciliation.projectId, project.id);
    expect(summary.financeLedger.budgetLineCount, greaterThan(0));
    expect(summary.expenseIntake.routeCount, greaterThan(0));
    expect(summary.spendAuthority.ruleCount, greaterThan(0));
    expect(summary.cashFlowForecast.windowCount, greaterThan(0));
    expect(summary.financeReconciliation.itemCount, greaterThan(0));
  });
}
