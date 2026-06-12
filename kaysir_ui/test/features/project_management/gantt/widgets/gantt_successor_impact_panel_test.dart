import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_successor_impact_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_successor_impact_panel.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('gantt successor impact panel renders downstream signals', (
    tester,
  ) async {
    String? selectedTaskId;
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 6, 6),
      progress: 0.4,
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 5),
      end: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: design,
      dependencyTasks: [design, build, launch],
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttSuccessorImpactPanel(
              summary: summary,
              onTaskSelected: (taskId) => selectedTaskId = taskId,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Downstream Impact'), findsOneWidget);
    expect(find.text('2 successors'), findsOneWidget);
    expect(find.text('1 direct'), findsOneWidget);
    expect(find.text('1 indirect'), findsWidgets);
    expect(find.text('1 conflict'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.textContaining('starts before Design clears'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsWidgets);

    await tester.tap(
      find.byKey(GanttSuccessorImpactPanel.inspectTaskButtonKey('build')),
    );

    expect(selectedTaskId, 'build');
  });

  testWidgets('gantt successor impact panel reveals overflow successors', (
    tester,
  ) async {
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 6, 6),
      progress: 0.4,
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 5),
      end: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: design,
      dependencyTasks: [design, build, launch],
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttSuccessorImpactPanel(summary: summary, maxItems: 1),
          ),
        ),
      ),
    );

    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Launch'), findsNothing);
    expect(find.text('Show 1 More'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttSuccessorImpactPanel.overflowToggleButtonKey),
    );
    await tester.pumpAndSettle();

    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('Show Less'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttSuccessorImpactPanel.overflowToggleButtonKey),
    );
    await tester.pumpAndSettle();

    expect(find.text('Launch'), findsNothing);
    expect(find.text('Show 1 More'), findsOneWidget);
  });

  testWidgets('gantt successor impact panel filters attention successors', (
    tester,
  ) async {
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 6, 6),
      progress: 1,
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 5),
      end: DateTime(2026, 6, 12),
      progress: 0.35,
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );
    final archive = _task(
      id: 'archive',
      title: 'Archive',
      start: DateTime(2026, 6, 10),
      end: DateTime(2026, 6, 11),
      dependsOn: 'design',
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: design,
      dependencyTasks: [design, build, launch, archive],
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttSuccessorImpactPanel(summary: summary, maxItems: 5),
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);

    await tester.tap(find.text('Attention'));
    await tester.pumpAndSettle();

    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Launch'), findsOneWidget);
    expect(find.text('Archive'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttSuccessorImpactPanel(
              summary: summary,
              maxItems: 5,
              showViewFilter: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('All'), findsNothing);
    expect(find.text('Attention'), findsNothing);
    expect(find.text('Archive'), findsOneWidget);
  });

  testWidgets('gantt successor impact panel can show a clear empty state', (
    tester,
  ) async {
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 6, 6),
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 6, 7),
      end: DateTime(2026, 6, 12),
      dependsOn: 'design',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 6, 21),
      dependsOn: 'build',
    );

    final summary = buildGanttSuccessorImpactSummary(
      task: launch,
      dependencyTasks: [design, build, launch],
      today: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GanttSuccessorImpactPanel(summary: summary)),
      ),
    );

    expect(find.text('No Downstream Impact'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttSuccessorImpactPanel(
            summary: summary,
            showEmptyState: true,
          ),
        ),
      ),
    );

    expect(find.text('No Downstream Impact'), findsOneWidget);
    expect(
      find.text('No downstream successors depend on this task.'),
      findsOneWidget,
    );
    expect(find.text('Clear'), findsOneWidget);
  });
}

gantt.GanttTask _task({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  double progress = 0,
  String? dependsOn,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end,
    progress: progress,
    dependsOn: dependsOn,
  );
}
