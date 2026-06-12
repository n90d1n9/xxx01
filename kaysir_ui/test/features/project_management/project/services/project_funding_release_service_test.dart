import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_funding_release_service.dart';

void main() {
  test('builds review funding releases for guarded retail controls', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectFundingReleaseSummary(workspace);

    expect(summary.projectId, 'retail-modernization');
    expect(summary.level, ProjectFundingReleaseLevel.review);
    expect(summary.title, 'Funding releases need review');
    expect(summary.stepCount, greaterThanOrEqualTo(4));
    expect(summary.reviewCount, greaterThan(0));
    expect(summary.blockedCount, 0);
    expect(summary.releaseAmountLabel, isNot('-'));
    expect(
      summary.steps.map((step) => step.title),
      containsAll([
        'Active funding window',
        'Pilot release gate',
        'Reserve guardrail',
        'Spend authority needs setup',
      ]),
    );
  });

  test('blocks funding releases when warehouse cash flow is constrained', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectFundingReleaseSummary(workspace);

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.level, ProjectFundingReleaseLevel.blocked);
    expect(summary.title, 'Funding releases blocked');
    expect(summary.blockedCount, greaterThan(0));
    expect(summary.primaryStep?.level, ProjectFundingReleaseLevel.blocked);
    expect(summary.attentionAmountLabel, isNot('-'));
    expect(
      summary.steps.map((step) => step.title),
      containsAll([
        'Active funding window',
        'Integration release gate',
        'Reserve guardrail',
        'Spend escalation required',
      ]),
    );
  });
}
