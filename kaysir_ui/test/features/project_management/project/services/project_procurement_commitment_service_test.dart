import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_procurement_commitment_service.dart';

void main() {
  test('builds review procurement commitments for retail vendor setup', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectProcurementCommitmentSummary(workspace);

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectProcurementCommitmentLevel.review);
    expect(summary.title, 'Procurement commitments need review');
    expect(summary.itemCount, greaterThanOrEqualTo(4));
    expect(summary.reviewCount, greaterThan(0));
    expect(summary.blockedCount, 0);
    expect(summary.commitmentAmountLabel, isNot('-'));
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Checkout and inventory systems',
        'Prepare vendor spend route',
        'Vendor commitment authority',
        'Validate vendor delivery proof',
      ]),
    );
  });

  test('blocks procurement commitments for warehouse spend escalation', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectProcurementCommitmentSummary(workspace);

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectProcurementCommitmentLevel.blocked);
    expect(summary.title, 'Procurement commitments blocked');
    expect(summary.blockedCount, greaterThan(0));
    expect(
      summary.primaryItem?.level,
      ProjectProcurementCommitmentLevel.blocked,
    );
    expect(summary.attentionAmountLabel, isNot('-'));
    expect(
      summary.items.map((item) => item.title),
      containsAll([
        'Sensors and scanners',
        'Integration vendor',
        'Vendor commitment authority',
        'Validate vendor delivery proof',
        'Device lead time',
      ]),
    );
  });
}
