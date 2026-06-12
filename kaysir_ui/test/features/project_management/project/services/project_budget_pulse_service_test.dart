import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_budget_pulse_service.dart';

void main() {
  test('project budget pulse prioritizes spend pressure', () {
    final summary = buildProjectBudgetPulseSummary(
      projects: [
        _project(
          id: 'mobile',
          name: 'Mobile Field App',
          health: ProjectHealth.blocked,
          progress: 0.2,
          budgetUsed: 0.51,
        ),
        _project(
          id: 'warehouse',
          name: 'Warehouse Automation',
          health: ProjectHealth.atRisk,
          progress: 0.4,
          budgetUsed: 0.62,
        ),
        _project(
          id: 'finance',
          name: 'Finance Close Suite',
          health: ProjectHealth.onTrack,
          progress: 0.7,
          budgetUsed: 0.55,
        ),
      ],
    );

    expect(summary.projectCount, 3);
    expect(summary.pressureCount, 2);
    expect(summary.criticalCount, 1);
    expect(summary.efficientCount, 1);
    expect(summary.averageVariancePoints, 13);
    expect(summary.signal, ProjectBudgetPulseState.critical);
    expect(summary.prioritizedItems.first.projectName, 'Mobile Field App');
    expect(
      projectBudgetPulseDetail(summary.prioritizedItems.first),
      '51% budget used against 20% progress (+31 pts).',
    );
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required ProjectHealth health,
  required double progress,
  required double budgetUsed,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 7, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: const [],
  );
}
