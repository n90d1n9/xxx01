import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_closeout_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds attention closeout checklist for active retail finance', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final closeout = buildProjectFinanceCloseoutSummary(workspace);

    expect(closeout.projectId, 'retail-modernization');
    expect(closeout.checkCount, 6);
    expect(closeout.readyCount, 1);
    expect(closeout.attentionCount, 5);
    expect(closeout.blockedCount, 0);
    expect(closeout.completionPercent, 17);
    expect(closeout.level, ProjectFinanceCloseoutLevel.attention);
    expect(closeout.title, 'Finance closeout needs attention');
    expect(closeout.primaryCheck?.title, 'Ledger records');
  });

  test(
    'marks blocked finance closeout when ledger and authority are blocked',
    () {
      final project = const ProjectPortfolioRepository().findById(
        'warehouse-automation',
      );
      final workspace = buildProjectFinanceWorkspaceSummary(project!);

      final closeout = buildProjectFinanceCloseoutSummary(workspace);

      expect(closeout.projectId, 'warehouse-automation');
      expect(closeout.blockedCount, greaterThan(0));
      expect(closeout.level, ProjectFinanceCloseoutLevel.blocked);
      expect(closeout.title, 'Finance closeout blocked');
      expect(closeout.primaryCheck?.level, ProjectFinanceCloseoutLevel.blocked);
    },
  );
}
