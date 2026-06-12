import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_decision_record.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision intake service validates and submits a draft record', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    const service = ProjectDecisionIntakeService();
    final initialDraft = ProjectDecisionIntakeDraft.initial(
      workspace.decisionRegisterSummary,
    );

    expect(service.validate(initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      title: 'Approve vendor readiness gate',
      detail:
          'Confirm vendor readiness, owner accountability, and proof needed before the next milestone gate.',
      owner: 'Aisyah Rahman',
      source: ProjectDecisionSource.governance,
      priority: ProjectDecisionPriority.high,
      status: ProjectDecisionStatus.inReview,
      dueOption: ProjectDecisionIntakeDueOption.nextReview,
      evidenceLabel: 'Vendor readiness checklist',
    );
    final issues = service.validate(draft);
    final submission = service.submit(
      register: workspace.decisionRegisterSummary,
      draft: draft,
      queueIndex: 1,
    );

    expect(issues, isEmpty);
    expect(submission.record.title, draft.title);
    expect(submission.record.owner, draft.owner);
    expect(submission.record.dueDate, DateTime(2026, 6, 13));
    expect(submission.routeLabel, 'Approval route');
    expect(submission.summaryText, contains('Decision intake draft'));
    expect(submission.summaryText, contains('Vendor readiness checklist'));
  });
}
