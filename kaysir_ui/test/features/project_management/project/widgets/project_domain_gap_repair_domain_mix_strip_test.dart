import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_domain_mix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_domain_mix_strip.dart';

void main() {
  testWidgets('repair domain mix strip opens the domain primary target', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairDomainMixStrip(
            summary: buildProjectDomainGapRepairDomainMixSummary(
              plan: ProjectDomainGapRepairPlan.fromTargets([
                first,
                third,
                second,
              ]),
            ),
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('2 fixes: Software Development'), findsOneWidget);
    expect(find.text('1 fix: Wedding Organizer'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-gap-repair-domain-software-development'),
      ),
    );

    expect(repairedTarget, first);
  });

  testWidgets('repair domain mix strip hides single-domain summaries', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairDomainMixStrip(
            summary: ProjectDomainGapRepairDomainMixSummary.empty(),
            onRepair: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('fix'), findsNothing);
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
