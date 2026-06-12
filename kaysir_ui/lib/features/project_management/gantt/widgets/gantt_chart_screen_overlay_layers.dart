import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_chart_hidden_selection_host.dart';
import 'gantt_chart_inspector_host.dart';
import 'gantt_task_inspector_actions.dart';

/// Configuration for the hidden selected-task recovery layer.
class GanttChartHiddenSelectionLayerConfig {
  const GanttChartHiddenSelectionLayerConfig({
    required this.task,
    required this.onRevealTask,
    required this.onClearSelection,
    this.projectName,
    this.dependencyTitle,
  });

  final gantt.GanttTask task;
  final String? projectName;
  final String? dependencyTitle;
  final VoidCallback onRevealTask;
  final VoidCallback onClearSelection;
}

/// Configuration for the selected task inspector overlay layer.
class GanttChartInspectorLayerConfig {
  const GanttChartInspectorLayerConfig({
    required this.task,
    required this.projectName,
    required this.dependencyTitle,
    required this.dependencyTasks,
    required this.recentEdits,
    required this.actions,
    this.placement = GanttTaskInspectorPlacement.adaptive,
    this.taskPositionLabel,
    this.previousTaskTitle,
    this.nextTaskTitle,
  });

  final gantt.GanttTask task;
  final String? projectName;
  final String? dependencyTitle;
  final List<gantt.GanttTask> dependencyTasks;
  final List<gantt.GanttTaskEditActivity> recentEdits;
  final GanttTaskInspectorActions actions;
  final GanttTaskInspectorPlacement placement;
  final String? taskPositionLabel;
  final String? previousTaskTitle;
  final String? nextTaskTitle;
}

/// Full-size overlay composer for task recovery and inspection layers.
class GanttChartScreenOverlayLayers extends StatelessWidget {
  const GanttChartScreenOverlayLayers({
    this.hiddenSelection,
    this.inspector,
    super.key,
  });

  final GanttChartHiddenSelectionLayerConfig? hiddenSelection;
  final GanttChartInspectorLayerConfig? inspector;

  @override
  Widget build(BuildContext context) {
    final hiddenSelection = this.hiddenSelection;
    final inspector = this.inspector;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (hiddenSelection != null)
          GanttChartHiddenSelectionHost(
            task: hiddenSelection.task,
            projectName: hiddenSelection.projectName,
            dependencyTitle: hiddenSelection.dependencyTitle,
            onRevealTask: hiddenSelection.onRevealTask,
            onClearSelection: hiddenSelection.onClearSelection,
          ),
        if (inspector != null)
          GanttChartInspectorHost(
            task: inspector.task,
            projectName: inspector.projectName,
            dependencyTitle: inspector.dependencyTitle,
            dependencyTasks: inspector.dependencyTasks,
            recentEdits: inspector.recentEdits,
            placement: inspector.placement,
            taskPositionLabel: inspector.taskPositionLabel,
            previousTaskTitle: inspector.previousTaskTitle,
            nextTaskTitle: inspector.nextTaskTitle,
            actions: inspector.actions,
          ),
      ],
    );
  }
}

@Preview(name: 'Gantt chart screen overlay layers')
Widget ganttChartScreenOverlayLayersPreview() {
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
          Positioned.fill(
            child: GanttChartScreenOverlayLayers(
              hiddenSelection: GanttChartHiddenSelectionLayerConfig(
                task: task,
                projectName: 'Retail Modernization',
                dependencyTitle: 'Planning',
                onRevealTask: _previewNoop,
                onClearSelection: _previewNoop,
              ),
              inspector: GanttChartInspectorLayerConfig(
                task: task,
                projectName: 'Retail Modernization',
                dependencyTitle: 'Planning',
                dependencyTasks: const [],
                recentEdits: const [],
                taskPositionLabel: '2 of 4 visible',
                previousTaskTitle: 'Planning',
                nextTaskTitle: 'Testing',
                actions: GanttTaskInspectorActions(
                  onDismiss: _previewNoop,
                  onClearSelection: _previewNoop,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void _previewNoop() {}
