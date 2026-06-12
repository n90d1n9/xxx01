import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_project_cluster_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_project_cluster_strip.dart';

void main() {
  testWidgets('repair project cluster strip opens the cluster primary target', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(key: 'repository', label: 'Repository'),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: first.project,
      column: _column(key: 'api-owner', label: 'API Owner'),
      priority: ProjectDomainGapRepairPriority.riskSignal,
    );
    final summary = buildProjectDomainGapRepairProjectClusterSummary(
      plan: ProjectDomainGapRepairPlan.fromTargets([first, second]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairProjectClusterStrip(
            summary: summary,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('2 fields: Field App'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-cluster-field-app')),
    );

    expect(repairedTarget, first);
  });

  testWidgets(
    'repair project cluster strip hides without multi-field clusters',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectDomainGapRepairProjectClusterStrip(
              summary: ProjectDomainGapRepairProjectClusterSummary.empty(),
              onRepair: (_) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('fields:'), findsNothing);
    },
  );
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'field-app',
    name: 'Field App',
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
