import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_hidden_selection_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_inspector_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_screen_overlay_layers.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_actions.dart';

void main() {
  testWidgets('gantt chart overlay layers render configured task surfaces', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              Positioned.fill(
                child: GanttChartScreenOverlayLayers(
                  hiddenSelection: GanttChartHiddenSelectionLayerConfig(
                    task: _task('hidden'),
                    projectName: 'Retail Modernization',
                    dependencyTitle: 'Discovery',
                    onRevealTask: () {},
                    onClearSelection: () {},
                  ),
                  inspector: GanttChartInspectorLayerConfig(
                    task: _task('selected'),
                    projectName: 'Retail Modernization',
                    dependencyTitle: 'Planning',
                    dependencyTasks: const [],
                    recentEdits: const [],
                    taskPositionLabel: '1 of 3 visible',
                    actions: GanttTaskInspectorActions(
                      onDismiss: () {},
                      onClearSelection: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GanttChartHiddenSelectionHost), findsOneWidget);
    expect(find.byType(GanttChartInspectorHost), findsOneWidget);
    expect(find.text('Hidden by filters'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsWidgets);
  });

  testWidgets('gantt chart overlay layers stay empty without configurations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(),
              Positioned.fill(child: GanttChartScreenOverlayLayers()),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GanttChartHiddenSelectionHost), findsNothing);
    expect(find.byType(GanttChartInspectorHost), findsNothing);
  });
}

gantt.GanttTask _task(String id) {
  return gantt.GanttTask(
    id: id,
    title: 'Task $id',
    startDate: DateTime(2026, 1, 5),
    endDate: DateTime(2026, 1, 12),
    progress: 0.4,
    dependsOn: 'plan',
    projectId: 'retail',
  );
}
