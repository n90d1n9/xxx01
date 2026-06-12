import 'package:flutter/foundation.dart';

import '../../project/models/project_portfolio_item.dart';
import '../gantt_dashboard.dart' as gantt;
import '../states/gantt_filter_provider.dart';
import 'gantt_chart_empty_state_service.dart';
import 'gantt_saved_view_service.dart';
import 'gantt_selection_context_service.dart';
import 'gantt_task_navigation_service.dart';

/// Derived presentation state for the full-screen Gantt chart.
@immutable
class GanttChartScreenPresentationModel {
  const GanttChartScreenPresentationModel({
    required this.taskNavigation,
    required this.selectionContext,
    required this.hiddenSelectedTask,
    required this.emptyState,
  });

  final GanttTaskNavigationContext taskNavigation;
  final GanttSelectionContext selectionContext;
  final gantt.GanttTask? hiddenSelectedTask;
  final GanttChartEmptyStateSummary emptyState;
}

/// Builds screen-level Gantt presentation state from provider snapshots.
class GanttChartScreenPresentationService {
  const GanttChartScreenPresentationService({
    this.taskNavigationService = const GanttTaskNavigationService(),
    this.selectionContextService = const GanttSelectionContextService(),
    this.emptyStateService = const GanttChartEmptyStateService(),
  });

  final GanttTaskNavigationService taskNavigationService;
  final GanttSelectionContextService selectionContextService;
  final GanttChartEmptyStateService emptyStateService;

  GanttChartScreenPresentationModel modelFor({
    required List<gantt.GanttTask> allTasks,
    required List<gantt.GanttTask> visibleTasks,
    required gantt.GanttTask? selectedTask,
    required String? selectedTaskId,
    required String? selectedProjectId,
    required String? branchFocusTaskId,
    required Map<String, String> taskTitlesById,
    required List<ProjectPortfolioItem> projects,
    required String searchQuery,
    required GanttTaskStatusFilter statusFilter,
    required GanttTimelineViewPreset timelineView,
  }) {
    final taskNavigation = taskNavigationService.contextFor(
      selectedTask: selectedTask,
      visibleTasks: visibleTasks,
      taskTitlesById: taskTitlesById,
    );
    final selectionContext = selectionContextService.contextFor(
      allTasks: allTasks,
      selectedVisibleTask: selectedTask,
      selectedTaskId: selectedTaskId,
      selectedProjectId: selectedProjectId,
      branchFocusTaskId: branchFocusTaskId,
      taskTitlesById: taskTitlesById,
      projects: projects,
    );
    final emptyState = emptyStateService.summaryFor(
      hasSourceTasks: allTasks.isNotEmpty,
      hasVisibleTasks: visibleTasks.isNotEmpty,
      searchQuery: searchQuery,
      selectedProjectId: selectedProjectId,
      branchFocusTaskId: branchFocusTaskId,
      statusFilter: statusFilter,
      timelineView: timelineView,
    );

    return GanttChartScreenPresentationModel(
      taskNavigation: taskNavigation,
      selectionContext: selectionContext,
      hiddenSelectedTask:
          selectionContext.selectedTaskHiddenByFilters
              ? selectionContext.selectedTaskInTimeline
              : null,
      emptyState: emptyState,
    );
  }
}
