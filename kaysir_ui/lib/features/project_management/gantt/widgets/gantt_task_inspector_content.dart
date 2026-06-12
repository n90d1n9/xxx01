import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_inspector_summary_service.dart';
import 'gantt_task_inspector_action_bar.dart';
import 'gantt_task_inspector_actions.dart';
import 'gantt_task_inspector_collapsible_section.dart';
import 'gantt_task_inspector_editing_section.dart';
import 'gantt_task_inspector_readiness_section.dart';
import 'gantt_task_inspector_relationship_section.dart';
import 'gantt_task_inspector_section_config.dart';
import 'gantt_task_inspector_summary_section.dart';

/// Composes the selected task inspector sections and forwards inspector actions.
class GanttTaskInspectorContent extends StatelessWidget {
  const GanttTaskInspectorContent({
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

  final gantt.GanttTask task;
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
    final summary = const GanttTaskInspectorSummaryService().build(
      task: task,
      dependencyTasks: dependencyTasks,
      today: today,
      fallbackDependencyTitle: dependencyTitle,
    );

    final sections = [
      if (sectionConfig.showSummary)
        _InspectorContentSection(
          section: GanttTaskInspectorSection.summary,
          child: GanttTaskInspectorSummarySection(
            task: task,
            summary: summary,
            projectName: projectName,
          ),
          spacingAfter: 12,
        ),
      if (sectionConfig.showEditing)
        _InspectorContentSection(
          section: GanttTaskInspectorSection.editing,
          child: GanttTaskInspectorEditingSection(
            task: task,
            recentEdits: recentEdits,
            activityNow: activityNow,
            onRecentEditSelected: actions.onRecentEditSelected,
            onProgressChanged: actions.onProgressChanged,
            onTaskKindChanged: actions.onTaskKindChanged,
            onStartDateChanged: actions.onStartDateChanged,
            onEndDateChanged: actions.onEndDateChanged,
            onMilestoneDateChanged: actions.onMilestoneDateChanged,
          ),
          spacingAfter: 12,
        ),
      if (sectionConfig.showReadiness)
        _InspectorContentSection(
          section: GanttTaskInspectorSection.readiness,
          child: GanttTaskInspectorReadinessSection(
            task: task,
            summary: summary,
            dependencyTasks: dependencyTasks,
            dependencyTitle: dependencyTitle,
            onDependencyChanged: actions.onDependencyChanged,
          ),
          spacingAfter: 10,
        ),
      if (sectionConfig.showRelationships)
        _InspectorContentSection(
          section: GanttTaskInspectorSection.relationships,
          child: GanttTaskInspectorRelationshipSection(
            task: task,
            dependencyTasks: dependencyTasks,
            today: today,
            onTaskSelected: actions.onTaskSelected,
            onFocusBranch: actions.onFocusBranch,
          ),
          spacingAfter: 12,
        ),
      if (sectionConfig.showActions)
        _InspectorContentSection(
          section: GanttTaskInspectorSection.actions,
          child: GanttTaskInspectorActionBar(
            projectName: projectName,
            onUndoLastEdit: actions.onUndoLastEdit,
            onOpenProject: actions.onOpenProject,
            onClearSelection: actions.onClearSelection,
          ),
          spacingAfter: 0,
        ),
    ];

    if (sections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          _sectionChild(sections[index]),
          if (index < sections.length - 1)
            SizedBox(height: sections[index].spacingAfter),
        ],
      ],
    );
  }

  Widget _sectionChild(_InspectorContentSection section) {
    if (!sectionConfig.isCollapsible(section.section)) {
      return section.child;
    }

    return GanttTaskInspectorCollapsibleSection(
      section: section.section,
      initiallyCollapsed: sectionConfig.isInitiallyCollapsed(section.section),
      child: section.child,
    );
  }
}

/// Internal descriptor for a rendered inspector content section.
class _InspectorContentSection {
  const _InspectorContentSection({
    required this.section,
    required this.child,
    required this.spacingAfter,
  });

  final GanttTaskInspectorSection section;
  final Widget child;
  final double spacingAfter;
}
