import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('domain gap repair targets prioritize editable required gaps', () {
    final projects = [
      _project(
        id: 'field-app',
        name: 'Field App',
        businessDomain: 'Software Development',
        health: ProjectHealth.blocked,
        endDate: DateTime(2026, 8),
      ),
      _project(
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
        health: ProjectHealth.atRisk,
        endDate: DateTime(2026, 7),
      ),
      _project(
        id: 'demo',
        name: 'Demo',
        businessDomain: 'General Business',
        health: ProjectHealth.blocked,
        endDate: DateTime(2026, 6),
      ),
    ];
    final columns = [
      _column(
        key: 'repository',
        label: 'Repository',
        applicableProjectIds: {'field-app', 'demo'},
        requiredProjectIds: {'field-app', 'demo'},
        riskWatchedProjectIds: {'field-app'},
      ),
      _column(
        key: 'venue',
        label: 'Venue',
        applicableProjectIds: {'wedding'},
        requiredProjectIds: {'wedding'},
      ),
    ];

    final targets = buildProjectDomainGapRepairTargets(
      projects: projects,
      columns: columns,
      editableProjectIds: const {'field-app', 'wedding'},
    );

    expect(targets.map((target) => target.project.id), [
      'field-app',
      'wedding',
    ]);
    expect(targets.first.column.key, 'repository');
    expect(
      targets.first.priority,
      ProjectDomainGapRepairPriority.requiredField,
    );
    expect(targets.first.contextLabel, 'Software Development - Blocked');
  });

  test('domain gap repair targets respect max targets and filled values', () {
    final projects = [
      _project(
        id: 'alpha',
        name: 'Alpha',
        customAttributes: [_attribute('priority', 'Priority', 'High')],
      ),
      _project(id: 'beta', name: 'Beta'),
      _project(id: 'gamma', name: 'Gamma'),
    ];
    final columns = [
      _column(
        key: 'priority',
        label: 'Priority',
        applicableProjectIds: {'alpha', 'beta', 'gamma'},
        filledProjectIds: {'alpha'},
        requiredProjectIds: {'alpha', 'beta', 'gamma'},
      ),
    ];

    final targets = buildProjectDomainGapRepairTargets(
      projects: projects,
      columns: columns,
      editableProjectIds: const {'alpha', 'beta', 'gamma'},
      maxTargets: 1,
    );

    expect(targets, hasLength(1));
    expect(targets.single.project.id, 'beta');
  });

  test('domain gap repair plan reports hidden and priority counts', () {
    final projects = [
      _project(id: 'alpha', name: 'Alpha', health: ProjectHealth.blocked),
      _project(id: 'beta', name: 'Beta', health: ProjectHealth.atRisk),
      _project(id: 'gamma', name: 'Gamma'),
    ];
    final columns = [
      _column(
        key: 'priority',
        label: 'Priority',
        applicableProjectIds: {'alpha', 'beta', 'gamma'},
        requiredProjectIds: {'alpha', 'beta'},
        recommendedProjectIds: {'gamma'},
      ),
      _column(
        key: 'handoff',
        label: 'Handoff',
        applicableProjectIds: {'alpha', 'beta', 'gamma'},
        riskWatchedProjectIds: {'alpha'},
      ),
    ];

    final plan = buildProjectDomainGapRepairPlan(
      projects: projects,
      columns: columns,
      editableProjectIds: const {'alpha', 'beta', 'gamma'},
      maxTargets: 2,
    );

    expect(plan.visibleTargetCount, 2);
    expect(plan.allTargets, hasLength(6));
    expect(plan.totalTargetCount, 6);
    expect(plan.hiddenTargetCount, 4);
    expect(plan.requiredTargetCount, 2);
    expect(plan.riskSignalTargetCount, 1);
    expect(plan.recommendedTargetCount, 1);
    expect(plan.hasHiddenTargets, isTrue);
    expect(plan.visibleTargets.map((target) => target.project.id), [
      'alpha',
      'beta',
    ]);
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  String businessDomain = 'General Business',
  ProjectHealth health = ProjectHealth.onTrack,
  DateTime? endDate,
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 6),
    endDate: endDate ?? DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: health,
    milestones: const [],
    customAttributes: customAttributes,
  );
}

ProjectTableCustomColumn _column({
  required String key,
  required String label,
  required Set<String> applicableProjectIds,
  Set<String> filledProjectIds = const {},
  Set<String> requiredProjectIds = const {},
  Set<String> recommendedProjectIds = const {},
  Set<String> riskWatchedProjectIds = const {},
}) {
  return ProjectTableCustomColumn(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: applicableProjectIds,
    filledProjectIds: filledProjectIds,
    pinnedProjectIds: const {},
    requiredProjectIds: requiredProjectIds,
    recommendedProjectIds: recommendedProjectIds,
    riskWatchedProjectIds: riskWatchedProjectIds,
  );
}

ProjectCustomAttribute _attribute(String key, String label, String value) {
  return ProjectCustomAttribute(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    value: value,
  );
}
