import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/widgets/project_timeline_health_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('project timeline health panel renders rollup metrics', (
    tester,
  ) async {
    String? focusedTaskId;
    final dependency = gantt.GanttTask(
      id: 'dependency',
      title: 'Dependency',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 20),
      progress: 0.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 760,
              child: ProjectTimelineHealthPanel(
                today: DateTime(2026, 5, 31),
                dependencyTasks: [dependency],
                onTaskFocus: (task) => focusedTaskId = task.id,
                tasks: [
                  gantt.GanttTask(
                    id: 'active',
                    title: 'Active Task',
                    startDate: DateTime(2026, 5, 25),
                    endDate: DateTime(2026, 6, 5),
                    progress: 0.4,
                  ),
                  gantt.GanttTask(
                    id: 'blocked',
                    title: 'Blocked Task',
                    startDate: DateTime(2026, 6, 8),
                    endDate: DateTime(2026, 6, 15),
                    progress: 0.1,
                    dependsOn: 'dependency',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timeline Blocked'), findsOneWidget);
    expect(find.text('2 linked tasks - 25% average progress'), findsOneWidget);
    expect(find.text('Dependency Blocks'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Blocked'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Overdue'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Due Soon'), findsOneWidget);
    expect(find.text('Blocked Task'), findsOneWidget);
    expect(find.text('Active Task'), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.byType(AppStatusPill), findsWidgets);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Blocked'));
    await tester.pump();

    expect(find.text('Blocked Task'), findsOneWidget);
    expect(find.text('Active Task'), findsNothing);

    await tester.tap(find.text('Blocked Task'));
    await tester.pump();

    expect(focusedTaskId, 'blocked');

    await tester.tap(find.widgetWithText(ChoiceChip, 'Active'));
    await tester.pump();

    expect(find.text('Blocked Task'), findsNothing);
    expect(find.text('Active Task'), findsOneWidget);
  });
}
