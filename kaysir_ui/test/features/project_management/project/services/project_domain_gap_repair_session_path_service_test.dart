import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_path_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair session path summarizes visible ordered steps', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(id: 'field-app', name: 'Field App'),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(id: 'wedding', name: 'Wedding Plan'),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final third = ProjectDomainGapRepairTarget(
      project: _project(id: 'school', name: 'School Upgrade'),
      column: _column(key: 'campus', label: 'Campus'),
      priority: ProjectDomainGapRepairPriority.recommended,
    );

    final summary = buildProjectDomainGapRepairSessionPathSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([first, second, third]),
      maxSteps: 2,
    );

    expect(summary.hasPath, isTrue);
    expect(summary.visibleSteps, hasLength(2));
    expect(summary.hiddenStepCount, 1);
    expect(summary.visibleSteps.first.stepNumber, 1);
    expect(summary.visibleSteps.first.target, first);
    expect(summary.visibleSteps.first.actionLabel, '1 Repository - Field App');
    expect(summary.visibleSteps[1].actionLabel, '2 Venue - Wedding Plan');
  });

  test('repair session path hides single-step plans', () {
    final summary = buildProjectDomainGapRepairSessionPathSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(id: 'field-app', name: 'Field App'),
          column: _column(key: 'repository', label: 'Repository'),
          priority: ProjectDomainGapRepairPriority.requiredField,
        ),
      ]),
    );

    expect(summary.hasPath, isFalse);
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
