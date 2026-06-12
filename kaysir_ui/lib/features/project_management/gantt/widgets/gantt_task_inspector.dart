import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

import '../gantt_dashboard.dart' as gantt;
import 'gantt_task_inspector_actions.dart';
import 'gantt_task_inspector_content.dart';
import 'gantt_task_inspector_section_config.dart';

/// Inspector panel that renders an empty prompt or a selected task workspace.
class GanttTaskInspectorPanel extends StatelessWidget {
  const GanttTaskInspectorPanel({
    required this.task,
    required this.projectName,
    required this.dependencyTitle,
    this.actions,
    this.onClearSelection,
    this.onOpenProject,
    this.onUndoLastEdit,
    this.onTaskKindChanged,
    this.onStartDateChanged,
    this.onEndDateChanged,
    this.onMilestoneDateChanged,
    this.onDependencyChanged,
    this.onProgressChanged,
    this.onTaskSelected,
    this.onFocusBranch,
    this.onRecentEditSelected,
    this.recentEdits = const [],
    this.dependencyTasks = const [],
    this.sectionConfig = GanttTaskInspectorSectionConfig.all,
    this.activityNow,
    this.today,
    super.key,
  }) : assert(
         actions != null || onClearSelection != null,
         'Provide actions or onClearSelection.',
       );

  final gantt.GanttTask? task;
  final String? projectName;
  final String? dependencyTitle;
  final GanttTaskInspectorActions? actions;
  final VoidCallback? onClearSelection;
  final VoidCallback? onOpenProject;
  final VoidCallback? onUndoLastEdit;
  final ValueChanged<gantt.GanttTaskKind>? onTaskKindChanged;
  final ValueChanged<DateTime>? onStartDateChanged;
  final ValueChanged<DateTime>? onEndDateChanged;
  final ValueChanged<DateTime>? onMilestoneDateChanged;
  final ValueChanged<String?>? onDependencyChanged;
  final ValueChanged<double>? onProgressChanged;
  final ValueChanged<String>? onTaskSelected;
  final VoidCallback? onFocusBranch;
  final ValueChanged<gantt.GanttTaskEditActivity>? onRecentEditSelected;
  final List<gantt.GanttTaskEditActivity> recentEdits;
  final List<gantt.GanttTask> dependencyTasks;
  final GanttTaskInspectorSectionConfig sectionConfig;
  final DateTime? activityNow;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final task = this.task;

    if (task == null) {
      return const AppEmptyState(
        icon: Icons.ads_click_outlined,
        title: 'Select a timeline task',
        message:
            'Choose a roadmap item to inspect its progress, dates, dependency, and linked project.',
      );
    }

    final actions = GanttTaskInspectorActions.resolve(
      actions: this.actions,
      onClearSelection: onClearSelection,
      onOpenProject: onOpenProject,
      onUndoLastEdit: onUndoLastEdit,
      onTaskKindChanged: onTaskKindChanged,
      onStartDateChanged: onStartDateChanged,
      onEndDateChanged: onEndDateChanged,
      onMilestoneDateChanged: onMilestoneDateChanged,
      onDependencyChanged: onDependencyChanged,
      onProgressChanged: onProgressChanged,
      onTaskSelected: onTaskSelected,
      onFocusBranch: onFocusBranch,
      onRecentEditSelected: onRecentEditSelected,
    );

    return GanttTaskInspectorContent(
      task: task,
      projectName: projectName,
      dependencyTitle: dependencyTitle,
      dependencyTasks: dependencyTasks,
      recentEdits: recentEdits,
      sectionConfig: sectionConfig,
      activityNow: activityNow,
      today: today,
      actions: actions,
    );
  }
}

@Preview(name: 'Gantt task inspector panel')
Widget ganttTaskInspectorPanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GanttTaskInspectorPanel(
          task: gantt.GanttTask(
            id: 'design',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            dependsOn: 'planning',
            projectId: 'warehouse-automation',
          ),
          projectName: 'Warehouse Automation',
          dependencyTitle: 'Project Planning',
          today: DateTime(2026, 5, 6),
          actions: GanttTaskInspectorActions(
            onDismiss: () {},
            onClearSelection: () {},
          ),
        ),
      ),
    ),
  );
}
