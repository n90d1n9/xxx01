import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_procurement_commitment_service.dart';
import 'package:kaysir/features/project_management/project/services/project_procurement_request_flow_service.dart';

void main() {
  test('procurement request flow validates and queues a request', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectProcurementCommitmentSummary(workspace);
    const service = ProjectProcurementRequestFlowService();
    final initialDraft = service.initialDraft(summary);

    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      kind: ProjectProcurementCommitmentKind.budgetPackage,
      title: 'Scanner supplier purchase request',
      vendor: 'PT Sensor Integrasi',
      owner: 'Supply Chain Owner',
      amountText: '45000000',
      scopeNote:
          'Procure scanners, mounting accessories, freight handling, and onsite installation coordination.',
      evidenceNote:
          'Attach supplier quotation, purchase reason, delivery lead time, and warehouse acceptance checklist.',
    );
    final submission = service.submit(
      summary: summary,
      draft: draft,
      queueIndex: 1,
    );

    expect(submission.item.title, 'Scanner supplier purchase request');
    expect(
      submission.item.kind,
      ProjectProcurementCommitmentKind.budgetPackage,
    );
    expect(submission.item.amountLabel, '45.0M');
    expect(submission.routeLabel, 'Procurement hold');
    expect(submission.item.sourceLabel, 'PT Sensor Integrasi');
    expect(submission.summaryText, contains('Procurement request'));
    expect(submission.summaryText, contains('Supply Chain Owner'));
  });
}
