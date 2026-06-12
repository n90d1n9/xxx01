import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_finance_ledger.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_petty_cash_request_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_petty_cash_workspace_service.dart';

void main() {
  test('petty cash request intake validates and submits a float request', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectPettyCashWorkspaceSummary(
      financeWorkspace,
      today: DateTime(2026, 6, 20),
    );
    const service = ProjectPettyCashRequestIntakeService();
    final initialDraft = service.initialDraft(summary);

    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      title: 'Pilot store replenishment float',
      custodian: 'Maya Santoso',
      amountText: '1250000',
      purpose: ProjectPettyCashRequestPurpose.fieldOperations,
      evidenceNote:
          'Receipts will be attached by store custodian with branch purpose and reconciliation date.',
    );
    final submission = service.submit(
      summary: summary,
      draft: draft,
      queueIndex: 1,
    );

    expect(submission.entry.title, 'Pilot store replenishment float');
    expect(submission.entry.status, ProjectFinanceRecordStatus.submitted);
    expect(submission.entry.amount, 1250000);
    expect(submission.amountLabel, '1.3M');
    expect(submission.routeLabel, 'Custodian review');
    expect(submission.summaryText, contains('Petty cash request'));
    expect(submission.summaryText, contains('Maya Santoso'));
  });
}
