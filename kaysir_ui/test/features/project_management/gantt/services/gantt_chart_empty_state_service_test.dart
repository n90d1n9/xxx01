import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_empty_state_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';

void main() {
  group('GanttChartEmptyStateService', () {
    const service = GanttChartEmptyStateService();

    test('builds a recoverable empty state for filtered timelines', () {
      final summary = service.summaryFor(
        hasSourceTasks: true,
        hasVisibleTasks: false,
        searchQuery: 'release',
        selectedProjectId: null,
        branchFocusTaskId: null,
        statusFilter: GanttTaskStatusFilter.all,
        timelineView: GanttTimelineViewPreset.all,
      );

      expect(summary.isRecoverable, isTrue);
      expect(summary.title, 'No matching timeline tasks');
      expect(
        summary.message,
        'Clear the current filters to bring the schedule back into view.',
      );
      expect(summary.actionLabel, 'Clear Timeline Filters');
    });

    test('builds the base empty state when no source tasks exist', () {
      final summary = service.summaryFor(
        hasSourceTasks: false,
        hasVisibleTasks: false,
        searchQuery: 'release',
        selectedProjectId: 'project-a',
        branchFocusTaskId: 'task-a',
        statusFilter: GanttTaskStatusFilter.inProgress,
        timelineView: GanttTimelineViewPreset.dependencyWatch,
      );

      expect(summary.isRecoverable, isFalse);
      expect(summary.title, 'No gantt tasks');
      expect(
        summary.message,
        'Try a different project, status, or saved timeline view.',
      );
      expect(summary.actionLabel, isNull);
    });

    test('does not offer recovery while tasks remain visible', () {
      final summary = service.summaryFor(
        hasSourceTasks: true,
        hasVisibleTasks: true,
        searchQuery: 'release',
        selectedProjectId: null,
        branchFocusTaskId: null,
        statusFilter: GanttTaskStatusFilter.all,
        timelineView: GanttTimelineViewPreset.all,
      );

      expect(summary.isRecoverable, isFalse);
      expect(summary.title, 'No gantt tasks');
    });

    test('detects active timeline filters consistently', () {
      expect(
        service.hasActiveTimelineFilters(
          searchQuery: '  ',
          selectedProjectId: null,
          branchFocusTaskId: null,
          statusFilter: GanttTaskStatusFilter.all,
          timelineView: GanttTimelineViewPreset.all,
        ),
        isFalse,
      );
      expect(
        service.hasActiveTimelineFilters(
          searchQuery: '',
          selectedProjectId: 'project-a',
          branchFocusTaskId: null,
          statusFilter: GanttTaskStatusFilter.all,
          timelineView: GanttTimelineViewPreset.all,
        ),
        isTrue,
      );
      expect(
        service.hasActiveTimelineFilters(
          searchQuery: '',
          selectedProjectId: null,
          branchFocusTaskId: 'task-a',
          statusFilter: GanttTaskStatusFilter.all,
          timelineView: GanttTimelineViewPreset.all,
        ),
        isTrue,
      );
      expect(
        service.hasActiveTimelineFilters(
          searchQuery: '',
          selectedProjectId: null,
          branchFocusTaskId: null,
          statusFilter: GanttTaskStatusFilter.inProgress,
          timelineView: GanttTimelineViewPreset.all,
        ),
        isTrue,
      );
      expect(
        service.hasActiveTimelineFilters(
          searchQuery: '',
          selectedProjectId: null,
          branchFocusTaskId: null,
          statusFilter: GanttTaskStatusFilter.all,
          timelineView: GanttTimelineViewPreset.readyNext,
        ),
        isTrue,
      );
    });
  });
}
