import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_target_row.dart';

void main() {
  testWidgets('repair target row renders context and emits repair', (
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
          body: ProjectDomainGapRepairTargetRow(
            target: target,
            onRepair: () => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('Repository - Field App'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('URL value'), findsOneWidget);
    expect(find.text('Mandatory context'), findsOneWidget);
    expect(find.text('Blocked project'), findsOneWidget);
    expect(find.text('Software Development - Blocked'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-gap-repair-field-app-repository'),
      ),
    );

    expect(repairedTarget, target);
  });
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

ProjectTableCustomColumn _column() {
  return const ProjectTableCustomColumn(
    key: 'repository',
    label: 'Repository',
    type: ProjectCustomAttributeType.url,
    applicableProjectIds: {'field-app'},
    filledProjectIds: {},
    pinnedProjectIds: {},
    requiredProjectIds: {'field-app'},
    recommendedProjectIds: {},
    riskWatchedProjectIds: {'field-app'},
  );
}
