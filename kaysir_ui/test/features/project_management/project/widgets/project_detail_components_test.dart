import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_handoff_brief_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_detail_components.dart';
import 'package:kaysir/features/project_management/project/widgets/project_handoff_brief_panel.dart';

void main() {
  testWidgets('linked timeline panel reports focused task taps', (
    tester,
  ) async {
    gantt.GanttTask? focusedTask;
    final task = gantt.GanttTask(
      id: '3',
      title: 'Development',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 12),
      progress: 0.35,
      color: Colors.orange,
      projectId: 'mobile-field-app',
    );
    final milestone = gantt.GanttTask(
      id: '5',
      title: 'Launch Readiness',
      startDate: DateTime(2026, 6, 12),
      endDate: DateTime(2026, 6, 12),
      progress: 0,
      color: Colors.deepPurple,
      kind: gantt.GanttTaskKind.milestone,
      projectId: 'mobile-field-app',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectLinkedTimelinePanel(
              tasks: [milestone, task],
              today: DateTime(2026, 5, 31),
              onTaskFocus: (task) => focusedTask = task,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Next timeline item: Development'), findsOneWidget);
    expect(find.text('2 linked - 1 milestones - 0 complete'), findsOneWidget);
    expect(find.text('Development'), findsOneWidget);
    expect(find.text('Launch Readiness'), findsOneWidget);
    expect(find.text('Due Soon'), findsOneWidget);
    expect(find.text('Scheduled'), findsOneWidget);
    expect(find.text('Milestone'), findsOneWidget);
    expect(find.textContaining('Starts in 1 day'), findsOneWidget);
    expect(find.textContaining('Milestone - Jun 12'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsNWidgets(2));

    await tester.tap(find.text('Development'));

    expect(focusedTask?.id, '3');
  });

  testWidgets('attention panel renders synthesized delivery signals', (
    tester,
  ) async {
    final project = ProjectPortfolioItem(
      id: 'mobile-field-app',
      name: 'Mobile Field App',
      owner: 'Nadia Putri',
      client: 'Service Team',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 7, 1),
      progress: 0.2,
      budgetUsed: 0.48,
      health: ProjectHealth.blocked,
      milestones: [
        ProjectMilestone(
          label: 'API Ready',
          dueDate: DateTime(2026, 6, 2),
          isComplete: false,
        ),
      ],
      risks: const [
        ProjectDeliveryRisk(
          title: 'API contract drift',
          detail: 'Payload contract is not signed.',
          severity: ProjectHealth.blocked,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectAttentionPanel(
              project: project,
              timelineTasks: [
                gantt.GanttTask(
                  id: '3',
                  title: 'Development',
                  startDate: DateTime(2026, 5, 1),
                  endDate: DateTime(2026, 5, 20),
                  progress: 0.35,
                ),
              ],
              today: DateTime(2026, 5, 31),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Unblock delivery path'), findsOneWidget);
    expect(find.text('Recover overdue timeline'), findsOneWidget);
    expect(find.text('Rebalance spend'), findsOneWidget);
    expect(find.text('Critical'), findsWidgets);
  });

  testWidgets('handoff brief panel renders owner and next-action context', (
    tester,
  ) async {
    final project = demoProjectPortfolio.firstWhere(
      (project) => project.id == 'mobile-field-app',
    );
    final brief = buildProjectHandoffBrief(
      project: project,
      timelineTasks: [
        gantt.GanttTask(
          id: '3',
          title: 'Development',
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 20),
          progress: 0.35,
        ),
      ],
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectHandoffBriefPanel(brief: brief),
          ),
        ),
      ),
    );

    expect(find.text('Handoff blocked delivery'), findsOneWidget);
    expect(find.text('Owner handoff'), findsOneWidget);
    expect(
      find.text('Nadia Putri - Sponsor: Customer Service'),
      findsOneWidget,
    );
    expect(find.text('API Ready'), findsOneWidget);
    expect(find.text('API contract drift'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Handoff brief'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);

    final copyButton = find.widgetWithText(OutlinedButton, 'Copy');
    expect(copyButton, findsOneWidget);

    await tester.ensureVisible(copyButton);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('milestone timeline renders time-aware milestone states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectMilestoneTimeline(
              today: DateTime(2026, 5, 31),
              milestones: [
                ProjectMilestone(
                  label: 'Done Audit',
                  dueDate: DateTime(2026, 5, 12),
                  isComplete: true,
                ),
                ProjectMilestone(
                  label: 'Contract',
                  dueDate: DateTime(2026, 5, 28),
                  isComplete: false,
                ),
                ProjectMilestone(
                  label: 'Pilot',
                  dueDate: DateTime(2026, 6, 3),
                  isComplete: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Next milestone: Contract'), findsOneWidget);
    expect(find.text('2 open - 1 done - 1 overdue'), findsOneWidget);
    expect(find.text('3d overdue'), findsWidgets);
    expect(find.textContaining('Due in 3d'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
  });
}
