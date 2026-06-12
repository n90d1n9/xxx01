import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';

void main() {
  test('project priority classifies delivery attention levels', () {
    expect(
      projectPriorityFor(
        _project(
          health: ProjectHealth.blocked,
          risks: const [
            ProjectDeliveryRisk(
              title: 'Contract',
              detail: 'Contract is not signed.',
              severity: ProjectHealth.blocked,
            ),
          ],
        ),
      ),
      ProjectPriority.critical,
    );
    expect(
      projectPriorityFor(
        _project(
          health: ProjectHealth.atRisk,
          progress: 0.35,
          budgetUsed: 0.62,
        ),
      ),
      ProjectPriority.high,
    );
    expect(
      projectPriorityFor(_project(milestoneOpen: true)),
      ProjectPriority.normal,
    );
    expect(
      projectPriorityFor(_project(milestoneOpen: false)),
      ProjectPriority.steady,
    );
  });

  test('project portfolio sort puts attention work first', () {
    final projects = [
      _project(id: 'steady', name: 'Steady', milestoneOpen: false),
      _project(id: 'blocked', name: 'Blocked', health: ProjectHealth.blocked),
      _project(id: 'budget', name: 'Budget', progress: 0.2, budgetUsed: 0.5),
    ];

    expect(
      sortProjectPortfolio(
        projects,
        ProjectPortfolioSortOption.attention,
      ).map((project) => project.id),
      ['blocked', 'budget', 'steady'],
    );
    expect(
      sortProjectPortfolio(
        projects,
        ProjectPortfolioSortOption.name,
      ).map((project) => project.id),
      ['blocked', 'budget', 'steady'],
    );
  });

  test('project portfolio sort prioritizes domain context gaps', () {
    final projects = [
      _project(
        id: 'ready',
        name: 'Ready',
        customAttributes: _readyGeneralAttributes(),
      ),
      _project(
        id: 'in-progress',
        name: 'In Progress',
        customAttributes: _requiredGeneralAttributes(),
      ),
      _project(
        id: 'missing-one-required',
        name: 'Missing One Required',
        customAttributes: const [
          ProjectCustomAttribute(
            key: 'workstream',
            label: 'Workstream',
            type: ProjectCustomAttributeType.text,
            value: 'Operations',
          ),
        ],
      ),
      _project(id: 'missing-all', name: 'Missing All'),
    ];

    expect(
      sortProjectPortfolio(
        projects,
        ProjectPortfolioSortOption.domainContext,
      ).map((project) => project.id),
      ['missing-all', 'missing-one-required', 'in-progress', 'ready'],
    );
  });
}

ProjectPortfolioItem _project({
  String id = 'project',
  String name = 'Project',
  ProjectHealth health = ProjectHealth.onTrack,
  double progress = 0.5,
  double budgetUsed = 0.45,
  bool milestoneOpen = false,
  List<ProjectDeliveryRisk> risks = const [],
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 6, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    risks: risks,
    customAttributes: customAttributes,
    milestones: [
      ProjectMilestone(
        label: 'Release',
        dueDate: DateTime(2026, 5, 20),
        isComplete: !milestoneOpen,
      ),
    ],
  );
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
