import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_field_type_mix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_field_type_mix_strip.dart';

void main() {
  testWidgets('repair field type mix strip opens the type primary target', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairFieldTypeMixStrip(
            summary: buildProjectDomainGapRepairFieldTypeMixSummary(
              plan: ProjectDomainGapRepairPlan.fromTargets([first, second]),
            ),
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('2 URL fixes'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-field-type-url')),
    );

    expect(repairedTarget, first);
  });

  testWidgets('repair field type mix strip hides single target plans', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairFieldTypeMixStrip(
            summary: ProjectDomainGapRepairFieldTypeMixSummary.empty(),
            onRepair: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('fix'), findsNothing);
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
