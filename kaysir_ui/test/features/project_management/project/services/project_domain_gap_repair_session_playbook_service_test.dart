import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_playbook_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair playbook prioritizes blocked required recovery work', () {
    final target = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'site',
        name: 'Site Build',
        businessDomain: 'Construction',
        health: ProjectHealth.blocked,
      ),
      column: _column(key: 'permit', label: 'Permit'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );

    final summary = buildProjectDomainGapRepairSessionPlaybookSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([target]),
    );

    expect(
      summary.kind,
      ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist,
    );
    expect(summary.playbookLabel, 'Recovery checklist');
    expect(summary.reviewerLabel, 'Owner + sponsor');
    expect(summary.evidenceLabel, 'Minimum fields');
  });

  test('repair playbook adapts risk and cross-domain setup sessions', () {
    final riskSummary = buildProjectDomainGapRepairSessionPlaybookSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'rollout',
            name: 'Retail Rollout',
            businessDomain: 'Retail Operations',
            health: ProjectHealth.atRisk,
          ),
          column: _column(key: 'stock', label: 'Stock Signal'),
          priority: ProjectDomainGapRepairPriority.riskSignal,
        ),
      ]),
    );
    final setupSummary = buildProjectDomainGapRepairSessionPlaybookSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'festival',
            name: 'Festival Program',
            businessDomain: 'Event Management',
          ),
          column: _column(key: 'runbook', label: 'Runbook'),
          priority: ProjectDomainGapRepairPriority.coverageGap,
        ),
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'campus',
            name: 'Campus Upgrade',
            businessDomain: 'Education',
          ),
          column: _column(key: 'handoff', label: 'Handoff'),
          priority: ProjectDomainGapRepairPriority.coverageGap,
        ),
      ]),
    );

    expect(riskSummary.playbookLabel, 'Risk review');
    expect(riskSummary.reviewerLabel, 'Delivery + risk');
    expect(setupSummary.playbookLabel, 'Cross-domain setup');
    expect(setupSummary.reviewerLabel, 'Domain leads');
  });

  test('repair playbook hides empty plans', () {
    final summary = buildProjectDomainGapRepairSessionPlaybookSummary(
      plan: ProjectDomainGapRepairPlan.empty(),
    );

    expect(summary.isEmpty, isTrue);
  });
}

ProjectPortfolioItem _project({
  required String id,
  required String name,
  required String businessDomain,
  ProjectHealth health = ProjectHealth.onTrack,
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
