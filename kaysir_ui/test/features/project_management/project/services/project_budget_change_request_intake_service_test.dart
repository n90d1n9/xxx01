import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_change_request_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_change_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('budget change request intake validates and queues a variation', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectBudgetChangeWorkspaceSummary(financeWorkspace);
    const service = ProjectBudgetChangeRequestIntakeService();
    final initialDraft = service.initialDraft(summary);

    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      kind: ProjectBudgetChangeKind.varianceRecovery,
      title: 'Sensor freight recovery variation',
      owner: 'Rafi Prakoso',
      amountText: '18000000',
      impactNote:
          'Recover freight acceleration cost by moving low-priority installation scope into the next baseline cycle.',
      evidenceNote:
          'Attach supplier quote, sponsor approval, variance reason, and funding source before release.',
    );
    final submission = service.submit(
      summary: summary,
      draft: draft,
      queueIndex: 1,
    );

    expect(submission.request.title, 'Sensor freight recovery variation');
    expect(submission.request.kind, ProjectBudgetChangeKind.varianceRecovery);
    expect(submission.request.requestedAmountLabel, '18.0M');
    expect(submission.routeLabel, 'Sponsor approval');
    expect(submission.summaryText, contains('Budget change request'));
    expect(submission.summaryText, contains('Rafi Prakoso'));
  });
}
