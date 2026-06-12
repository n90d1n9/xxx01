import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_next_action.dart';

void main() {
  testWidgets('repair next action opens the prioritized target', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairNextAction(
            target: target,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('Fix Next'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-fix-next')),
    );

    expect(repairedTarget, target);
  });

  testWidgets('repair next action hides without a target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairNextAction(
            target: null,
            onRepair: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Fix Next'), findsNothing);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'field-app',
    name: 'Field App',
    owner: 'Owner',
    client: 'Client',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 5),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}

ProjectTableCustomColumn _column() {
  return const ProjectTableCustomColumn(
    key: 'repository',
    label: 'Repository',
    type: ProjectCustomAttributeType.url,
    applicableProjectIds: {},
    filledProjectIds: {},
    pinnedProjectIds: {},
    requiredProjectIds: {},
    recommendedProjectIds: {},
    riskWatchedProjectIds: {},
  );
}
