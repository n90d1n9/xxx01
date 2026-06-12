import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_portfolio_triage_service.dart';

void main() {
  test('builds sorted portfolio finance triage summary', () {
    final projects = const ProjectPortfolioRepository().fetchProjects();

    final summary = buildProjectFinancePortfolioTriageSummary(projects);

    expect(summary.projectCount, 4);
    expect(summary.actionCount, 9);
    expect(summary.criticalActionCount, 4);
    expect(summary.openLedgerCount, 9);
    expect(summary.blockedLedgerCount, 4);
    expect(summary.criticalProjectCount, 1);
    expect(summary.level, ProjectFinancePortfolioTriageLevel.critical);
    expect(summary.title, 'Portfolio finance needs intervention');
    expect(summary.entries.first.projectId, 'warehouse-automation');
    expect(
      summary.entries.first.level,
      ProjectFinancePortfolioTriageLevel.critical,
    );
    expect(summary.entries.first.primaryActionTitle, contains('Unblock'));
  });
}
