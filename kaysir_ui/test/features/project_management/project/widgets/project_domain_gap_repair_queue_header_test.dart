import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_queue_header.dart';

void main() {
  testWidgets('repair queue header summarizes priority counts', (tester) async {
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [target],
      allTargets: [target, target, target],
      totalTargetCount: 3,
      requiredTargetCount: 2,
      riskSignalTargetCount: 1,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueueHeader(
            plan: plan,
            isExpanded: false,
          ),
        ),
      ),
    );

    expect(find.text('Field Repair Queue'), findsOneWidget);
    expect(
      find.text('1 of 3 editable domain gaps shown by priority'),
      findsOneWidget,
    );
    expect(find.text('Required: 2'), findsOneWidget);
    expect(find.text('Risk: 1'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
  });

  testWidgets('repair queue header reflects expanded hidden state', (
    tester,
  ) async {
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [target],
      allTargets: [target, target],
      totalTargetCount: 2,
      requiredTargetCount: 2,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueueHeader(plan: plan, isExpanded: true),
        ),
      ),
    );

    expect(
      find.text('2 editable domain gaps shown by priority'),
      findsOneWidget,
    );
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
