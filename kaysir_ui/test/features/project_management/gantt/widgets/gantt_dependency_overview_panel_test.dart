import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_dependency_overview_panel.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('gantt dependency overview panel renders readiness signals', (
    tester,
  ) async {
    String? selectedTaskId;
    final dependency = _task(
      id: 'planning',
      title: 'Project Planning',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 20),
      progress: 0.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: GanttDependencyOverviewPanel(
                tasks: [
                  _task(
                    id: 'design',
                    title: 'Design Phase',
                    start: DateTime(2026, 5, 28),
                    dependsOn: 'planning',
                    projectId: 'warehouse',
                  ),
                ],
                dependencyTasks: [dependency],
                projectNamesById: const {'warehouse': 'Warehouse Automation'},
                today: DateTime(2026, 5, 31),
                onTaskSelected: (taskId) => selectedTaskId = taskId,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Dependencies Blocked'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Design Phase'), findsOneWidget);
    expect(find.textContaining('Warehouse Automation'), findsOneWidget);
    expect(find.textContaining('incomplete and now blocks'), findsOneWidget);

    await tester.tap(find.text('Inspect'));
    expect(selectedTaskId, 'design');
  });

  testWidgets('gantt dependency overview panel renders empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GanttDependencyOverviewPanel(tasks: [], dependencyTasks: []),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No dependency links'), findsOneWidget);
  });
}

gantt.GanttTask _task({
  required String id,
  String title = 'Task',
  required DateTime start,
  DateTime? end,
  double progress = 0,
  String? dependsOn,
  String? projectId,
}) {
  return gantt.GanttTask(
    id: id,
    title: title,
    startDate: start,
    endDate: end ?? start.add(const Duration(days: 3)),
    progress: progress,
    dependsOn: dependsOn,
    projectId: projectId,
  );
}
