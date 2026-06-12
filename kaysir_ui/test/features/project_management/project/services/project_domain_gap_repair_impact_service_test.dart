import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_impact_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair impact summary groups unique projects fields and domains', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'field-app',
        name: 'Field App',
        businessDomain: 'Software Development',
        health: ProjectHealth.blocked,
      ),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
        health: ProjectHealth.atRisk,
      ),
      column: _column(key: 'venue', label: 'Venue'),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );
    final third = ProjectDomainGapRepairTarget(
      project: first.project,
      column: _column(key: 'api-owner', label: 'API Owner'),
      priority: ProjectDomainGapRepairPriority.recommended,
    );
    final plan = ProjectDomainGapRepairPlan.fromTargets([first, second, third]);

    final summary = buildProjectDomainGapRepairImpactSummary(plan: plan);

    expect(summary.totalTargetCount, 3);
    expect(summary.projectCount, 2);
    expect(summary.fieldCount, 3);
    expect(summary.domains, ['Software Development', 'Wedding Organizer']);
    expect(summary.domainScopeLabel, '2 domains');
    expect(summary.domainTooltip, 'Software Development, Wedding Organizer');
    expect(summary.blockedProjectCount, 1);
    expect(summary.atRiskProjectCount, 1);
    expect(summary.hasUrgentHealthContext, isTrue);
    expect(summary.urgencyLabel, '1 blocked project');
    expect(summary.nextTarget, first);
    expect(summary.nextFixLabel, 'Repository - Field App');
    expect(summary.projectScopeLabel, '2 projects');
    expect(summary.fieldScopeLabel, '3 fields');
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
  required ProjectHealth health,
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
    health: health,
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
