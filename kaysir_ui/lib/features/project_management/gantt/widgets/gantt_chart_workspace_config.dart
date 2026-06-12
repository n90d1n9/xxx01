import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_branch_focus_summary_service.dart';
import '../services/gantt_chart_empty_state_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import '../states/gantt_filter_provider.dart';

/// Header inputs and commands for the full-screen Gantt workspace.
class GanttChartWorkspaceHeaderConfig {
  const GanttChartWorkspaceHeaderConfig({
    required this.controlsExpanded,
    required this.onToggleControls,
    required this.onOpenViewSettings,
    required this.onOpenDashboard,
    required this.dateRange,
    required this.viewMode,
    required this.projects,
    required this.selectedProjectId,
    required this.searchController,
    required this.searchFocusNode,
    required this.statusFilter,
    required this.timelineView,
    required this.tasks,
    required this.rangeTasks,
    required this.dependencyTasks,
    required this.query,
    required this.selectedProject,
    required this.canUndoLastEdit,
    required this.onUndoLastEdit,
    required this.onClearFilters,
    this.branchFocusTitle,
    this.branchFocusSummary,
    this.onClearProjectFilter,
    this.onClearBranchFocus,
    this.onClearTimelineView,
    this.onClearRangePreset,
    this.onClearStatusFilter,
    this.onClearSearchQuery,
  });

  final bool controlsExpanded;
  final VoidCallback onToggleControls;
  final VoidCallback onOpenViewSettings;
  final VoidCallback onOpenDashboard;
  final DateTimeRange dateRange;
  final gantt.ViewMode viewMode;
  final List<ProjectPortfolioItem> projects;
  final String? selectedProjectId;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GanttTaskStatusFilter statusFilter;
  final GanttTimelineViewPreset timelineView;
  final List<gantt.GanttTask> tasks;
  final List<gantt.GanttTask> rangeTasks;
  final List<gantt.GanttTask> dependencyTasks;
  final String query;
  final ProjectPortfolioItem? selectedProject;
  final String? branchFocusTitle;
  final GanttBranchFocusSummary? branchFocusSummary;
  final bool canUndoLastEdit;
  final VoidCallback onUndoLastEdit;
  final VoidCallback onClearFilters;
  final VoidCallback? onClearProjectFilter;
  final VoidCallback? onClearBranchFocus;
  final VoidCallback? onClearTimelineView;
  final VoidCallback? onClearRangePreset;
  final VoidCallback? onClearStatusFilter;
  final VoidCallback? onClearSearchQuery;
}

/// Timeline chart inputs and commands for the full-screen Gantt workspace.
class GanttChartWorkspaceTimelineConfig {
  const GanttChartWorkspaceTimelineConfig({
    required this.tasks,
    required this.dateRange,
    required this.viewMode,
    required this.selectedTaskId,
    required this.onTaskSelected,
    required this.collapsedTaskIds,
    required this.onTaskCollapseToggled,
    required this.projectNamesById,
    required this.displayPreferences,
    required this.interactionPreferences,
    required this.emptyState,
    required this.onClearFilters,
    this.taskAvatarBuilder,
    this.taskDateRangeValidator,
    this.onTaskDateRangeChanged,
    this.onTaskDateRangeChangeRejected,
  });

  final List<gantt.GanttTask> tasks;
  final DateTimeRange dateRange;
  final gantt.ViewMode viewMode;
  final String? selectedTaskId;
  final ValueChanged<String> onTaskSelected;
  final Set<String> collapsedTaskIds;
  final ValueChanged<String>? onTaskCollapseToggled;
  final Map<String, String> projectNamesById;
  final GanttChartDisplayPreferences displayPreferences;
  final GanttChartInteractionPreferences interactionPreferences;
  final GanttChartEmptyStateSummary emptyState;
  final VoidCallback onClearFilters;
  final ky.KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final ky.KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final ky.KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final ky.KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
}
