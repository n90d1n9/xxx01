import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_schedule_focus_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('gantt schedule focus panel renders ranked schedule risks', (
    tester,
  ) async {
    String? selectedTaskId;
    String? selectedProjectId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: GanttScheduleFocusPanel(
                tasks: [_lateTask(), _behindTask()],
                projectNamesById: const {'retail': 'Retail Modernization'},
                today: DateTime(2026, 5, 6),
                onTaskSelected: (taskId) => selectedTaskId = taskId,
                onProjectSelected: (projectId) => selectedProjectId = projectId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Schedule Critical'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Behind'), findsWidgets);
    expect(find.text('Starting Soon'), findsOneWidget);
    expect(find.text('Focus Items'), findsOneWidget);
    expect(find.text('Dependencies'), findsOneWidget);
    expect(find.text('Blocked dep'), findsOneWidget);
    expect(find.text('Late Foundation'), findsOneWidget);
    expect(find.text('Slow Fit Out'), findsOneWidget);
    expect(find.textContaining('Retail Modernization'), findsWidgets);
    expect(find.textContaining('Reset finish plan'), findsWidgets);
    expect(find.text('Recovery brief'), findsOneWidget);
    expect(find.text('Copy ready'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Project'), findsOneWidget);
    expect(
      find.textContaining('Roadmap schedule recovery brief'),
      findsOneWidget,
    );
    expect(find.textContaining('Dependency impact'), findsOneWidget);

    await tester.tap(find.text('Inspect').first);
    await tester.pump();

    expect(selectedTaskId, 'late');

    await tester.tap(find.text('Project'));
    await tester.pump();

    expect(selectedProjectId, 'retail');
  });

  testWidgets('gantt schedule focus panel renders empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GanttScheduleFocusPanel(tasks: [])),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No schedule focus yet'), findsOneWidget);
  });
}

gantt.GanttTask _lateTask() {
  return gantt.GanttTask(
    id: 'late',
    title: 'Late Foundation',
    startDate: DateTime(2026, 4, 1),
    endDate: DateTime(2026, 4, 8),
    progress: 0.5,
    projectId: 'retail',
  );
}

gantt.GanttTask _behindTask() {
  return gantt.GanttTask(
    id: 'behind',
    title: 'Slow Fit Out',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 5, 10),
    progress: 0.2,
    dependsOn: 'late',
  );
}
