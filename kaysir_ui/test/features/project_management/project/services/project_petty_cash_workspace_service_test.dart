import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_petty_cash_workspace_service.dart';

void main() {
  test('builds active petty cash workspace for retail project float', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectPettyCashWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 20),
    );

    expect(summary.projectId, 'retail-modernization');
    expect(summary.title, 'Petty cash reconciliation active');
    expect(summary.level, ProjectPettyCashWorkspaceLevel.review);
    expect(summary.entryCount, 1);
    expect(summary.openCount, 1);
    expect(summary.blockedCount, 0);
    expect(summary.dueSoonCount, 1);
    expect(summary.openFloatAmountLabel, '5.0M');
    expect(summary.primaryEntry?.title, 'Pilot store project float');
    expect(summary.primaryEntry?.actionLabel, 'Attach receipts');
    expect(summary.controls.length, 3);
  });

  test('marks petty cash workspace blocked when project float is blocked', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectPettyCashWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 20),
    );

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.title, 'Petty cash blocked');
    expect(summary.level, ProjectPettyCashWorkspaceLevel.blocked);
    expect(summary.blockedCount, 1);
    expect(summary.primaryEntry?.title, 'Fulfillment floor float');
    expect(summary.primaryEntry?.actionLabel, 'Resolve block');
  });
}
