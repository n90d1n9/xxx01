import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_next_decision_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_next_decision_brief_card.dart';
import 'package:kaysir/features/project_management/project/widgets/project_next_decision_panel.dart';

void main() {
  testWidgets('project next decision panel renders decisions and opens task', (
    tester,
  ) async {
    String? openedTaskId;
    final task = gantt.GanttTask(
      id: 'blocked',
      title: 'Cutover Prep',
      startDate: DateTime(2026, 6, 3),
      endDate: DateTime(2026, 6, 8),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectNextDecisionPanel(
              onOpenTask: (task) => openedTaskId = task.id,
              summary: ProjectNextDecisionSummary(
                project: _project(),
                level: ProjectNextDecisionLevel.critical,
                readinessScore: 42,
                timelineIssueCount: 2,
                briefText:
                    'Store Rollout decision brief\nStatus: Decision Needed\nReadiness: 42/100',
                decisions: [
                  ProjectNextDecision(
                    title: 'Clear dependency block',
                    detail: 'Cutover Prep: Vendor sign-off blocks this task.',
                    level: ProjectNextDecisionLevel.critical,
                    kind: ProjectNextDecisionKind.timeline,
                    icon: Icons.block_outlined,
                    task: task,
                  ),
                  const ProjectNextDecision(
                    title: 'Review budget baseline',
                    detail: '52% budget used against 20% progress.',
                    level: ProjectNextDecisionLevel.warning,
                    kind: ProjectNextDecisionKind.budget,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Clear dependency block'), findsWidgets);
    expect(find.textContaining('42/100 readiness'), findsOneWidget);
    expect(find.text('Decision Needed'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Critical'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Watch'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Next'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Healthy'), findsOneWidget);
    expect(find.byType(ProjectNextDecisionBriefCard), findsOneWidget);
    expect(find.text('Decision brief'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Gantt'), findsOneWidget);

    await tester.tap(find.text('Gantt'));
    await tester.pump();

    expect(openedTaskId, 'blocked');

    await tester.tap(find.widgetWithText(ChoiceChip, 'Watch'));
    await tester.pump();

    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Gantt'), findsNothing);
    expect(
      find.textContaining('52% budget used against 20% progress'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Healthy'));
    await tester.pump();

    expect(find.text('No healthy decisions'), findsOneWidget);
  });

  testWidgets('project next decision brief card renders copy state', (
    tester,
  ) async {
    var copied = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectNextDecisionBriefCard(
            briefText: 'Store Rollout decision brief',
            copied: true,
            onCopy: () => copied = true,
          ),
        ),
      ),
    );

    expect(find.text('Decision brief'), findsOneWidget);
    expect(find.text('Store Rollout decision brief'), findsOneWidget);
    expect(find.text('Copied'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Copied'));

    expect(copied, true);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'store-rollout',
    name: 'Store Rollout',
    owner: 'Rafi',
    client: 'Retail Ops',
    startDate: DateTime(2026, 5),
    endDate: DateTime(2026, 7),
    progress: 0.2,
    budgetUsed: 0.52,
    health: ProjectHealth.blocked,
    milestones: const [],
  );
}
