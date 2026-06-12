import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_field_type_mix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair field type mix groups missing targets by value type', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(id: 'field-app', name: 'Field App'),
      column: _column(
        key: 'repository',
        label: 'Repository',
        type: ProjectCustomAttributeType.url,
      ),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(id: 'venue', name: 'Venue Setup'),
      column: _column(
        key: 'contract',
        label: 'Contract',
        type: ProjectCustomAttributeType.url,
      ),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );
    final third = ProjectDomainGapRepairTarget(
      project: _project(id: 'school', name: 'School Upgrade'),
      column: _column(
        key: 'handoff',
        label: 'Handoff Date',
        type: ProjectCustomAttributeType.date,
      ),
      priority: ProjectDomainGapRepairPriority.recommended,
    );

    final summary = buildProjectDomainGapRepairFieldTypeMixSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([first, third, second]),
      maxGroups: 1,
    );

    expect(summary.hasMix, isTrue);
    expect(summary.totalGroupCount, 2);
    expect(summary.hiddenGroupCount, 1);

    final group = summary.visibleGroups.single;
    expect(group.type, ProjectCustomAttributeType.url);
    expect(group.targetCount, 2);
    expect(group.primaryTarget, first);
    expect(group.actionLabel, '2 URL fixes');
    expect(group.fieldSummaryLabel, 'Repository, Contract');
    expect(group.projectScopeLabel, '2 projects');
    expect(group.prioritySummaryLabel, '1 required - 1 risk');
  });

  test('repair field type mix hides single target plans', () {
    final summary = buildProjectDomainGapRepairFieldTypeMixSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(id: 'field-app', name: 'Field App'),
          column: _column(
            key: 'repository',
            label: 'Repository',
            type: ProjectCustomAttributeType.url,
          ),
          priority: ProjectDomainGapRepairPriority.requiredField,
        ),
      ]),
    );

    expect(summary.hasMix, isFalse);
  });
}

ProjectPortfolioItem _project({required String id, required String name}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column({
  required String key,
  required String label,
  required ProjectCustomAttributeType type,
}) {
  return ProjectTableCustomColumn(
    key: key,
    label: label,
    type: type,
    applicableProjectIds: const {},
    filledProjectIds: const {},
    pinnedProjectIds: const {},
    requiredProjectIds: const {},
    recommendedProjectIds: const {},
    riskWatchedProjectIds: const {},
  );
}
