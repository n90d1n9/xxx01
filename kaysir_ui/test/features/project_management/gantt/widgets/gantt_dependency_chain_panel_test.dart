import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_chain_panel.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('gantt dependency chain panel renders upstream path', (
    tester,
  ) async {
    String? selectedTaskId;
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 20),
      progress: 1,
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 6),
      progress: 0.2,
      dependsOn: 'design',
    );
    final launch = gantt.GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 6, 10),
      endDate: DateTime(2026, 6, 15),
      dependsOn: 'build',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 460,
            child: GanttDependencyChainPanel(
              task: launch,
              dependencyTasks: [design, build, launch],
              today: DateTime(2026, 5, 31),
              onTaskSelected: (taskId) => selectedTaskId = taskId,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dependency Chain'), findsOneWidget);
    expect(find.text('Waiting on Build.'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('2 predecessors'), findsOneWidget);
    expect(find.text('1 needs attention'), findsOneWidget);
    expect(find.text('1 ready'), findsOneWidget);
    expect(find.text('Nearest'), findsOneWidget);
    expect(find.text('Upstream 2'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsWidgets);

    await tester.tap(
      find.byKey(GanttDependencyChainPanel.inspectTaskButtonKey('build')),
    );

    expect(selectedTaskId, 'build');
  });

  testWidgets('gantt dependency chain panel reveals overflow predecessors', (
    tester,
  ) async {
    final discovery = _task(
      id: 'discovery',
      title: 'Discovery',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 4),
      progress: 1,
    );
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 5),
      end: DateTime(2026, 5, 8),
      progress: 1,
      dependsOn: 'discovery',
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 5, 9),
      end: DateTime(2026, 5, 12),
      progress: 1,
      dependsOn: 'design',
    );
    final qa = _task(
      id: 'qa',
      title: 'QA',
      start: DateTime(2026, 5, 13),
      end: DateTime(2026, 5, 16),
      dependsOn: 'build',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 5, 17),
      end: DateTime(2026, 5, 18),
      dependsOn: 'qa',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttDependencyChainPanel(
              task: launch,
              dependencyTasks: [discovery, design, build, qa, launch],
              maxNodes: 2,
              today: DateTime(2026, 5, 10),
            ),
          ),
        ),
      ),
    );

    expect(find.text('QA'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('4 predecessors'), findsOneWidget);
    expect(find.text('1 needs attention'), findsOneWidget);
    expect(find.text('3 ready'), findsOneWidget);
    expect(find.text('Nearest'), findsOneWidget);
    expect(find.text('Upstream 2'), findsOneWidget);
    expect(find.text('Upstream 3'), findsNothing);
    expect(find.text('Design'), findsNothing);
    expect(find.text('Discovery'), findsNothing);
    expect(find.text('Show 2 More'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttDependencyChainPanel.overflowToggleButtonKey),
    );
    await tester.pumpAndSettle();

    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Discovery'), findsOneWidget);
    expect(find.text('Upstream 3'), findsOneWidget);
    expect(find.text('Upstream 4'), findsOneWidget);
    expect(find.text('Show Less'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttDependencyChainPanel.overflowToggleButtonKey),
    );
    await tester.pumpAndSettle();

    expect(find.text('Design'), findsNothing);
    expect(find.text('Discovery'), findsNothing);
    expect(find.text('Show 2 More'), findsOneWidget);
  });

  testWidgets('gantt dependency chain panel filters attention predecessors', (
    tester,
  ) async {
    final discovery = _task(
      id: 'discovery',
      title: 'Discovery',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 4),
      progress: 1,
    );
    final design = _task(
      id: 'design',
      title: 'Design',
      start: DateTime(2026, 5, 5),
      end: DateTime(2026, 5, 8),
      progress: 1,
      dependsOn: 'discovery',
    );
    final build = _task(
      id: 'build',
      title: 'Build',
      start: DateTime(2026, 5, 9),
      end: DateTime(2026, 5, 12),
      progress: 1,
      dependsOn: 'design',
    );
    final qa = _task(
      id: 'qa',
      title: 'QA',
      start: DateTime(2026, 5, 13),
      end: DateTime(2026, 5, 16),
      dependsOn: 'build',
    );
    final launch = _task(
      id: 'launch',
      title: 'Launch',
      start: DateTime(2026, 5, 17),
      end: DateTime(2026, 5, 18),
      dependsOn: 'qa',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttDependencyChainPanel(
              task: launch,
              dependencyTasks: [discovery, design, build, qa, launch],
              maxNodes: 5,
              today: DateTime(2026, 5, 10),
            ),
          ),
        ),
      ),
    );

    expect(find.text('All'), findsOneWidget);
    expect(find.text('Attention'), findsOneWidget);
    expect(find.text('QA'), findsOneWidget);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Discovery'), findsOneWidget);

    await tester.tap(find.text('Attention'));
    await tester.pumpAndSettle();

    expect(find.text('QA'), findsOneWidget);
    expect(find.text('Build'), findsNothing);
    expect(find.text('Design'), findsNothing);
    expect(find.text('Discovery'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            child: GanttDependencyChainPanel(
              task: launch,
              dependencyTasks: [discovery, design, build, qa, launch],
              maxNodes: 5,
              showViewFilter: false,
              today: DateTime(2026, 5, 10),
            ),
          ),
        ),
      ),
    );

    expect(find.text('All'), findsNothing);
    expect(find.text('Attention'), findsNothing);
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Design'), findsOneWidget);
    expect(find.text('Discovery'), findsOneWidget);
  });

  testWidgets('gantt dependency chain panel can show a clear empty state', (
    tester,
  ) async {
    final planning = _task(
      id: 'planning',
      title: 'Planning',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 4),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttDependencyChainPanel(
            task: planning,
            dependencyTasks: [planning],
          ),
        ),
      ),
    );

    expect(find.text('No Upstream Dependencies'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttDependencyChainPanel(
            task: planning,
            dependencyTasks: [planning],
            showEmptyState: true,
          ),
        ),
      ),
    );

    expect(find.text('No Upstream Dependencies'), findsOneWidget);
    expect(find.text('No upstream dependency chain.'), findsOneWidget);
    expect(find.text('Independent'), findsOneWidget);
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
