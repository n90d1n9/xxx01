import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_issue_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_response_flow_service.dart';

void main() {
  test('risk response flow validates and queues a response', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectRiskIssueWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 11),
    );
    const service = ProjectRiskResponseFlowService();
    final initialDraft = service.initialDraft(summary);

    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      mode: ProjectRiskResponseMode.escalate,
      title: 'Scanner delivery recovery response',
      owner: 'Delivery Sponsor',
      responseNote:
          'Escalate supplier lead-time recovery, alternate sourcing, and warehouse cutover protection before the next gate.',
      evidenceNote:
          'Attach supplier recovery memo, alternate quotation, revised delivery date, and sponsor approval trail.',
    );
    final submission = service.submit(
      summary: summary,
      draft: draft,
      queueIndex: 1,
    );

    expect(submission.responseItem.title, 'Scanner delivery recovery response');
    expect(submission.mode, ProjectRiskResponseMode.escalate);
    expect(submission.responseItem.level, ProjectRiskIssueLevel.critical);
    expect(submission.routeLabel, 'Executive escalation');
    expect(submission.summaryText, contains('Risk response'));
    expect(submission.summaryText, contains('Delivery Sponsor'));
  });
}
