import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_empty_state_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_selection_context_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_screen_workspace.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt chart screen workspace forwards empty recovery action', (
    tester,
  ) async {
    final fixture = _ScreenWorkspaceFixture(query: 'release');
    addTearDown(fixture.dispose);

    await tester.pumpWidget(fixture.build());

    expect(find.text('Full Gantt Chart'), findsWidgets);
    expect(find.text('No matching timeline tasks'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttChartScreenWorkspace.emptyClearFiltersButtonKey),
    );
    await tester.pump();

    expect(fixture.clearCount, 1);
  });

  testWidgets('gantt chart screen workspace forwards task selection', (
    tester,
  ) async {
    final fixture = _ScreenWorkspaceFixture(tasks: [_task]);
    addTearDown(fixture.dispose);

    await tester.pumpWidget(fixture.build());

    final taskRow = find.widgetWithText(KyGanttTaskListRow, 'Planning');
    await tester.ensureVisible(taskRow);
    await tester.tap(taskRow);
    await tester.pump();

    expect(fixture.selectedTaskId, 'planning');
  });
}

class _ScreenWorkspaceFixture {
  _ScreenWorkspaceFixture({this.query = '', this.tasks = const []})
    : searchController = TextEditingController(text: query),
      searchFocusNode = FocusNode(debugLabel: 'Gantt screen workspace test');

  final String query;
  final List<gantt.GanttTask> tasks;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  var clearCount = 0;
  String? selectedTaskId;

  DateTimeRange get range {
    return DateTimeRange(start: DateTime(2026, 1), end: DateTime(2026, 1, 31));
  }

  Widget build() {
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
            allTasks: tasks,
            visibleTasks: tasks,
            searchQuery: query,
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
            emptyState:
                tasks.isEmpty
                    ? const GanttChartEmptyStateSummary(
                      title: 'No matching timeline tasks',
                      message:
                          'Clear the current filters to bring the schedule back.',
                      isRecoverable: true,
                      actionLabel: 'Clear Timeline Filters',
                    )
                    : const GanttChartEmptyStateSummary(
                      title: 'No gantt tasks',
                      message: 'Try a different timeline view.',
                      isRecoverable: false,
                    ),
            canUndoLastEdit: false,
            actions: GanttChartScreenWorkspaceActions(
              onToggleControls: () {},
              onOpenViewSettings: () {},
              onOpenDashboard: () {},
              onUndoLastEdit: () {},
              onClearFilters: () => clearCount++,
              onTaskSelected: (taskId) => selectedTaskId = taskId,
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }
}

final _task = gantt.GanttTask(
  id: 'planning',
  title: 'Planning',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 12),
  progress: 0.4,
);
