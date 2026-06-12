import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_handoff_pack_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds review handoff pack for retail finance workspace', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final pack = buildProjectFinanceHandoffPackSummary(workspace);

    expect(pack.projectId, 'retail-modernization');
    expect(pack.packageId, 'retail-modernization-finance-handoff');
    expect(pack.sectionCount, 6);
    expect(pack.blockedCount, 0);
    expect(pack.reviewCount, greaterThan(0));
    expect(pack.level, ProjectFinanceHandoffPackLevel.review);
    expect(
      pack.recipients,
      containsAll(['Maya Santoso', 'Retail Operations', 'Kaysir Retail']),
    );
    expect(
      pack.briefText,
      contains('Finance handoff pack - Retail Modernization'),
    );
    expect(pack.briefText, contains('Recovery Plan'));
    expect(pack.briefText, contains('Store Cluster: Jakarta pilot'));
  });

  test('marks handoff pack blocked when finance evidence is blocked', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final pack = buildProjectFinanceHandoffPackSummary(workspace);

    expect(pack.projectId, 'warehouse-automation');
    expect(pack.level, ProjectFinanceHandoffPackLevel.blocked);
    expect(pack.blockedCount, greaterThan(0));
    expect(pack.primarySection?.level, ProjectFinanceHandoffPackLevel.blocked);
    expect(pack.briefText, contains('Warehouse Automation'));
  });
}
