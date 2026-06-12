import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_inspector_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_actions.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_overlay.dart';

void main() {
  testWidgets(
    'gantt chart inspector host positions and forwards overlay actions',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                GanttChartInspectorHost(
                  task: _task,
                  projectName: 'Retail Modernization',
                  dependencyTitle: 'Planning',
                  dependencyTasks: const [],
                  recentEdits: const [],
                  taskPositionLabel: '2 of 4 visible',
                  previousTaskTitle: 'Planning',
                  nextTaskTitle: 'Testing',
                  actions: GanttTaskInspectorActions(
                    onDismiss: () => dismissed = true,
                    onClearSelection: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GanttTaskInspectorOverlay), findsOneWidget);
      expect(find.byKey(GanttTaskInspectorOverlay.panelKey), findsOneWidget);
      expect(find.text('Build - 2 of 4 visible'), findsOneWidget);

      await tester.tapAt(const Offset(4, 4));

      expect(dismissed, isTrue);
    },
  );
}

final _task = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 12),
  progress: 0.5,
  dependsOn: 'plan',
  projectId: 'retail',
);
