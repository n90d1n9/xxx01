import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_chart_interaction_provider.dart';
import 'gantt_task_inspector_actions.dart';
import 'gantt_task_inspector_overlay.dart';

/// Stack layer that positions the selected task inspector over the Gantt chart.
class GanttChartInspectorHost extends StatelessWidget {
  const GanttChartInspectorHost({
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
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GanttTaskInspectorOverlay(
        task: task,
        projectName: projectName,
        dependencyTitle: dependencyTitle,
        dependencyTasks: dependencyTasks,
        recentEdits: recentEdits,
        placement: placement,
        taskPositionLabel: taskPositionLabel,
        previousTaskTitle: previousTaskTitle,
        nextTaskTitle: nextTaskTitle,
        actions: actions,
      ),
    );
  }
}

@Preview(name: 'Gantt chart inspector host')
Widget ganttChartInspectorHostPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: Color(0xFFF8FAFC), child: SizedBox.expand()),
          GanttChartInspectorHost(
            task: gantt.GanttTask(
              id: 'build',
              title: 'Build',
              startDate: DateTime(2026, 1, 5),
              endDate: DateTime(2026, 1, 12),
              progress: 0.5,
              dependsOn: 'plan',
              projectId: 'retail',
            ),
            projectName: 'Retail Modernization',
            dependencyTitle: 'Planning',
            dependencyTasks: const [],
            recentEdits: const [],
            taskPositionLabel: '2 of 4 visible',
            previousTaskTitle: 'Planning',
            nextTaskTitle: 'Testing',
            actions: GanttTaskInspectorActions(
              onDismiss: () {},
              onClearSelection: () {},
            ),
          ),
        ],
      ),
    ),
  );
}
