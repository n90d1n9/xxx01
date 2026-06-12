import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_resource_capacity_service.dart';

void main() {
  test('project resource capacity groups contributors across projects', () {
    final summary = buildProjectResourceCapacitySummary(
      projects: [
        _project(
          id: 'retail',
          name: 'Retail Modernization',
          health: ProjectHealth.onTrack,
          team: const [
            ProjectTeamMember(
              name: 'Maya Santoso',
              role: 'Delivery Lead',
              allocation: 0.7,
            ),
            ProjectTeamMember(
              name: 'Iqbal Karim',
              role: 'QA Lead',
              allocation: 0.4,
            ),
          ],
        ),
        _project(
          id: 'mobile',
          name: 'Mobile Field App',
          health: ProjectHealth.blocked,
          team: const [
            ProjectTeamMember(
              name: 'Maya Santoso',
              role: 'Program Advisor',
              allocation: 0.45,
            ),
          ],
        ),
      ],
    );

    expect(summary.contributorCount, 2);
    expect(summary.overallocatedCount, 1);
    expect(summary.availableCount, 1);
    expect(summary.attentionAssignmentCount, 1);

    final maya = summary.prioritizedItems.first;
    expect(maya.name, 'Maya Santoso');
    expect(maya.projectCount, 2);
    expect(maya.allocationPercent, 115);
    expect(maya.state, ProjectResourceCapacityState.overallocated);
    expect(projectResourceCapacityDetail(maya), contains('2 projects'));
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required ProjectHealth health,
  required List<ProjectTeamMember> team,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 6, 30),
    progress: 0.5,
    budgetUsed: 0.5,
    health: health,
    milestones: const [],
    team: team,
  );
}
