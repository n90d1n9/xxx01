import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../../project/states/project_portfolio_provider.dart';
import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_chart_control_intent_service.dart';
import '../services/gantt_chart_route_focus_intent_service.dart';
import '../services/gantt_chart_screen_presentation_service.dart';
import '../services/gantt_chart_task_focus_intent_service.dart';
import '../services/gantt_chart_timeline_focus_intent_service.dart';
import '../services/gantt_task_avatar_service.dart';
import '../services/gantt_task_date_range_edit_service.dart';
import '../services/gantt_task_date_range_validation_service.dart';
import '../services/gantt_task_edit_availability_service.dart';
import '../services/gantt_task_inspector_action_service.dart';
import '../services/gantt_task_navigation_service.dart';
import '../services/gantt_timeline_range_preset_service.dart';
import '../states/gantt_filter_provider.dart';
import '../states/gantt_chart_preferences_provider.dart';
import '../states/gantt_timeline_range_preset_provider.dart';
import '../widgets/gantt_chart_screen_actions.dart';
import '../widgets/gantt_chart_screen_shell.dart';
import '../widgets/gantt_chart_screen_task_overlay_layer.dart';
import '../widgets/gantt_chart_screen_workspace.dart';
import '../widgets/gantt_chart_view_settings_dialog.dart';
import '../widgets/gantt_task_inspector_actions.dart';
import '../widgets/gantt_task_schedule_feedback_snack_bar_factory.dart';

/// Full-screen interactive Gantt chart workspace for project schedules.
class GanttChartScreen extends ConsumerStatefulWidget {
  const GanttChartScreen({
    this.initialProjectId,
    this.initialTaskId,
    super.key,
  });

  static const emptyClearFiltersButtonKey =
      GanttChartScreenWorkspace.emptyClearFiltersButtonKey;

  final String? initialProjectId;
  final String? initialTaskId;

  @override
  ConsumerState<GanttChartScreen> createState() => _GanttChartScreenState();
}

/// Coordinates full-screen Gantt state, filters, selection, and edit feedback.
class _GanttChartScreenState extends ConsumerState<GanttChartScreen> {
  static const _taskAvatarService = GanttTaskAvatarService();
  static const _dateRangeValidationService =
      GanttTaskDateRangeValidationService();
  static const _presentationService = GanttChartScreenPresentationService();
  static const _controlIntentService = GanttChartControlIntentService();
  static const _controlIntentDispatcher = GanttChartControlIntentDispatcher();
  static const _dateRangeEditService = GanttTaskDateRangeEditService();
  static const _taskEditAvailabilityService =
      GanttTaskEditAvailabilityService();
  static const _inspectorActionService = GanttTaskInspectorActionService();
  static const _timelineFocusIntentService =
      GanttChartTimelineFocusIntentService();
  static const _timelineFocusIntentDispatcher =
      GanttChartTimelineFocusIntentDispatcher();
  static const _taskFocusIntentService = GanttChartTaskFocusIntentService();
  static const _taskFocusIntentDispatcher =
      GanttChartTaskFocusIntentDispatcher();
  static const _taskSelectionIntentDispatcher =
      GanttChartTaskSelectionIntentDispatcher();
  static const _taskNavigationActionService =
      GanttTaskNavigationActionService();
  static const _routeFocusIntentService = GanttChartRouteFocusIntentService();
  static const _routeFocusIntentDispatcher =
      GanttChartRouteFocusIntentDispatcher();
  static const _scheduleFeedbackSnackBarFactory =
      GanttTaskScheduleFeedbackSnackBarFactory();

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(ganttChartWorkspacePreferencesHydrationProvider.future));
    _searchController = TextEditingController(
      text: ref.read(gantt.searchQueryProvider),
    );
    _searchFocusNode = FocusNode(debugLabel: 'Gantt timeline search');
    _applyInitialRouteFocus();
  }

  @override
  void didUpdateWidget(covariant GanttChartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProjectId != widget.initialProjectId ||
        oldWidget.initialTaskId != widget.initialTaskId) {
      _applyInitialRouteFocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(gantt.tasksProvider);
    final tasks = ref.watch(operationalGanttTasksProvider);
    final dateRange = ref.watch(gantt.dateRangeProvider);
    final selectedTaskId = ref.watch(gantt.selectedTaskProvider);
    final viewMode = ref.watch(gantt.viewModeProvider);
    final projects = ref.watch(projectPortfolioProvider);
    final selectedProjectId = ref.watch(ganttProjectFilterProvider);
    final statusFilter = ref.watch(ganttTaskStatusFilterProvider);
    final searchQuery = ref.watch(gantt.searchQueryProvider);
    final timelineView = ref.watch(ganttTimelineViewProvider);
    final branchFocusTaskId = ref.watch(ganttBranchFocusTaskIdProvider);
    final collapsedTaskIds = ref.watch(ganttCollapsedTaskIdsProvider);
    final controlsExpanded = ref.watch(ganttChartControlsExpandedProvider);
    final displayPreferences = ref.watch(ganttChartDisplayPreferencesProvider);
    final interactionPreferences = ref.watch(
      ganttChartInteractionPreferencesProvider,
    );
    ref.listen<GanttTimelineRangePreset>(ganttTimelineRangePresetProvider, (
      previous,
      next,
    ) {
      if (previous == next) return;
      _applyTimelineRangePreset(next, ref.read(operationalGanttTasksProvider));
    });
    final selectedTask = ref.watch(selectedOperationalGanttTaskProvider);
    final taskTitlesById = ref.watch(ganttTaskTitlesByIdProvider);
    final presentation = _presentationService.modelFor(
      allTasks: allTasks,
      visibleTasks: tasks,
      selectedTask: selectedTask,
      selectedTaskId: selectedTaskId,
      selectedProjectId: selectedProjectId,
      branchFocusTaskId: branchFocusTaskId,
      taskTitlesById: taskTitlesById,
      projects: projects,
      searchQuery: searchQuery,
      statusFilter: statusFilter,
      timelineView: timelineView,
    );
    final taskNavigation = presentation.taskNavigation;
    final taskNavigationActions = _taskNavigationActionService.actionsFor(
      context: taskNavigation,
      onOpenTask: _openTaskInspector,
    );
    final selectionContext = presentation.selectionContext;
    final selectedTaskProjectId = selectionContext.selectedTaskProjectId;
    final hiddenSelectedTask = presentation.hiddenSelectedTask;
    final recentTaskEdits = ref.watch(gantt.recentTaskEditsProvider);
    final editAvailability = _taskEditAvailabilityService.availabilityFor(
      tasksNotifier: ref.read(gantt.tasksProvider.notifier),
      selectedTask: selectedTask,
    );
    final emptyState = presentation.emptyState;

    return GanttChartScreenShell(
      actions: GanttChartScreenActions(
        onDismiss: _clearSelectedTask,
        onSearch: _focusTimelineSearch,
        onToggleControls: _toggleControls,
        onOpenSettings: _openViewSettings,
        onUndo: editAvailability.canUndoLastTaskEdit ? _undoLastTaskEdit : null,
        onPreviousTask: taskNavigationActions.onPreviousTask,
        onNextTask: taskNavigationActions.onNextTask,
        onClearFilters: _clearTimelineFilters,
      ),
      workspace: GanttChartScreenWorkspace(
        controlsExpanded: controlsExpanded,
        dateRange: dateRange,
        viewMode: viewMode,
        projects: projects,
        selectedProjectId: selectedProjectId,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        statusFilter: statusFilter,
        timelineView: timelineView,
        allTasks: allTasks,
        visibleTasks: tasks,
        searchQuery: searchQuery,
        selectedTaskId: selectedTaskId,
        collapsedTaskIds: collapsedTaskIds,
        selectionContext: selectionContext,
        displayPreferences: displayPreferences,
        interactionPreferences: interactionPreferences,
        emptyState: emptyState,
        canUndoLastEdit: editAvailability.canUndoLastTaskEdit,
        actions: GanttChartScreenWorkspaceActions(
          onToggleControls: _toggleControls,
          onOpenViewSettings: _openViewSettings,
          onOpenDashboard: () => context.go('/gantt'),
          onUndoLastEdit: _undoLastTaskEdit,
          onClearProjectFilter: _clearProjectFilter,
          onClearBranchFocus: _clearBranchFocus,
          onClearTimelineView: _clearTimelineView,
          onClearRangePreset: _clearRangePreset,
          onClearStatusFilter: _clearStatusFilter,
          onClearSearchQuery: _clearSearchQuery,
          onClearFilters: _clearTimelineFilters,
          onTaskSelected: _openTaskInspector,
          onTaskCollapseToggled: _toggleCollapsedTask,
        ),
        taskAvatarBuilder:
            (task) => _taskAvatarService.avatarsForTask(
              task,
              selectionContext.projectsById,
            ),
        taskDateRangeValidator:
            interactionPreferences.enableScheduleGuard
                ? (task, startDate, endDate) =>
                    _dateRangeValidationService.validate(
                      task,
                      startDate: startDate,
                      endDate: endDate,
                      tasks: allTasks,
                    )
                : null,
        onTaskDateRangeChanged: _moveTaskDateRange,
        onTaskDateRangeChangeRejected: _showTaskScheduleGuardFeedback,
      ),
      foregroundLayers: [
        GanttChartScreenTaskOverlayLayer(
          hiddenSelectedTask: hiddenSelectedTask,
          selectedTask: selectedTask,
          selectionContext: selectionContext,
          taskNavigation: taskNavigation,
          dependencyTasks: allTasks,
          recentEdits: recentTaskEdits,
          placement: interactionPreferences.inspectorPlacement,
          actions: GanttChartScreenTaskOverlayActions(
            onRevealTask: _revealSelectedTask,
            onClearSelection: _clearSelectedTask,
            inspectorActions:
                selectedTask == null
                    ? null
                    : _inspectorActionsFor(
                      selectedTask: selectedTask,
                      canUndoSelectedTaskEdit:
                          editAvailability.canUndoSelectedTaskEdit,
                      selectedTaskProjectId: selectedTaskProjectId,
                      onPreviousTask: taskNavigationActions.onPreviousTask,
                      onNextTask: taskNavigationActions.onNextTask,
                    ),
          ),
        ),
      ],
    );
  }

  void _openTaskInspector(String taskId) {
    ref.read(gantt.selectedTaskProvider.notifier).state = taskId;
  }

  void _clearSelectedTask() {
    ref.read(gantt.selectedTaskProvider.notifier).state = null;
  }

  void _clearProjectFilter() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearProject(_timelineFocusSnapshot()),
    );
  }

  void _clearBranchFocus() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearBranch(_timelineFocusSnapshot()),
    );
  }

  void _clearTimelineView() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearView(_timelineFocusSnapshot()),
    );
  }

  void _clearRangePreset() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearRange(_timelineFocusSnapshot()),
    );
  }

  void _clearStatusFilter() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearStatus(_timelineFocusSnapshot()),
    );
  }

  void _clearSearchQuery() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearQuery(_timelineFocusSnapshot()),
    );
  }

  void _clearTimelineFilters() {
    _applyTimelineFocusIntent(
      _timelineFocusIntentService.clearAll(_timelineFocusSnapshot()),
    );
  }

  GanttChartTimelineFocusSnapshot _timelineFocusSnapshot() {
    return GanttChartTimelineFocusSnapshot(
      query: ref.read(gantt.searchQueryProvider),
      projectId: ref.read(ganttProjectFilterProvider),
      branchFocusTaskId: ref.read(ganttBranchFocusTaskIdProvider),
      viewPreset: ref.read(ganttTimelineViewProvider),
      rangePreset: ref.read(ganttTimelineRangePresetProvider),
      statusFilter: ref.read(ganttTaskStatusFilterProvider),
    );
  }

  void _applyTimelineFocusIntent(GanttChartTimelineFocusIntentResult result) {
    _timelineFocusIntentDispatcher.dispatch(
      intent: result,
      onClearSearchController: _searchController.clear,
      onApplyFocus: _applyTimelineFocusSnapshot,
      onApplyRangePreset:
          (preset) => _applyTimelineRangePreset(
            preset,
            ref.read(operationalGanttTasksProvider),
          ),
    );
  }

  void _applyTimelineFocusSnapshot(GanttChartTimelineFocusSnapshot focus) {
    ref.read(gantt.searchQueryProvider.notifier).state = focus.query;
    ref.read(ganttProjectFilterProvider.notifier).state = focus.projectId;
    ref.read(ganttBranchFocusTaskIdProvider.notifier).state =
        focus.branchFocusTaskId;
    ref.read(ganttTimelineViewProvider.notifier).state = focus.viewPreset;
    ref.read(ganttTaskStatusFilterProvider.notifier).state = focus.statusFilter;
    ref
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setTimelineRangePreset(focus.rangePreset);
  }

  void _toggleCollapsedTask(String taskId) {
    _taskFocusIntentDispatcher.dispatchCollapsedTaskIds(
      collapsedTaskIds: _taskFocusIntentService.toggleCollapsedTask(
        collapsedTaskIds: ref.read(ganttCollapsedTaskIdsProvider),
        taskId: taskId,
      ),
      onApplyCollapsedTaskIds: _applyCollapsedTaskIds,
    );
  }

  void _focusTaskBranch(String taskId) {
    _taskFocusIntentDispatcher.dispatchBranchFocus(
      intent: _taskFocusIntentService.focusBranch(
        taskId: taskId,
        collapsedTaskIds: ref.read(ganttCollapsedTaskIdsProvider),
      ),
      onApplyBranchFocus: _applyBranchFocus,
      onApplyCollapsedTaskIds: _applyCollapsedTaskIds,
    );
  }

  void _applyBranchFocus(String taskId) {
    ref.read(ganttBranchFocusTaskIdProvider.notifier).state = taskId;
  }

  void _applyCollapsedTaskIds(Set<String> collapsedTaskIds) {
    ref.read(ganttCollapsedTaskIdsProvider.notifier).state = collapsedTaskIds;
  }

  void _revealSelectedTask() {
    _applyTaskSelectionIntent(
      _taskFocusIntentService.revealSelectedTask(
        ref.read(gantt.selectedTaskProvider),
      ),
    );
  }

  void _undoLastTaskEdit() {
    ref.read(gantt.tasksProvider.notifier).undoLastTaskEdit();
  }

  void _showTaskScheduleFeedback(gantt.GanttTaskEditActivity activity) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _scheduleFeedbackSnackBarFactory.snackBarFor(
          activity: activity,
          onUndo: _undoLastTaskEdit,
        ),
      );
  }

  void _showTaskScheduleGuardFeedback(
    gantt.GanttTask task,
    DateTime startDate,
    DateTime endDate,
    ky.KyGanttTaskDateRangeValidation validation,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _scheduleFeedbackSnackBarFactory.rejectedSnackBarFor(
          task: task,
          validation: validation,
          onReview: () => _openTaskInspector(task.id),
        ),
      );
  }

  GanttTaskInspectorActions _inspectorActionsFor({
    required gantt.GanttTask selectedTask,
    required bool canUndoSelectedTaskEdit,
    required String? selectedTaskProjectId,
    required VoidCallback? onPreviousTask,
    required VoidCallback? onNextTask,
  }) {
    return _inspectorActionService.actionsFor(
      tasksNotifier: ref.read(gantt.tasksProvider.notifier),
      selectedTask: selectedTask,
      canUndoSelectedTaskEdit: canUndoSelectedTaskEdit,
      onClearSelection: _clearSelectedTask,
      onPreviousTask: onPreviousTask,
      onNextTask: onNextTask,
      onFocusBranch: () => _focusTaskBranch(selectedTask.id),
      onRecentEditSelected: _selectRecentEditActivity,
      onTaskSelected: _openTaskInspector,
      onOpenProject:
          selectedTaskProjectId == null
              ? null
              : () => context.go('/projects/$selectedTaskProjectId'),
    );
  }

  void _toggleControls() {
    _setControlsExpanded(
      _controlIntentService.nextControlsExpanded(
        controlsExpanded: ref.read(ganttChartControlsExpandedProvider),
      ),
    );
  }

  void _openViewSettings() {
    showDialog<void>(
      context: context,
      builder: (context) => const GanttChartViewSettingsDialog(),
    );
  }

  void _focusTimelineSearch() {
    _controlIntentDispatcher.dispatchSearchFocus(
      intent: _controlIntentService.focusSearch(
        controlsExpanded: ref.read(ganttChartControlsExpandedProvider),
      ),
      onExpandControls: () => _setControlsExpanded(true),
      onScheduleSearchFocus: _scheduleTimelineSearchFocus,
    );
  }

  void _scheduleTimelineSearchFocus({required bool selectText}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _searchFocusNode.requestFocus();
      if (selectText) {
        _searchController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchController.text.length,
        );
      }
    });
  }

  void _setControlsExpanded(bool controlsExpanded) {
    ref
        .read(ganttChartWorkspacePreferencesProvider.notifier)
        .setControlsExpanded(controlsExpanded);
  }

  void _moveTaskDateRange(
    gantt.GanttTask task,
    DateTime startDate,
    DateTime endDate,
  ) {
    final result = _dateRangeEditService.applyDateRangeEdit(
      tasksNotifier: ref.read(gantt.tasksProvider.notifier),
      task: task,
      startDate: startDate,
      endDate: endDate,
      feedbackEnabled:
          ref
              .read(ganttChartInteractionPreferencesProvider)
              .showScheduleEditFeedback,
    );
    final activity = result.feedbackActivity;
    if (activity == null) return;

    _showTaskScheduleFeedback(activity);
  }

  void _applyTimelineRangePreset(
    GanttTimelineRangePreset preset,
    List<gantt.GanttTask> tasks,
  ) {
    final range = _timelineFocusIntentService.rangeForPreset(
      preset: preset,
      tasks: tasks,
    );
    ref.read(gantt.dateRangeProvider.notifier).state = range;
  }

  void _applyInitialRouteFocus() {
    Future<void>(() {
      if (!mounted) return;

      final result = _routeFocusIntentService.projectFocusFor(
        projectId: widget.initialProjectId,
        availableProjectIds: ref
            .read(projectPortfolioProvider)
            .map((project) => project.id),
      );
      _routeFocusIntentDispatcher.dispatchProjectFocus(
        intent: result,
        onApplyProjectFocus: _applyInitialProjectFocus,
        onResolveTaskSelection: _applyInitialTaskSelection,
      );
    });
  }

  void _applyInitialProjectFocus(String projectId) {
    ref.read(ganttProjectFilterProvider.notifier).state = projectId;
  }

  void _applyInitialTaskSelection() {
    final result = _routeFocusIntentService.taskSelectionFor(
      taskId: widget.initialTaskId,
      visibleTasks: ref.read(operationalGanttTasksProvider),
    );
    _routeFocusIntentDispatcher.dispatchTaskSelection(
      intent: result,
      onSelectTask: _openTaskInspector,
    );
  }

  void _selectRecentEditActivity(gantt.GanttTaskEditActivity activity) {
    _applyTaskSelectionIntent(
      _taskFocusIntentService.selectRecentEditTask(
        taskId: activity.taskId,
        allTasks: ref.read(gantt.tasksProvider),
        visibleTasks: ref.read(operationalGanttTasksProvider),
      ),
    );
  }

  void _applyTaskSelectionIntent(GanttChartTaskSelectionIntentResult intent) {
    _taskSelectionIntentDispatcher.dispatch(
      intent: intent,
      onClearTimelineFocus: _clearTimelineFilters,
      onSelectTask: _openTaskInspector,
    );
  }
}
