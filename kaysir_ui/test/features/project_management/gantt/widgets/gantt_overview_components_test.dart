import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_overview_components.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('gantt overview components render summary and roadmap tiles', (
    tester,
  ) async {
    final tasks = [_task()];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 900,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GanttOverviewSummaryGrid(
                    tasks: tasks,
                    today: DateTime(2026, 5, 3),
                    dateRange: DateTimeRange(
                      start: DateTime(2026, 5, 1),
                      end: DateTime(2026, 6, 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GanttRoadmapPanel(
                    tasks: tasks,
                    selectedTaskId: '1.1',
                    today: DateTime(2026, 5, 3),
                    onTaskSelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Timeline Tasks'), findsOneWidget);
    expect(find.byType(GanttRoadmapTaskTile), findsNWidgets(2));
    expect(find.byType(AppStatusPill), findsNWidgets(4));
    expect(find.text('Project Planning'), findsOneWidget);
    expect(find.text('Requirements'), findsOneWidget);
    expect(find.text('Schedule Alerts'), findsOneWidget);
    expect(find.text('Dependency Alerts'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('gantt roadmap uses shared empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 320,
            child: GanttRoadmapPanel(
              tasks: const [],
              selectedTaskId: null,
              onTaskSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No timeline tasks'), findsOneWidget);
  });
}

gantt.GanttTask _task() {
  return gantt.GanttTask(
    id: '1',
    title: 'Project Planning',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 5, 12),
    progress: 0.7,
    color: Colors.blue,
    subtasks: [
      gantt.GanttTask(
        id: '1.1',
        title: 'Requirements',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 4),
        progress: 1,
        color: Colors.blueAccent,
      ),
    ],
  );
}
