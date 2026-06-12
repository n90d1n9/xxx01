import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_chart_empty_state_service.dart';
import '../services/gantt_saved_view_service.dart';
import '../states/gantt_chart_display_provider.dart';
import '../states/gantt_chart_interaction_provider.dart';
import '../states/gantt_filter_provider.dart';
import 'gantt_chart_control_header.dart';
import 'gantt_chart_workspace_config.dart';
import 'gantt_task_drag_preview_card.dart';
import 'project_gantt_chart_panel.dart';

/// Full-screen Gantt workspace body containing controls and the timeline chart.
class GanttChartWorkspaceView extends StatelessWidget {
  const GanttChartWorkspaceView({
    required this.header,
    required this.timeline,
    super.key,
  });

  static const emptyClearFiltersButtonKey = ValueKey(
    'gantt-chart-empty-clear-filters-button',
  );

  final GanttChartWorkspaceHeaderConfig header;
  final GanttChartWorkspaceTimelineConfig timeline;

  @override
  Widget build(BuildContext context) {
    final interactionPreferences = timeline.interactionPreferences;
    final displayPreferences = timeline.displayPreferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GanttChartControlHeader(
          controlsExpanded: header.controlsExpanded,
          onToggleControls: header.onToggleControls,
          onOpenViewSettings: header.onOpenViewSettings,
          onOpenDashboard: header.onOpenDashboard,
          dateRange: header.dateRange,
          viewMode: header.viewMode,
          projects: header.projects,
          selectedProjectId: header.selectedProjectId,
          searchController: header.searchController,
          searchFocusNode: header.searchFocusNode,
          statusFilter: header.statusFilter,
          timelineView: header.timelineView,
          tasks: header.tasks,
          rangeTasks: header.rangeTasks,
          dependencyTasks: header.dependencyTasks,
          query: header.query,
          selectedProject: header.selectedProject,
          branchFocusTitle: header.branchFocusTitle,
          branchFocusSummary: header.branchFocusSummary,
          canUndoLastEdit: header.canUndoLastEdit,
          onUndoLastEdit: header.onUndoLastEdit,
          onClearProjectFilter: header.onClearProjectFilter,
          onClearBranchFocus: header.onClearBranchFocus,
          onClearTimelineView: header.onClearTimelineView,
          onClearRangePreset: header.onClearRangePreset,
          onClearStatusFilter: header.onClearStatusFilter,
          onClearSearchQuery: header.onClearSearchQuery,
          onClearFilters: header.onClearFilters,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ProjectGanttChartPanel(
              tasks: timeline.tasks,
              dateRange: timeline.dateRange,
              viewMode: timeline.viewMode,
              selectedTaskId: timeline.selectedTaskId,
              onTaskSelected: timeline.onTaskSelected,
              collapsedTaskIds: timeline.collapsedTaskIds,
              onTaskCollapseToggled: timeline.onTaskCollapseToggled,
              projectNamesById: timeline.projectNamesById,
              displayOptions: displayPreferences.kyOptions,
              interactionOptions: interactionPreferences.kyOptions,
              rowHeight: displayPreferences.density.rowHeight,
              headerHeight: displayPreferences.density.headerHeight,
              timelineScale: displayPreferences.timelineZoom.scale,
              emptyStateTitle: timeline.emptyState.title,
              emptyStateMessage: timeline.emptyState.message,
              emptyStateAction:
                  timeline.emptyState.isRecoverable
                      ? FilledButton.icon(
                        key: emptyClearFiltersButtonKey,
                        onPressed: timeline.onClearFilters,
                        icon: const Icon(Icons.filter_alt_off_rounded),
                        label: Text(timeline.emptyState.actionLabel!),
                      )
                      : null,
              taskAvatarBuilder: timeline.taskAvatarBuilder,
              taskDragPreviewBuilder:
                  (context, preview) => GanttTaskDragPreviewCard(
                    preview: preview,
                    showImpactSummary:
                        interactionPreferences.showDragImpactSummary,
                    showMetadataPills:
                        interactionPreferences
                            .dragPreviewDetail
                            .showMetadataPills,
                    showGhostBar:
                        interactionPreferences.dragPreviewDetail.showGhostBar,
                    showDeltaStrip:
                        interactionPreferences.dragPreviewDetail.showDeltaStrip,
                  ),
              taskDateRangeValidator: timeline.taskDateRangeValidator,
              onTaskDateRangeChanged: timeline.onTaskDateRangeChanged,
              onTaskDateRangeChangeRejected:
                  timeline.onTaskDateRangeChangeRejected,
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Gantt chart workspace view')
Widget ganttChartWorkspaceViewPreview() {
  final searchController = TextEditingController();
  final searchFocusNode = FocusNode(debugLabel: 'Gantt preview search');
  final range = _previewRange();

  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: GanttChartWorkspaceView(
          header: _previewHeaderConfig(
            range: range,
            searchController: searchController,
            searchFocusNode: searchFocusNode,
          ),
          timeline: _previewTimelineConfig(range),
        ),
      ),
    ),
  );
}

DateTimeRange _previewRange() {
  return DateTimeRange(start: DateTime(2026, 1), end: DateTime(2026, 1, 31));
}

GanttChartWorkspaceHeaderConfig _previewHeaderConfig({
  required DateTimeRange range,
  required TextEditingController searchController,
  required FocusNode searchFocusNode,
}) {
  return GanttChartWorkspaceHeaderConfig(
    controlsExpanded: false,
    onToggleControls: () {},
    onOpenViewSettings: () {},
    onOpenDashboard: () {},
    dateRange: range,
    viewMode: gantt.ViewMode.week,
    projects: const [],
    selectedProjectId: null,
    searchController: searchController,
    searchFocusNode: searchFocusNode,
    statusFilter: GanttTaskStatusFilter.all,
    timelineView: GanttTimelineViewPreset.all,
    tasks: const [],
    rangeTasks: const [],
    dependencyTasks: const [],
    query: '',
    selectedProject: null,
    canUndoLastEdit: false,
    onUndoLastEdit: () {},
    onClearFilters: () {},
  );
}

GanttChartWorkspaceTimelineConfig _previewTimelineConfig(DateTimeRange range) {
  return GanttChartWorkspaceTimelineConfig(
    tasks: const [],
    dateRange: range,
    viewMode: gantt.ViewMode.week,
    selectedTaskId: null,
    onTaskSelected: (_) {},
    collapsedTaskIds: const {},
    onTaskCollapseToggled: null,
    projectNamesById: const {},
    displayPreferences: GanttChartDisplayPreferences.initial,
    interactionPreferences: GanttChartInteractionPreferences.initial,
    emptyState: const GanttChartEmptyStateSummary(
      title: 'No matching timeline tasks',
      message: 'Clear the current filters to bring the schedule back.',
      isRecoverable: true,
      actionLabel: 'Clear Timeline Filters',
    ),
    onClearFilters: () {},
  );
}
