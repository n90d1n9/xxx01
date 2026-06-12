import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_issue_workspace_service.dart';

void main() {
  test('builds watch risk issues for retail project signals', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectRiskIssueWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 11),
    );

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectRiskIssueLevel.watch);
    expect(summary.title, 'Risk and issues need review');
    expect(summary.activeCount, greaterThan(0));
    expect(summary.criticalCount, 0);
    expect(summary.watchCount, greaterThan(0));
    expect(summary.exposureScore, greaterThan(0));
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Store readiness',
        'Pilot milestone',
        'Spend authority needs setup',
      ]),
    );
  });

  test('builds critical risk issues for warehouse recovery signals', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectRiskIssueWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 11),
    );

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectRiskIssueLevel.critical);
    expect(summary.title, 'Risk and issues critical');
    expect(summary.criticalCount, greaterThan(0));
    expect(summary.primaryItem?.level, ProjectRiskIssueLevel.critical);
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Budget overrun risk',
        'Spend escalation required',
        'Cash flow constrained',
        'Device lead time',
      ]),
    );
  });
}
