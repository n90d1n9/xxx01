import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_approval_action_flow_service.dart';
import 'package:kaysir/features/project_management/project/services/project_approval_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('approval action flow validates and submits an approval action', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectApprovalWorkspaceSummary(financeWorkspace);
    const service = ProjectApprovalActionFlowService();
    final initialDraft = service.initialDraft(summary);

    expect(service.actionableItems(summary), isNotEmpty);
    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      outcome: ProjectApprovalActionOutcome.approve,
      approver: 'Supply Chain Sponsor',
      evidenceRef: 'Sponsor approval memo',
      note:
          'Approve the queue item after confirming evidence, release owner, and approval threshold.',
    );
    final submission = service.submit(summary: summary, draft: draft);

    expect(submission.outcome, ProjectApprovalActionOutcome.approve);
    expect(submission.resultingLevel, ProjectApprovalWorkspaceLevel.ready);
    expect(submission.approver, 'Supply Chain Sponsor');
    expect(submission.routeLabel, 'Approval route');
    expect(submission.summaryText, contains('Approval action'));
    expect(submission.summaryText, contains('Sponsor approval memo'));
  });
}
