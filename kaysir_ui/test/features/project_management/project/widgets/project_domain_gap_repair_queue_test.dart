import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_repair_service.dart';
import 'package:kaysir/features/project_management/project/services/project_table_custom_column_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_domain_gap_repair_queue.dart';

void main() {
  testWidgets('domain gap repair queue renders targets and emits repair', (
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
          body: ProjectDomainGapRepairQueue(
            targets: [target],
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('Field Repair Queue'), findsOneWidget);
    expect(find.text('Next: Repository - Field App'), findsOneWidget);
    expect(find.text('1 project'), findsOneWidget);
    expect(find.text('1 field'), findsOneWidget);
    expect(find.text('Software Development'), findsOneWidget);
    expect(find.text('1 blocked project'), findsOneWidget);
    expect(find.text('Stabilize blockers'), findsOneWidget);
    expect(find.text('Quick pass'), findsOneWidget);
    expect(find.text('Single-project pass'), findsOneWidget);
    expect(find.text('Recovery checklist'), findsOneWidget);
    expect(find.text('Owner + sponsor'), findsOneWidget);
    expect(find.text('Minimum fields'), findsOneWidget);
    expect(find.text('Guided: 1 step'), findsOneWidget);
    expect(find.text('Step 1: Repository - Field App'), findsOneWidget);
    expect(find.text('Repository - Field App'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('URL value'), findsOneWidget);
    expect(find.text('Mandatory context'), findsOneWidget);
    expect(find.text('Blocked project'), findsOneWidget);
    expect(find.text('Software Development - Blocked'), findsOneWidget);
    expect(find.text('Fix Next'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-gap-repair-field-app-repository'),
      ),
    );

    expect(repairedTarget?.project.id, 'field-app');
    expect(repairedTarget?.column.key, 'repository');
  });

  testWidgets('domain gap repair queue repairs top target from next action', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = _target(projectId: 'second');
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 2,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-fix-next')),
    );

    expect(repairedTarget, first);
  });

  testWidgets('domain gap repair queue surfaces guided path steps', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(id: 'wedding', name: 'Wedding Plan'),
      column: _coverageColumn(),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 1,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('1 Repository - Field App'), findsOneWidget);
    expect(find.text('2 Handoff - Wedding Plan'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-session-step-2')),
    );

    expect(repairedTarget, second);
  });

  testWidgets('domain gap repair queue surfaces same-project batches', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: first.project,
      column: _coverageColumn(),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 1,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
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

  testWidgets('domain gap repair queue surfaces field type mix actions', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(id: 'handoff', name: 'Handoff Plan'),
      column: _coverageColumn(),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 1,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('1 URL fix'), findsOneWidget);
    expect(find.text('1 Text fix'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-field-type-url')),
    );

    expect(repairedTarget, first);
  });

  testWidgets('domain gap repair queue surfaces domain mix actions', (
    tester,
  ) async {
    ProjectDomainGapRepairTarget? repairedTarget;
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = ProjectDomainGapRepairTarget(
      project: _project(
        id: 'wedding',
        name: 'Wedding Plan',
        businessDomain: 'Wedding Organizer',
      ),
      column: _coverageColumn(),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 1,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (target) => repairedTarget = target,
          ),
        ),
      ),
    );

    expect(find.text('1 fix: Software Development'), findsOneWidget);
    expect(find.text('1 fix: Wedding Organizer'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-gap-repair-domain-software-development'),
      ),
    );

    expect(repairedTarget, first);
  });

  testWidgets('domain gap repair queue summarizes hidden targets', (
    tester,
  ) async {
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [target],
      allTargets: [
        target,
        _target(projectId: 'second'),
        _target(projectId: 'third'),
      ],
      totalTargetCount: 3,
      requiredTargetCount: 2,
      riskSignalTargetCount: 1,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.text('1 of 3 editable domain gaps shown by priority'),
      findsOneWidget,
    );
    expect(find.text('Required: 2'), findsOneWidget);
    expect(find.text('Risk: 1'), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);
    expect(find.text('Show All 3'), findsOneWidget);
  });

  testWidgets('domain gap repair queue expands hidden targets', (tester) async {
    final first = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final second = _target(projectId: 'second');
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [first],
      allTargets: [first, second],
      totalTargetCount: 2,
      requiredTargetCount: 2,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Repository - Second'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-toggle')),
    );
    await tester.pump();

    expect(
      find.text('2 editable domain gaps shown by priority'),
      findsOneWidget,
    );
    expect(find.text('Repository - Second'), findsOneWidget);
    expect(find.text('Show Top Fixes'), findsOneWidget);
  });

  testWidgets('domain gap repair queue can focus repair classes', (
    tester,
  ) async {
    ProjectDomainGapRepairPriority? focusedPriority;
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _column(),
      priority: ProjectDomainGapRepairPriority.requiredField,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [target],
      allTargets: [target],
      totalTargetCount: 1,
      requiredTargetCount: 1,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (_) {},
            onFocusPriority: (priority) => focusedPriority = priority,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-gap-repair-focus-requiredField'),
      ),
    );

    expect(focusedPriority, ProjectDomainGapRepairPriority.requiredField);
  });

  testWidgets('domain gap repair queue can focus coverage gaps', (
    tester,
  ) async {
    ProjectDomainGapRepairPriority? focusedPriority;
    final target = ProjectDomainGapRepairTarget(
      project: _project(),
      column: _coverageColumn(),
      priority: ProjectDomainGapRepairPriority.coverageGap,
    );
    final plan = ProjectDomainGapRepairPlan(
      visibleTargets: [target],
      allTargets: [target],
      totalTargetCount: 1,
      requiredTargetCount: 0,
      riskSignalTargetCount: 0,
      recommendedTargetCount: 0,
      coverageGapTargetCount: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectDomainGapRepairQueue.fromPlan(
            plan: plan,
            onRepair: (_) {},
            onFocusPriority: (priority) => focusedPriority = priority,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('project-domain-gap-repair-focus-coverageGap')),
    );

    expect(focusedPriority, ProjectDomainGapRepairPriority.coverageGap);
  });
}

ProjectDomainGapRepairTarget _target({required String projectId}) {
  return ProjectDomainGapRepairTarget(
    project: _project(id: projectId, name: _title(projectId)),
    column: _column(),
    priority: ProjectDomainGapRepairPriority.requiredField,
  );
}

ProjectPortfolioItem _project({
  String id = 'field-app',
  String name = 'Field App',
  String businessDomain = 'Software Development',
}) {
  return ProjectPortfolioItem(
    id: id,
    name: name,
    owner: 'Nadia Putri',
    client: 'Service Team',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.4,
    budgetUsed: 0.3,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}

String _title(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
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

ProjectTableCustomColumn _coverageColumn() {
  return const ProjectTableCustomColumn(
    key: 'handoff',
    label: 'Handoff',
    type: ProjectCustomAttributeType.text,
    applicableProjectIds: {'field-app'},
    filledProjectIds: {},
    pinnedProjectIds: {},
    requiredProjectIds: {},
    recommendedProjectIds: {},
    riskWatchedProjectIds: {},
  );
}
