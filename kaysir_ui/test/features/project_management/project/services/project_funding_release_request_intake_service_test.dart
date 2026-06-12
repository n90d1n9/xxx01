import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_funding_release_request_intake_service.dart';
import 'package:kaysir/features/project_management/project/services/project_funding_release_service.dart';

void main() {
  test('funding release request intake validates and queues a release', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectFundingReleaseSummary(financeWorkspace);
    const service = ProjectFundingReleaseRequestIntakeService();
    final initialDraft = service.initialDraft(summary);

    expect(service.validate(summary: summary, draft: initialDraft), isNotEmpty);

    final draft = initialDraft.copyWith(
      kind: ProjectFundingReleaseKind.activeFunding,
      title: 'Sensor installation release window',
      owner: 'Supply Chain Sponsor',
      amountText: '45000000',
      gateNote:
          'Release only after scanner delivery confirmation and blocked freight exception review are cleared.',
      evidenceNote:
          'Attach supplier delivery note, sponsor approval, release checklist, and cash-flow owner confirmation.',
    );
    final submission = service.submit(
      summary: summary,
      draft: draft,
      queueIndex: 1,
    );

    expect(submission.step.title, 'Sensor installation release window');
    expect(submission.step.kind, ProjectFundingReleaseKind.activeFunding);
    expect(submission.step.amountLabel, '45.0M');
    expect(submission.routeLabel, 'Release hold');
    expect(submission.summaryText, contains('Funding release request'));
    expect(submission.summaryText, contains('Supply Chain Sponsor'));
  });
}
