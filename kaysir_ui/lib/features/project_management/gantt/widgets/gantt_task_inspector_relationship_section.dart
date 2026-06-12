import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_relationship_overview_service.dart';
import 'gantt_branch_focus_preview_panel.dart';
import 'gantt_dependency_chain_panel.dart';
import 'gantt_successor_impact_panel.dart';
import 'gantt_task_relationship_overview_strip.dart';

class GanttTaskInspectorRelationshipSection extends StatelessWidget {
  const GanttTaskInspectorRelationshipSection({
    required this.task,
    required this.dependencyTasks,
    this.today,
    this.onTaskSelected,
    this.onFocusBranch,
    super.key,
  });

  final gantt.GanttTask task;
  final List<gantt.GanttTask> dependencyTasks;
  final DateTime? today;
  final ValueChanged<String>? onTaskSelected;
  final VoidCallback? onFocusBranch;

  @override
  Widget build(BuildContext context) {
    final overview = const GanttTaskRelationshipOverviewService().build(
      task: task,
      dependencyTasks: dependencyTasks,
      today: today,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GanttTaskRelationshipOverviewStrip(overview: overview),
        const SizedBox(height: 10),
        GanttDependencyChainPanel(
          task: task,
          dependencyTasks: dependencyTasks,
          today: today,
          showEmptyState: true,
          onTaskSelected: onTaskSelected,
        ),
        const SizedBox(height: 10),
        GanttSuccessorImpactPanel(
          summary: overview.successorImpact,
          showEmptyState: true,
          onTaskSelected: onTaskSelected,
        ),
        const SizedBox(height: 10),
        GanttBranchFocusPreviewPanel(
          task: task,
          dependencyTasks: dependencyTasks,
          today: today,
          onFocusBranch: onFocusBranch,
          onTaskSelected: onTaskSelected,
        ),
      ],
    );
  }
}
