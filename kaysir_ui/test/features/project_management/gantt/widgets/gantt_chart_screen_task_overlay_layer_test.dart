import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_selection_context_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_navigation_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_hidden_selection_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_inspector_host.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_screen_task_overlay_layer.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_selected_task_focus_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_actions.dart';

void main() {
  testWidgets('gantt chart screen task overlay renders hidden recovery layer', (
    tester,
  ) async {
    var revealCount = 0;
    var clearCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              GanttChartScreenTaskOverlayLayer(
                hiddenSelectedTask: _task('hidden'),
                selectedTask: null,
                selectionContext: _selectionContext,
                taskNavigation: _taskNavigation,
                dependencyTasks: const [],
                recentEdits: const [],
                actions: GanttChartScreenTaskOverlayActions(
                  onRevealTask: () => revealCount++,
                  onClearSelection: () => clearCount++,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GanttChartHiddenSelectionHost), findsOneWidget);
    expect(find.byType(GanttChartInspectorHost), findsNothing);
    expect(find.text('Hidden by filters'), findsOneWidget);

    await tester.tap(find.byKey(GanttSelectedTaskFocusStrip.revealButtonKey));
    await tester.pump();

    expect(revealCount, 1);
    expect(clearCount, 0);
  });

  testWidgets('gantt chart screen task overlay renders inspector layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const SizedBox.expand(),
              GanttChartScreenTaskOverlayLayer(
                hiddenSelectedTask: null,
                selectedTask: _task('selected'),
                selectionContext: _selectionContext,
                taskNavigation: _taskNavigation,
                dependencyTasks: const [],
                recentEdits: const [],
                actions: GanttChartScreenTaskOverlayActions(
                  onRevealTask: _noop,
                  onClearSelection: _noop,
                  inspectorActions: GanttTaskInspectorActions(
                    onDismiss: _noop,
                    onClearSelection: _noop,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GanttChartHiddenSelectionHost), findsNothing);
    expect(find.byType(GanttChartInspectorHost), findsOneWidget);
    expect(find.text('Task Inspector'), findsOneWidget);
  });

  testWidgets('gantt chart screen task overlay stays empty without tasks', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              SizedBox.expand(),
              GanttChartScreenTaskOverlayLayer(
                hiddenSelectedTask: null,
                selectedTask: null,
                selectionContext: _selectionContext,
                taskNavigation: GanttTaskNavigationContext.empty,
                dependencyTasks: [],
                recentEdits: [],
                actions: GanttChartScreenTaskOverlayActions(
                  onRevealTask: _noop,
                  onClearSelection: _noop,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GanttChartHiddenSelectionHost), findsNothing);
    expect(find.byType(GanttChartInspectorHost), findsNothing);
  });
}

const _selectionContext = GanttSelectionContext(
  selectedProject: null,
  projectsById: {},
  projectNamesById: {'retail': 'Retail Modernization'},
  selectedTaskInTimeline: null,
  selectedTaskHiddenByFilters: false,
  selectedTaskProjectId: 'retail',
  selectedTaskProjectName: 'Retail Modernization',
  selectedTaskDependencyTitle: 'Planning',
  hiddenTaskProjectName: 'Retail Modernization',
  hiddenTaskDependencyTitle: 'Discovery',
  branchFocusTitle: null,
  branchFocusSummary: null,
);

const _taskNavigation = GanttTaskNavigationContext(
  positionLabel: '2 of 4 visible',
  previousTaskId: 'plan',
  nextTaskId: 'test',
  previousTaskTitle: 'Planning',
  nextTaskTitle: 'Testing',
);

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

void _noop() {}
