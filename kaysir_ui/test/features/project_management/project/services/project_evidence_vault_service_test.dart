import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_evidence_vault_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds review evidence vault for retail project proof', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectEvidenceVaultSummary(
      workspace,
      today: DateTime(2026, 6, 20),
    );

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectEvidenceVaultLevel.review);
    expect(summary.title, 'Evidence vault needs review');
    expect(summary.recordCount, greaterThan(8));
    expect(summary.reviewCount, greaterThan(0));
    expect(summary.blockedCount, 0);
    expect(summary.primaryRecord?.title, isNotEmpty);
    expect(
      summary.records.map((record) => record.title),
      containsAll([
        'Pilot branch training materials',
        'Pilot store project float',
        'Training delivery proof',
      ]),
    );
  });

  test('marks evidence vault blocked when proof or milestones are blocked', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectEvidenceVaultSummary(
      workspace,
      today: DateTime(2026, 7, 1),
    );

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectEvidenceVaultLevel.blocked);
    expect(summary.title, 'Evidence vault blocked');
    expect(summary.blockedCount, greaterThan(0));
    expect(summary.primaryRecord?.level, ProjectEvidenceVaultLevel.blocked);
    expect(
      summary.records.map((record) => record.title),
      contains('Freight exception evidence'),
    );
  });
}
