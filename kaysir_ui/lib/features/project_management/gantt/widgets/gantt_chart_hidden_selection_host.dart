import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_selected_task_focus_strip.dart';

/// Stack layer that anchors hidden selected-task recovery actions.
class GanttChartHiddenSelectionHost extends StatelessWidget {
  const GanttChartHiddenSelectionHost({
    required this.task,
    required this.onRevealTask,
    required this.onClearSelection,
    this.projectName,
    this.dependencyTitle,
    super.key,
  });

  final gantt.GanttTask task;
  final String? projectName;
  final String? dependencyTitle;
  final VoidCallback onRevealTask;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: GanttSelectedTaskFocusStrip(
        task: task,
        hiddenByFilters: true,
        projectName: projectName,
        dependencyTitle: dependencyTitle,
        onInspectTask: onRevealTask,
        onClearSelection: onClearSelection,
      ),
    );
  }
}

@Preview(name: 'Gantt hidden selection host')
Widget ganttChartHiddenSelectionHostPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: Color(0xFFF8FAFC), child: SizedBox.expand()),
          GanttChartHiddenSelectionHost(
            task: gantt.GanttTask(
              id: 'planning',
              title: 'Project Planning',
              startDate: DateTime(2026, 1, 5),
              endDate: DateTime(2026, 1, 12),
              progress: 0.4,
              dependsOn: 'brief',
              projectId: 'retail',
            ),
            projectName: 'Retail Modernization',
            dependencyTitle: 'Discovery Brief',
            onRevealTask: () {},
            onClearSelection: () {},
          ),
        ],
      ),
    ),
  );
}
