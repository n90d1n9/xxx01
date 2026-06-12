import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair session summary describes the guided repair path', () {
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
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
      ),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );

    final summary = buildProjectDomainGapRepairSessionSummary(
      plan: ProjectDomainGapRepairPlan(
        visibleTargets: [first],
        allTargets: [first, second],
        totalTargetCount: 2,
        requiredTargetCount: 1,
        riskSignalTargetCount: 0,
        recommendedTargetCount: 0,
        coverageGapTargetCount: 1,
      ),
    );

    expect(summary.isEmpty, isFalse);
    expect(summary.nextTarget, first);
    expect(summary.stepCountLabel, 'Guided: 2 steps');
    expect(summary.nextStepLabel, 'Step 1: Repository - Field App');
    expect(summary.projectScopeLabel, '2 projects');
    expect(summary.domainScopeLabel, '2 domains');
    expect(summary.priorityPathLabel, '1 required - 1 coverage');
  });

  test('repair session summary hides empty plans', () {
    final summary = buildProjectDomainGapRepairSessionSummary(
      plan: ProjectDomainGapRepairPlan.empty(),
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.stepCountLabel, 'Guided: 0 steps');
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
