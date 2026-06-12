import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_change_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds review budget changes for retail evidence movement', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectBudgetChangeWorkspaceSummary(workspace);

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectBudgetChangeLevel.review);
    expect(summary.title, 'Budget changes need review');
    expect(summary.requestCount, 3);
    expect(summary.reviewCount, greaterThanOrEqualTo(1));
    expect(summary.blockedCount, 0);
    expect(
      summary.requests.map((request) => request.title),
      containsAll([
        'Evidence-bound budget change',
        'Contingency release request',
        'Maintain budget change log',
      ]),
    );
  });

  test('blocks budget changes when warehouse budget variance is critical', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectBudgetChangeWorkspaceSummary(workspace);

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectBudgetChangeLevel.blocked);
    expect(summary.title, 'Budget change approval blocked');
    expect(summary.blockedCount, greaterThan(0));
    expect(summary.primaryRequest?.title, 'Budget variance recovery request');
    expect(summary.requestedAmountTotalLabel, isNot('-'));
  });
}
