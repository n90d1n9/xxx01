import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_session_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';

void main() {
  test('repair session focus prioritizes blocked required work', () {
    final first = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'site-build',
        name: 'Site Build',
        businessDomain: 'Construction',
        health: ProjectHealth.blocked,
      ),
      column: _column(key: 'permit', label: 'Permit'),
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

    final summary = buildProjectDomainGapRepairSessionFocusSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([first, second]),
    );

    expect(
      summary.focusKind,
      ProjectDomainGapRepairSessionFocusKind.stabilization,
    );
    expect(summary.focusLabel, 'Stabilize blockers');
    expect(summary.paceLabel, 'Quick pass');
    expect(summary.scopeLabel, '2-domain pass');
  });

  test('repair session focus classifies risk and coverage sessions', () {
    final riskSummary = buildProjectDomainGapRepairSessionFocusSummary(
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
    final coverageSummary = buildProjectDomainGapRepairSessionFocusSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([
        ProjectDomainGapRepairTarget(
          project: _project(
            id: 'festival',
            name: 'Festival Program',
            businessDomain: 'Event Management',
          ),
          column: _column(key: 'handoff', label: 'Handoff'),
          priority: ProjectDomainGapRepairPriority.coverageGap,
        ),
      ]),
    );

    expect(riskSummary.focusLabel, 'Reduce delivery risk');
    expect(coverageSummary.focusLabel, 'Broaden domain coverage');
  });

  test('repair session focus hides empty plans', () {
    final summary = buildProjectDomainGapRepairSessionFocusSummary(
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
