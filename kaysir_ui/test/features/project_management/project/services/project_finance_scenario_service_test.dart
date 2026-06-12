import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_scenario_service.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';

void main() {
  test('builds budget scenarios from a retail finance workspace', () {
    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectFinanceScenarioSummary(workspace);

    expect(summary.projectId, 'retail-modernization');
    expect(summary.scenarioCount, 3);
    expect(
      summary.recommendedOption.kind,
      ProjectFinanceScenarioKind.recoveryPlan,
    );
    expect(
      summary.recommendedOption.level,
      ProjectFinanceScenarioLevel.healthy,
    );
    expect(summary.recommendedOption.projectedAtCompletionPercent, 80);
    expect(summary.title, 'Scenario runway healthy');

    final current = summary.options.firstWhere(
      (option) => option.kind == ProjectFinanceScenarioKind.currentPace,
    );
    final guarded = summary.options.firstWhere(
      (option) => option.kind == ProjectFinanceScenarioKind.guardedSpend,
    );

    expect(current.projectedAtCompletionPercent, 94);
    expect(current.expectedActionCount, 3);
    expect(current.level, ProjectFinanceScenarioLevel.watch);
    expect(guarded.projectedAtCompletionPercent, 86);
    expect(guarded.expectedActionCount, 1);
  });

  test('keeps constrained projects constrained across scenarios', () {
    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);

    final summary = buildProjectFinanceScenarioSummary(workspace);

    expect(summary.projectId, 'warehouse-automation');
    expect(summary.title, 'Scenario runway constrained');
    expect(
      summary.recommendedOption.kind,
      ProjectFinanceScenarioKind.currentPace,
    );
    expect(
      summary.options.every(
        (option) => option.level == ProjectFinanceScenarioLevel.constrained,
      ),
      isTrue,
    );
  });
}
