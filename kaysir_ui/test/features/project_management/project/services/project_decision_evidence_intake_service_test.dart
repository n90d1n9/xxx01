import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_evidence_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision evidence intake validates and submits proof', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    const service = ProjectDecisionEvidenceIntakeService();
    final initialDraft = service.initialDraft(
      workspace.decisionRegisterSummary,
    );

    expect(
      service.evidenceTargets(workspace.decisionRegisterSummary),
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
      kind: ProjectDecisionEvidenceIntakeKind.approval,
      confidence: ProjectDecisionEvidenceConfidence.signedOff,
      title: 'Signed sponsor decision memo',
      reference: 'DOC-DEC-001',
      note:
          'Attach the signed sponsor memo, approval route, and evidence owner for the next review.',
    );
    final submission = service.submit(
      register: workspace.decisionRegisterSummary,
      draft: draft,
    );

    expect(submission.record, isNotNull);
    expect(submission.evidenceLabel, contains('Approval'));
    expect(submission.evidenceLabel, contains('Signed Off'));
    expect(submission.reference, 'DOC-DEC-001');
    expect(submission.summaryText, contains('Decision evidence intake'));
    expect(submission.summaryText, contains('DOC-DEC-001'));
  });
}
