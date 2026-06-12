import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_overview_service.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';

void main() {
  test('budget overview marks material variance as critical', () {
    final overview = buildProjectBudgetOverview(
      _project(progress: 0.4, budgetUsed: 0.71, health: ProjectHealth.atRisk),
    );

    expect(overview.state, ProjectBudgetPulseState.critical);
    expect(overview.paceLabel, 'Budget overrun risk');
    expect(overview.detail, '71% budget used against 40% progress (+31 pts).');
  });

  test('budget overview warns when spend is near budget ceiling', () {
    final overview = buildProjectBudgetOverview(
      _project(progress: 0.76, budgetUsed: 0.86),
    );

    expect(overview.state, ProjectBudgetPulseState.pressure);
    expect(overview.paceLabel, 'Spend ahead of progress');
    expect(overview.remainingBudgetPercent, 14);
  });

  test('budget overview identifies efficient budget pace', () {
    final overview = buildProjectBudgetOverview(
      _project(progress: 0.65, budgetUsed: 0.48),
    );

    expect(overview.state, ProjectBudgetPulseState.efficient);
    expect(overview.paceLabel, 'Under planned spend');
    expect(overview.varianceLabel, '-17 pts');
  });
}

ProjectPortfolioItem _project({
  double progress = 0.5,
  double budgetUsed = 0.5,
  ProjectHealth health = ProjectHealth.onTrack,
}) {
  return ProjectPortfolioItem(
    id: 'project-budget',
    name: 'Project Budget',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: const [],
  );
}
