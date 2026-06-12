import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_chart_empty_state_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../services/gantt_selection_context_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import '../states/gantt_filter_provider.dart';
import 'gantt_chart_workspace_config.dart';
import 'gantt_chart_workspace_view.dart';

/// Screen-level commands used by the full-screen Gantt workspace adapter.
class GanttChartScreenWorkspaceActions {
  const GanttChartScreenWorkspaceActions({
    required this.onToggleControls,
    required this.onOpenViewSettings,
    required this.onOpenDashboard,
    required this.onUndoLastEdit,
    required this.onClearFilters,
    required this.onTaskSelected,
    this.onClearProjectFilter,
    this.onClearBranchFocus,
    this.onClearTimelineView,
    this.onClearRangePreset,
    this.onClearStatusFilter,
    this.onClearSearchQuery,
    this.onTaskCollapseToggled,
  });

  final VoidCallback onToggleControls;
  final VoidCallback onOpenViewSettings;
  final VoidCallback onOpenDashboard;
  final VoidCallback onUndoLastEdit;
  final VoidCallback onClearFilters;
  final ValueChanged<String> onTaskSelected;
  final VoidCallback? onClearProjectFilter;
  final VoidCallback? onClearBranchFocus;
  final VoidCallback? onClearTimelineView;
  final VoidCallback? onClearRangePreset;
  final VoidCallback? onClearStatusFilter;
  final VoidCallback? onClearSearchQuery;
  final ValueChanged<String>? onTaskCollapseToggled;
}

/// Adapts full-screen Gantt route state into reusable workspace configs.
class GanttChartScreenWorkspace extends StatelessWidget {
  const GanttChartScreenWorkspace({
    required this.controlsExpanded,
    required this.dateRange,
    required this.viewMode,
    required this.projects,
    required this.selectedProjectId,
    required this.searchController,
    required this.searchFocusNode,
    required this.statusFilter,
    required this.timelineView,
    required this.allTasks,
    required this.visibleTasks,
    required this.searchQuery,
    required this.selectedTaskId,
    required this.collapsedTaskIds,
    required this.selectionContext,
    required this.displayPreferences,
    required this.interactionPreferences,
    required this.emptyState,
    required this.canUndoLastEdit,
    required this.actions,
    this.taskAvatarBuilder,
    this.taskDateRangeValidator,
    this.onTaskDateRangeChanged,
    this.onTaskDateRangeChangeRejected,
    super.key,
  });

  static const emptyClearFiltersButtonKey =
      GanttChartWorkspaceView.emptyClearFiltersButtonKey;

  final bool controlsExpanded;
  final DateTimeRange dateRange;
  final gantt.ViewMode viewMode;
  final List<ProjectPortfolioItem> projects;
  final String? selectedProjectId;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final GanttTaskStatusFilter statusFilter;
  final GanttTimelineViewPreset timelineView;
  final List<gantt.GanttTask> allTasks;
  final List<gantt.GanttTask> visibleTasks;
  final String searchQuery;
  final String? selectedTaskId;
  final Set<String> collapsedTaskIds;
  final GanttSelectionContext selectionContext;
  final GanttChartDisplayPreferences displayPreferences;
  final GanttChartInteractionPreferences interactionPreferences;
  final GanttChartEmptyStateSummary emptyState;
  final bool canUndoLastEdit;
  final GanttChartScreenWorkspaceActions actions;
  final ky.KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final ky.KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final ky.KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final ky.KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;

  @override
  Widget build(BuildContext context) {
    return GanttChartWorkspaceView(
      header: GanttChartWorkspaceHeaderConfig(
        controlsExpanded: controlsExpanded,
        onToggleControls: actions.onToggleControls,
        onOpenViewSettings: actions.onOpenViewSettings,
        onOpenDashboard: actions.onOpenDashboard,
        dateRange: dateRange,
        viewMode: viewMode,
        projects: projects,
        selectedProjectId: selectedProjectId,
        searchController: searchController,
        searchFocusNode: searchFocusNode,
        statusFilter: statusFilter,
        timelineView: timelineView,
        tasks: allTasks,
        rangeTasks: visibleTasks,
        dependencyTasks: allTasks,
        query: searchQuery,
        selectedProject: selectionContext.selectedProject,
        branchFocusTitle: selectionContext.branchFocusTitle,
        branchFocusSummary: selectionContext.branchFocusSummary,
        canUndoLastEdit: canUndoLastEdit,
        onUndoLastEdit: actions.onUndoLastEdit,
        onClearProjectFilter: actions.onClearProjectFilter,
        onClearBranchFocus: actions.onClearBranchFocus,
        onClearTimelineView: actions.onClearTimelineView,
        onClearRangePreset: actions.onClearRangePreset,
        onClearStatusFilter: actions.onClearStatusFilter,
        onClearSearchQuery: actions.onClearSearchQuery,
        onClearFilters: actions.onClearFilters,
      ),
      timeline: GanttChartWorkspaceTimelineConfig(
        tasks: visibleTasks,
        dateRange: dateRange,
        viewMode: viewMode,
        selectedTaskId: selectedTaskId,
        onTaskSelected: actions.onTaskSelected,
        collapsedTaskIds: collapsedTaskIds,
        onTaskCollapseToggled: actions.onTaskCollapseToggled,
        projectNamesById: selectionContext.projectNamesById,
        displayPreferences: displayPreferences,
        interactionPreferences: interactionPreferences,
        emptyState: emptyState,
        onClearFilters: actions.onClearFilters,
        taskAvatarBuilder: taskAvatarBuilder,
        taskDateRangeValidator: taskDateRangeValidator,
        onTaskDateRangeChanged: onTaskDateRangeChanged,
        onTaskDateRangeChangeRejected: onTaskDateRangeChangeRejected,
      ),
    );
  }
}

@Preview(name: 'Gantt chart screen workspace')
Widget ganttChartScreenWorkspacePreview() {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode(debugLabel: 'Gantt screen workspace');
  final range = DateTimeRange(
    start: DateTime(2026, 1),
    end: DateTime(2026, 1, 31),
  );

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: GanttChartScreenWorkspace(
          controlsExpanded: false,
          dateRange: range,
          viewMode: gantt.ViewMode.week,
          projects: const [],
          selectedProjectId: null,
          searchController: searchController,
          searchFocusNode: searchFocusNode,
          statusFilter: GanttTaskStatusFilter.all,
          timelineView: GanttTimelineViewPreset.all,
          allTasks: const [],
          visibleTasks: const [],
          searchQuery: '',
          selectedTaskId: null,
          collapsedTaskIds: const {},
          selectionContext: const GanttSelectionContext(
            selectedProject: null,
            projectsById: {},
            projectNamesById: {},
            selectedTaskInTimeline: null,
            selectedTaskHiddenByFilters: false,
            selectedTaskProjectId: null,
            selectedTaskProjectName: null,
            selectedTaskDependencyTitle: null,
            hiddenTaskProjectName: null,
            hiddenTaskDependencyTitle: null,
            branchFocusTitle: null,
            branchFocusSummary: null,
          ),
          displayPreferences: GanttChartDisplayPreferences.initial,
          interactionPreferences: GanttChartInteractionPreferences.initial,
          emptyState: const GanttChartEmptyStateSummary(
            title: 'No matching timeline tasks',
            message: 'Clear the current filters to bring the schedule back.',
            isRecoverable: true,
            actionLabel: 'Clear Timeline Filters',
          ),
          canUndoLastEdit: false,
          actions: GanttChartScreenWorkspaceActions(
            onToggleControls: _previewNoop,
            onOpenViewSettings: _previewNoop,
            onOpenDashboard: _previewNoop,
            onUndoLastEdit: _previewNoop,
            onClearFilters: _previewNoop,
            onTaskSelected: _previewSelectTask,
          ),
        ),
      ),
    ),
  );
}

void _previewNoop() {}

void _previewSelectTask(String taskId) {}
