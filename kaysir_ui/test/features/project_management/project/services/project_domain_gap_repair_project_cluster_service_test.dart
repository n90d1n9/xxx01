import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_project_cluster_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair project clusters group multi-field project work', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(id: 'field-app', name: 'Field App'),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: first.project,
      column: _column(key: 'api-owner', label: 'API Owner'),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );
    final single = ProjectDomainGapRepairTarget(
      project: _project(id: 'wedding', name: 'Wedding Plan'),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final third = ProjectDomainGapRepairTarget(
      project: _project(id: 'school', name: 'School Upgrade'),
      column: _column(key: 'campus', label: 'Campus'),
      priority: ProjectDomainGapRepairPriority.recommended,
    );
    final fourth = ProjectDomainGapRepairTarget(
      project: third.project,
      column: _column(key: 'approver', label: 'Approver'),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );

    final summary = buildProjectDomainGapRepairProjectClusterSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        first,
        second,
        single,
        third,
        fourth,
      ]),
      maxClusters: 1,
    );

    expect(summary.totalClusterCount, 2);
    expect(summary.visibleClusters, hasLength(1));
    expect(summary.hiddenClusterCount, 1);
    expect(summary.hasHiddenClusters, isTrue);

    final cluster = summary.visibleClusters.single;
    expect(cluster.project.id, 'field-app');
    expect(cluster.targetCount, 2);
    expect(cluster.primaryTarget, first);
    expect(cluster.requiredCount, 1);
    expect(cluster.riskSignalCount, 1);
    expect(cluster.actionLabel, '2 fields: Field App');
    expect(cluster.fieldSummaryLabel, 'Repository, API Owner');
    expect(cluster.prioritySummaryLabel, '1 required - 1 risk');
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
