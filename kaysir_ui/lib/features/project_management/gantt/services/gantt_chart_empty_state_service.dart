import 'gantt_saved_view_service.dart';
import '../states/gantt_filter_provider.dart';

class GanttChartEmptyStateSummary {
  const GanttChartEmptyStateSummary({
    required this.title,
    required this.message,
    required this.isRecoverable,
    this.actionLabel,
  });

  final String title;
  final String message;
  final bool isRecoverable;
  final String? actionLabel;
}

class GanttChartEmptyStateService {
  const GanttChartEmptyStateService();

  GanttChartEmptyStateSummary summaryFor({
    required bool hasSourceTasks,
    required bool hasVisibleTasks,
    required String searchQuery,
    required String? selectedProjectId,
    required String? branchFocusTaskId,
    required GanttTaskStatusFilter statusFilter,
    required GanttTimelineViewPreset timelineView,
  }) {
    final recoverable =
        hasSourceTasks &&
        !hasVisibleTasks &&
        hasActiveTimelineFilters(
          searchQuery: searchQuery,
          selectedProjectId: selectedProjectId,
          branchFocusTaskId: branchFocusTaskId,
          statusFilter: statusFilter,
          timelineView: timelineView,
        );

    if (recoverable) {
      return const GanttChartEmptyStateSummary(
        title: 'No matching timeline tasks',
        message:
            'Clear the current filters to bring the schedule back into view.',
        isRecoverable: true,
        actionLabel: 'Clear Timeline Filters',
      );
    }

    return const GanttChartEmptyStateSummary(
      title: 'No gantt tasks',
      message: 'Try a different project, status, or saved timeline view.',
      isRecoverable: false,
    );
  }

  bool hasActiveTimelineFilters({
    required String searchQuery,
    required String? selectedProjectId,
    required String? branchFocusTaskId,
    required GanttTaskStatusFilter statusFilter,
    required GanttTimelineViewPreset timelineView,
  }) {
    return searchQuery.trim().isNotEmpty ||
        selectedProjectId != null ||
        branchFocusTaskId != null ||
        statusFilter != GanttTaskStatusFilter.all ||
        timelineView != GanttTimelineViewPreset.all;
  }
}
