import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_decision_record.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_review_flow_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision review flow validates and submits an outcome', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    const service = ProjectDecisionReviewFlowService();
    final initialDraft = service.initialDraft(
      workspace.decisionRegisterSummary,
    );

    expect(
      service.reviewableRecords(workspace.decisionRegisterSummary),
      isNotEmpty,
    );
    expect(
      service.validate(
        register: workspace.decisionRegisterSummary,
        draft: initialDraft,
      ),
      isNotEmpty,
    );

    final draft = initialDraft.copyWith(
      outcome: ProjectDecisionReviewOutcome.approve,
      owner: 'Aisyah Rahman',
      note:
          'Approve the decision after confirming evidence, owner accountability, and next-step readiness.',
      evidenceLabel: 'Signed sponsor approval',
    );
    final submission = service.submit(
      register: workspace.decisionRegisterSummary,
      draft: draft,
    );

    expect(submission.outcome, ProjectDecisionReviewOutcome.approve);
    expect(submission.resultingStatus, ProjectDecisionStatus.approved);
    expect(submission.owner, 'Aisyah Rahman');
    expect(submission.routeLabel, 'Approval route');
    expect(submission.summaryText, contains('Decision review outcome'));
    expect(submission.summaryText, contains('Signed sponsor approval'));
  });
}
