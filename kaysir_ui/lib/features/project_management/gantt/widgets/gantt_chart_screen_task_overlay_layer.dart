import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_selection_context_service.dart';
import '../services/gantt_task_navigation_service.dart';
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_chart_screen_overlay_layers.dart';
import 'gantt_task_inspector_actions.dart';

/// Commands used by the full-screen Gantt task overlay adapter.
@immutable
class GanttChartScreenTaskOverlayActions {
  const GanttChartScreenTaskOverlayActions({
    required this.onRevealTask,
    required this.onClearSelection,
    this.inspectorActions,
  });

  final VoidCallback onRevealTask;
  final VoidCallback onClearSelection;
  final GanttTaskInspectorActions? inspectorActions;
}

/// Stack child that adapts selected task state into foreground overlay layers.
class GanttChartScreenTaskOverlayLayer extends StatelessWidget {
  const GanttChartScreenTaskOverlayLayer({
    required this.hiddenSelectedTask,
    required this.selectedTask,
    required this.selectionContext,
    required this.taskNavigation,
    required this.dependencyTasks,
    required this.recentEdits,
    required this.actions,
    this.placement = GanttTaskInspectorPlacement.adaptive,
    super.key,
  });

  final gantt.GanttTask? hiddenSelectedTask;
  final gantt.GanttTask? selectedTask;
  final GanttSelectionContext selectionContext;
  final GanttTaskNavigationContext taskNavigation;
  final List<gantt.GanttTask> dependencyTasks;
  final List<gantt.GanttTaskEditActivity> recentEdits;
  final GanttTaskInspectorPlacement placement;
  final GanttChartScreenTaskOverlayActions actions;

  @override
  Widget build(BuildContext context) {
    final hiddenSelectedTask = this.hiddenSelectedTask;
    final selectedTask = this.selectedTask;
    final inspectorActions = actions.inspectorActions;
    final hasHiddenSelection = hiddenSelectedTask != null;
    final hasInspector = selectedTask != null && inspectorActions != null;

    if (!hasHiddenSelection && !hasInspector) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GanttChartScreenOverlayLayers(
        hiddenSelection:
            hiddenSelectedTask == null
                ? null
                : GanttChartHiddenSelectionLayerConfig(
                  task: hiddenSelectedTask,
                  projectName: selectionContext.hiddenTaskProjectName,
                  dependencyTitle: selectionContext.hiddenTaskDependencyTitle,
                  onRevealTask: actions.onRevealTask,
                  onClearSelection: actions.onClearSelection,
                ),
        inspector:
            selectedTask == null || inspectorActions == null
                ? null
                : GanttChartInspectorLayerConfig(
                  task: selectedTask,
                  projectName: selectionContext.selectedTaskProjectName,
                  dependencyTitle: selectionContext.selectedTaskDependencyTitle,
                  dependencyTasks: dependencyTasks,
                  recentEdits: recentEdits,
                  placement: placement,
                  taskPositionLabel: taskNavigation.positionLabel,
                  previousTaskTitle: taskNavigation.previousTaskTitle,
                  nextTaskTitle: taskNavigation.nextTaskTitle,
                  actions: inspectorActions,
                ),
      ),
    );
  }
}

@Preview(name: 'Gantt chart screen task overlay layer')
Widget ganttChartScreenTaskOverlayLayerPreview() {
  final task = gantt.GanttTask(
    id: 'build',
    title: 'Build',
    startDate: DateTime(2026, 1, 5),
    endDate: DateTime(2026, 1, 12),
    progress: 0.5,
    dependsOn: 'plan',
    projectId: 'retail',
  );

  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: Color(0xFFF8FAFC), child: SizedBox.expand()),
          GanttChartScreenTaskOverlayLayer(
            hiddenSelectedTask: null,
            selectedTask: task,
            selectionContext: const GanttSelectionContext(
              selectedProject: null,
              projectsById: {},
              projectNamesById: {'retail': 'Retail Modernization'},
              selectedTaskInTimeline: null,
              selectedTaskHiddenByFilters: false,
              selectedTaskProjectId: 'retail',
              selectedTaskProjectName: 'Retail Modernization',
              selectedTaskDependencyTitle: 'Planning',
              hiddenTaskProjectName: null,
              hiddenTaskDependencyTitle: null,
              branchFocusTitle: null,
              branchFocusSummary: null,
            ),
            taskNavigation: const GanttTaskNavigationContext(
              positionLabel: '2 of 4 visible',
              previousTaskId: 'plan',
              nextTaskId: 'test',
              previousTaskTitle: 'Planning',
              nextTaskTitle: 'Testing',
            ),
            dependencyTasks: const [],
            recentEdits: const [],
            actions: GanttChartScreenTaskOverlayActions(
              onRevealTask: _previewNoop,
              onClearSelection: _previewNoop,
              inspectorActions: GanttTaskInspectorActions(
                onDismiss: _previewNoop,
                onClearSelection: _previewNoop,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _previewNoop() {}
