import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_chart_empty_state_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_display_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_workspace_config.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_chart_workspace_view.dart';

void main() {
  testWidgets(
    'gantt chart workspace view forwards recoverable empty state action',
    (tester) async {
      final fixture = _WorkspaceViewFixture(query: 'release');
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        fixture.build(
          emptyState: const GanttChartEmptyStateSummary(
            title: 'No matching timeline tasks',
            message:
                'Clear the current filters to bring the schedule back into view.',
            isRecoverable: true,
            actionLabel: 'Clear Timeline Filters',
          ),
        ),
      );

      expect(find.text('Full Gantt Chart'), findsWidgets);
      expect(find.text('No matching timeline tasks'), findsOneWidget);

      await tester.tap(
        find.byKey(GanttChartWorkspaceView.emptyClearFiltersButtonKey),
      );
      await tester.pump();

      expect(fixture.clearCount, 1);
    },
  );

  testWidgets(
    'gantt chart workspace view hides empty action when recovery is unavailable',
    (tester) async {
      final fixture = _WorkspaceViewFixture();
      addTearDown(fixture.dispose);

      await tester.pumpWidget(
        fixture.build(
          emptyState: const GanttChartEmptyStateSummary(
            title: 'No gantt tasks',
            message: 'Try a different project, status, or saved timeline view.',
            isRecoverable: false,
          ),
        ),
      );

      expect(find.text('No gantt tasks'), findsOneWidget);
      expect(
        find.byKey(GanttChartWorkspaceView.emptyClearFiltersButtonKey),
        findsNothing,
      );
      expect(fixture.clearCount, 0);
    },
  );
}

class _WorkspaceViewFixture {
  _WorkspaceViewFixture({String query = ''})
    : searchController = TextEditingController(text: query),
      searchFocusNode = FocusNode(debugLabel: 'Gantt workspace test search'),
      query = query;

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String query;
  var clearCount = 0;

  DateTimeRange get range {
    return DateTimeRange(start: DateTime(2026, 1), end: DateTime(2026, 1, 31));
  }

  Widget build({required GanttChartEmptyStateSummary emptyState}) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: GanttChartWorkspaceView(
            header: headerConfig(),
            timeline: timelineConfig(emptyState: emptyState),
          ),
        ),
      ),
    );
  }

  GanttChartWorkspaceHeaderConfig headerConfig() {
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
      query: query,
      selectedProject: null,
      canUndoLastEdit: false,
      onUndoLastEdit: () {},
      onClearFilters: () => clearCount++,
    );
  }

  GanttChartWorkspaceTimelineConfig timelineConfig({
    required GanttChartEmptyStateSummary emptyState,
  }) {
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
      emptyState: emptyState,
      onClearFilters: () => clearCount++,
    );
  }

  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
  }
}
