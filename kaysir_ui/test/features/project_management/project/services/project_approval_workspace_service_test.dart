import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_approval_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds review approval queue for retail project controls', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectApprovalWorkspaceSummary(workspace);

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectApprovalWorkspaceLevel.review);
    expect(summary.title, 'Approvals need review');
    expect(summary.itemCount, greaterThan(4));
    expect(summary.readyCount, greaterThan(0));
    expect(summary.reviewCount, greaterThan(0));
    expect(summary.blockedCount, 0);
    expect(summary.totalAmountLabel, isNot('-'));
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Training materials approval',
        'Contingency release request',
        'Reconcile petty cash evidence',
      ]),
    );
  });

  test('blocks approval queue when warehouse exception is unresolved', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectApprovalWorkspaceSummary(workspace);

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectApprovalWorkspaceLevel.blocked);
    expect(summary.title, 'Approval route blocked');
    expect(summary.blockedCount, greaterThan(0));
    expect(summary.primaryItem?.level, ProjectApprovalWorkspaceLevel.blocked);
    expect(summary.primaryItem?.title, 'Budget variance recovery request');
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Budget variance recovery request',
        'Freight acceleration exception',
        'Reconcile budget exception',
      ]),
    );
  });
}
