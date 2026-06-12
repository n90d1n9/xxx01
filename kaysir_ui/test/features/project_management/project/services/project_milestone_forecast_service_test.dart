import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_milestone_forecast_service.dart';

void main() {
  test('project milestone forecast prioritizes near-term open milestones', () {
    final summary = buildProjectMilestoneForecastSummary(
      today: DateTime(2026, 5, 31),
      horizonDays: 45,
      projects: [
        _project(
          id: 'retail',
          name: 'Retail Modernization',
          health: ProjectHealth.onTrack,
          milestones: [
            ProjectMilestone(
              label: 'Discovery',
              dueDate: DateTime(2026, 5, 24),
              isComplete: true,
            ),
            ProjectMilestone(
              label: 'Pilot',
              dueDate: DateTime(2026, 6, 2),
              isComplete: false,
            ),
          ],
        ),
        _project(
          id: 'mobile',
          name: 'Mobile Field App',
          health: ProjectHealth.blocked,
          milestones: [
            ProjectMilestone(
              label: 'API Ready',
              dueDate: DateTime(2026, 5, 28),
              isComplete: false,
            ),
            ProjectMilestone(
              label: 'Launch',
              dueDate: DateTime(2026, 8, 31),
              isComplete: false,
            ),
          ],
        ),
        _project(
          id: 'finance',
          name: 'Finance Close Suite',
          health: ProjectHealth.atRisk,
          milestones: [
            ProjectMilestone(
              label: 'Audit',
              dueDate: DateTime(2026, 6, 22),
              isComplete: false,
            ),
          ],
        ),
      ],
    );

    expect(summary.totalCount, 3);
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.upcomingCount, 1);
    expect(summary.projectCount, 3);

    expect(summary.items.first.label, 'API Ready');
    expect(summary.items.first.state, ProjectMilestoneForecastState.overdue);
    expect(summary.nextItem?.label, 'API Ready');
    expect(
      projectMilestoneForecastDetail(summary.items.first),
      contains('3 days overdue'),
    );
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required ProjectHealth health,
  required List<ProjectMilestone> milestones,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 9, 1),
    progress: 0.5,
    budgetUsed: 0.5,
    health: health,
    milestones: milestones,
  );
}
