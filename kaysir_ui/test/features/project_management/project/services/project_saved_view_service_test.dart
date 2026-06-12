import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/services/project_saved_view_service.dart';

void main() {
  test('project saved views classify portfolio presets', () {
    final today = DateTime(2026, 5, 31);

    expect(
      projectMatchesPortfolioView(
        _project(health: ProjectHealth.blocked),
        ProjectPortfolioViewPreset.blocked,
        today: today,
      ),
      true,
    );
    expect(
      projectMatchesPortfolioView(
        _project(progress: 0.25, budgetUsed: 0.55),
        ProjectPortfolioViewPreset.budgetPressure,
        today: today,
      ),
      true,
    );
    expect(
      projectMatchesPortfolioView(
        _project(
          milestones: [
            ProjectMilestone(
              label: 'Pilot',
              dueDate: DateTime(2026, 6, 10),
              isComplete: false,
            ),
          ],
        ),
        ProjectPortfolioViewPreset.dueSoon,
        today: today,
      ),
      true,
    );
    expect(
      projectMatchesPortfolioView(
        _project(customAttributes: _requiredGeneralAttributes()),
        ProjectPortfolioViewPreset.domainGaps,
        today: today,
      ),
      true,
    );
    expect(
      projectMatchesPortfolioView(
        _project(customAttributes: _readyGeneralAttributes()),
        ProjectPortfolioViewPreset.domainGaps,
        today: today,
      ),
      false,
    );
  });

  test('project saved views count each preset', () {
    final projects = [
      _project(id: 'steady', milestones: const []),
      _project(id: 'blocked', health: ProjectHealth.blocked),
      _project(id: 'budget', progress: 0.2, budgetUsed: 0.5),
      _project(id: 'ready-domain', customAttributes: _readyGeneralAttributes()),
    ];

    final counts = countProjectPortfolioViews(
      projects,
      today: DateTime(2026, 5, 31),
    );

    expect(counts[ProjectPortfolioViewPreset.all], 4);
    expect(counts[ProjectPortfolioViewPreset.needsAttention], 2);
    expect(counts[ProjectPortfolioViewPreset.blocked], 1);
    expect(counts[ProjectPortfolioViewPreset.budgetPressure], 1);
    expect(counts[ProjectPortfolioViewPreset.domainGaps], 3);
  });

  test('project saved views expose recommended sort options', () {
    expect(
      ProjectPortfolioViewPreset.domainGaps.recommendedSortOption,
      ProjectPortfolioSortOption.domainContext,
    );
    expect(
      ProjectPortfolioViewPreset.budgetPressure.recommendedSortOption,
      ProjectPortfolioSortOption.budget,
    );
    expect(
      ProjectPortfolioViewPreset.dueSoon.recommendedSortOption,
      ProjectPortfolioSortOption.dueDate,
    );
    expect(
      ProjectPortfolioViewPreset.needsAttention.recommendedSortOption,
      ProjectPortfolioSortOption.attention,
    );
  });
}

ProjectPortfolioItem _project({
  String id = 'project',
  ProjectHealth health = ProjectHealth.onTrack,
  double progress = 0.5,
  double budgetUsed = 0.45,
  List<ProjectMilestone>? milestones,
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: id,
    name: 'Project',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 7, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    customAttributes: customAttributes,
    milestones:
        milestones ??
        [
          ProjectMilestone(
            label: 'Release',
            dueDate: DateTime(2026, 6, 20),
            isComplete: false,
          ),
        ],
  );
}

List<ProjectCustomAttribute> _readyGeneralAttributes() {
  return const [
    ProjectCustomAttribute(
      key: 'workstream',
      label: 'Workstream',
      type: ProjectCustomAttributeType.text,
      value: 'Operations',
    ),
    ProjectCustomAttribute(
      key: 'region',
      label: 'Region',
      type: ProjectCustomAttributeType.text,
      value: 'Jakarta',
    ),
    ProjectCustomAttribute(
      key: 'priority',
      label: 'Priority',
      type: ProjectCustomAttributeType.choice,
      value: 'Medium',
      options: ['Low', 'Medium', 'High'],
    ),
    ProjectCustomAttribute(
      key: 'kpi-owner',
      label: 'KPI Owner',
      type: ProjectCustomAttributeType.text,
      value: 'Ops Lead',
    ),
  ];
}

List<ProjectCustomAttribute> _requiredGeneralAttributes() {
  return const [
    ProjectCustomAttribute(
      key: 'workstream',
      label: 'Workstream',
      type: ProjectCustomAttributeType.text,
      value: 'Operations',
    ),
    ProjectCustomAttribute(
      key: 'priority',
      label: 'Priority',
      type: ProjectCustomAttributeType.choice,
      value: 'Medium',
      options: ['Low', 'Medium', 'High'],
    ),
  ];
}
