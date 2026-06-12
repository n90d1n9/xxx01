import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_domain_mix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair domain mix groups missing targets by business domain', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'field-app',
        name: 'Field App',
        businessDomain: 'Software Development',
      ),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'release',
        name: 'Release Desk',
        businessDomain: 'Software Development',
      ),
      column: _column(key: 'api-owner', label: 'API Owner'),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );
    final third = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
      ),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );

    final summary = buildProjectDomainGapRepairDomainMixSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([first, third, second]),
      maxGroups: 1,
    );

    expect(summary.hasMix, isTrue);
    expect(summary.totalGroupCount, 2);
    expect(summary.hiddenGroupCount, 1);

    final group = summary.visibleGroups.single;
    expect(group.domainKey, 'software-development');
    expect(group.domainLabel, 'Software Development');
    expect(group.targetCount, 2);
    expect(group.projectScopeLabel, '2 projects');
    expect(group.primaryTarget, first);
    expect(group.actionLabel, '2 fixes: Software Development');
    expect(group.fieldSummaryLabel, 'Repository, API Owner');
    expect(group.prioritySummaryLabel, '1 required - 1 risk');
  });

  test('repair domain mix hides single-domain plans', () {
    final summary = buildProjectDomainGapRepairDomainMixSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'field-app',
            name: 'Field App',
            businessDomain: 'Software Development',
          ),
          column: _column(key: 'repository', label: 'Repository'),
          priority: ProjectDomainGapRepairPriority.requiredField,
        ),
      ]),
    );

    expect(summary.hasMix, isFalse);
  });

  test('repair domain mix normalizes empty domain labels', () {
    final summary = buildProjectDomainGapRepairDomainMixSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'general',
            name: 'General Work',
            businessDomain: '',
          ),
          column: _column(key: 'handoff', label: 'Handoff'),
          priority: ProjectDomainGapRepairPriority.recommended,
        ),
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'event',
            name: 'Event Work',
            businessDomain: 'Event Operations',
          ),
          column: _column(key: 'permit', label: 'Permit'),
          priority: ProjectDomainGapRepairPriority.coverageGap,
        ),
      ]),
    );

    expect(summary.visibleGroups.first.domainKey, 'general-business');
    expect(summary.visibleGroups.first.domainLabel, 'General Business');
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column({required String key, required String label}) {
  return ProjectTableCustomColumn(
    key: key,
    label: label,
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: const {},
    filledProjectIds: const {},
    pinnedProjectIds: const {},
    requiredProjectIds: const {},
    recommendedProjectIds: const {},
    riskWatchedProjectIds: const {},
  );
}
