import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../controllers/board_filter_state.dart';
import '../controllers/board_interaction_state.dart';
import '../controllers/scrum_board_controller.dart';
import '../models/scrum_board_config.dart';
import '../models/scrum_board_filter.dart';
import '../models/scrum_task.dart';
import '../models/scrum_task_move_preview.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';
import 'presentation/board_action_feedback.dart';
import 'presentation/board_snack_bar_presenter.dart';
import 'presentation/board_task_deletion_planner.dart';
import 'presentation/board_task_detail_action_dispatcher.dart';
import 'presentation/board_task_move_outcome.dart';
import 'scrum_board_palette.dart';
import 'widgets/scrum_active_filter_bar.dart';
import 'widgets/scrum_board_header.dart';
import 'widgets/scrum_board_toolbar.dart';
import 'widgets/scrum_board_viewport.dart';
import 'widgets/scrum_bulk_action_bar.dart';
import 'widgets/scrum_task_delete_confirmation_dialog.dart';
import 'widgets/scrum_task_detail_dialog.dart';
import 'widgets/scrum_task_editor_dialog.dart';
import 'widgets/scrum_task_move_preview_dialog.dart';

/// Complete scrumboard screen with filtering, bulk actions, lanes, and details.
class ScrumBoardScreen extends StatefulWidget {
  @Preview(
    group: 'Ky Scrumboard',
    name: 'Full scrumboard screen',
    size: Size(1440, 960),
  )
  const ScrumBoardScreen({
    super.key,
    this.controller,
    this.config = const ScrumBoardConfig(),
    this.title,
  });

  final ScrumBoardController? controller;
  final ScrumBoardConfig config;
  final String? title;

  @override
  State<ScrumBoardScreen> createState() => _ScrumBoardScreenState();
}

class _ScrumBoardScreenState extends State<ScrumBoardScreen> {
  late ScrumBoardController _controller;
  late bool _ownsController;
  late BoardFilterState _filterState;
  final BoardInteractionState _interactionState = BoardInteractionState();
  final BoardActionFeedback _feedback = const BoardActionFeedback();
  final BoardSnackBarPresenter _snackBarPresenter =
      const BoardSnackBarPresenter();
  final BoardTaskMoveOutcomePlanner _moveOutcomePlanner =
      const BoardTaskMoveOutcomePlanner();

  BoardTaskDeletionPlanner get _deletionPlanner {
    return BoardTaskDeletionPlanner(taskById: _controller.taskById);
  }

  @override
  void initState() {
    super.initState();
    _filterState = BoardFilterState(config: widget.config);
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant ScrumBoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        (_ownsController && oldWidget.config != widget.config)) {
      if (_ownsController) _controller.dispose();
      _attachController(widget.controller);
    }
    _filterState.reconcileConfig(widget.config);
    _interactionState.retainCollapsedStatusesWhere(
      widget.config.includesStatus,
    );
    if (widget.config.showBulkActions) {
      _pruneSelection();
    } else {
      _interactionState.clearSelection();
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final filter = _filterState.filter;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScrumBoardHeader(
                title: widget.title ?? widget.config.title,
                subtitle: widget.config.subtitle,
                summary: _controller.summary,
                sprint: widget.config.sprint,
                onCreateTask: () => _openTaskEditor(),
              ),
              ScrumBoardToolbar(
                filter: filter,
                statuses: widget.config.visibleStatuses,
                statusCounts: _statusCountsFor(filter),
                viewPresets: widget.config.visibleViewPresets,
                assignees: _controller.assignees(),
                showPriorityFilter: widget.config.showPriorityFilter,
                showAssigneeFilter: widget.config.showAssigneeFilter,
                showSortControl: widget.config.showSortControl,
                showViewPresets: widget.config.showViewPresets,
                statusLabelFor: widget.config.labelFor,
                onFilterChanged: _setFilter,
              ),
              ScrumActiveFilterBar(
                filter: filter,
                statusLabelFor: widget.config.labelFor,
                onFilterChanged: _setFilter,
              ),
              if (widget.config.showBulkActions)
                ScrumBulkActionBar(
                  selectedCount: _interactionState.selectedCount,
                  statuses: widget.config.visibleStatuses,
                  statusLabelFor: widget.config.labelFor,
                  onMoveToStatus: _moveSelectedTasks,
                  onPriorityChanged: _updateSelectedPriorities,
                  onDelete: _deleteSelectedTasks,
                  onClearSelection: () =>
                      setState(_interactionState.clearSelection),
                ),
              Expanded(
                child: ScrumBoardViewport(
                  controller: _controller,
                  config: widget.config,
                  filter: filter,
                  selectedTaskIds: widget.config.showBulkActions
                      ? _interactionState.selectedTaskIds
                      : const {},
                  collapsedStatuses: _interactionState.collapsedStatuses,
                  onFilterChanged: _setFilter,
                  onColumnCollapsedChanged: _setColumnCollapsed,
                  onVisibleColumnsCollapsedChanged: _setVisibleColumnsCollapsed,
                  onTaskSelectionChanged: widget.config.showBulkActions
                      ? _setTaskSelection
                      : null,
                  onTaskBatchSelectionChanged: widget.config.showBulkActions
                      ? _setTaskGroupSelection
                      : null,
                  onCreateTask: _openTaskEditor,
                  onTaskPressed: _openTaskDetails,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _attachController(ScrumBoardController? controller) {
    _ownsController = controller == null;
    _controller =
        controller ?? ScrumBoardController.demo(config: widget.config);
  }

  void _setFilter(ScrumBoardFilter filter) {
    setState(() {
      _filterState.setFilter(filter);
    });
  }

  Future<void> _openTaskEditor({
    ScrumTask? task,
    ScrumTaskStatus? status,
  }) async {
    final savedTask = await showScrumTaskEditor(
      context,
      task: task,
      initialStatus: status ?? task?.status ?? ScrumTaskStatus.todo,
      statuses: widget.config.visibleStatuses,
      statusLabelFor: widget.config.labelFor,
    );
    if (savedTask == null) return;

    if (task == null) {
      _controller.addTask(savedTask);
    } else {
      _controller.updateTask(savedTask);
    }
  }

  void _setTaskSelection(String taskId, bool selected) {
    setState(() {
      _interactionState.setTaskSelection(taskId, selected);
    });
  }

  void _setTaskGroupSelection(Iterable<String> taskIds, bool selected) {
    setState(() {
      _interactionState.setTaskGroupSelection(taskIds, selected);
    });
  }

  void _setColumnCollapsed(ScrumTaskStatus status, bool collapsed) {
    setState(() {
      _interactionState.setColumnCollapsed(status, collapsed);
    });
  }

  void _setVisibleColumnsCollapsed(
    Iterable<ScrumTaskStatus> statuses,
    bool collapsed,
  ) {
    setState(() {
      _interactionState.setVisibleColumnsCollapsed(statuses, collapsed);
    });
  }

  Map<ScrumTaskStatus, int> _statusCountsFor(ScrumBoardFilter filter) {
    return {
      for (final status in widget.config.visibleStatuses)
        status: _controller.tasksFor(status, filter: filter).length,
    };
  }

  void _moveSelectedTasks(ScrumTaskStatus status) {
    final selectedIds = _interactionState.selectedTaskIdList();
    if (selectedIds.isEmpty) return;

    final preview = _controller.previewTaskMoves(selectedIds, status);
    _confirmAndMoveSelectedTasks(status, preview);
  }

  Future<void> _confirmAndMoveSelectedTasks(
    ScrumTaskStatus status,
    ScrumTaskMovePreview preview,
  ) async {
    final confirmed = await showScrumTaskMovePreview(
      context,
      preview: preview,
      statusLabelFor: widget.config.labelFor,
      taskTitleFor: _taskTitleFor,
    );
    if (!mounted || !confirmed) return;

    final movableIds = _moveOutcomePlanner.movableTaskIds(preview);
    final results = _controller.moveTasks(movableIds, status);
    final outcome = _moveOutcomePlanner.summarize(
      results: results,
      statusLabel: widget.config.labelFor(status),
    );

    setState(() {
      _interactionState.removeSelectedTasks(outcome.changedTaskIds);
    });

    _showSnackBar(outcome.message);
  }

  void _updateSelectedPriorities(ScrumTaskPriority priority) {
    _controller.updateTaskPriorities(
      _interactionState.selectedTaskIds,
      priority,
    );
    setState(_interactionState.clearSelection);
  }

  void _deleteSelectedTasks() {
    final selectedIds = _interactionState.selectedTaskIdList();
    if (selectedIds.isEmpty) return;
    _confirmAndDeleteSelectedTasks(selectedIds);
  }

  Future<void> _confirmAndDeleteSelectedTasks(List<String> selectedIds) async {
    final deletionPlan = _deletionPlanner.planSelectedTasks(selectedIds);
    if (!deletionPlan.canConfirm) return;

    final confirmed = await showScrumTaskDeleteConfirmation(
      context,
      taskCount: deletionPlan.taskCount,
    );
    if (!mounted || !confirmed) return;

    final deletedCount = _controller.deleteTasks(selectedIds);
    setState(() => _interactionState.removeSelectedTasks(selectedIds));

    if (deletedCount > 0) {
      _showDeleteSnackBar(deletionPlan.selectedTasks, deletedCount);
    }
  }

  Future<void> _confirmAndDeleteTask(ScrumTask task) async {
    final confirmed = await showScrumTaskDeleteConfirmation(
      context,
      taskCount: 1,
      taskTitle: task.title,
    );
    if (!mounted || !confirmed) return;

    if (_controller.deleteTask(task.id)) {
      setState(() => _interactionState.removeSelectedTask(task.id));
      _showDeleteSnackBar([task], 1);
    }
  }

  String _taskTitleFor(String taskId) {
    return _controller.taskById(taskId)?.title ?? taskId;
  }

  void _showDeleteSnackBar(List<ScrumTask> tasks, int deletedCount) {
    final restorableTasks = _deletionPlanner.restorableTasks(tasks);

    _showSnackBar(
      _feedback.deletedTasks(deletedCount),
      action: restorableTasks.isEmpty
          ? null
          : SnackBarAction(
              label: 'Undo',
              onPressed: () => _restoreDeletedTasks(restorableTasks),
            ),
    );
  }

  void _restoreDeletedTasks(List<ScrumTask> tasks) {
    if (!mounted) return;

    final restoredCount = _controller.restoreTasks(tasks);
    if (restoredCount <= 0) return;

    setState(() {
      _interactionState.removeSelectedTasks(tasks.map((task) => task.id));
    });
    _showSnackBar(_feedback.restoredTasks(restoredCount));
  }

  void _pruneSelection() {
    _interactionState.pruneSelection(
      (taskId) => _controller.taskById(taskId) != null,
    );
  }

  void _showSnackBar(String message, {SnackBarAction? action}) {
    _snackBarPresenter.show(context, message, action: action);
  }

  Future<void> _openTaskDetails(ScrumTask task) async {
    final result = await showScrumTaskDetails(
      context,
      task: task,
      activities: _controller.activitiesForTask(task.id, limit: 5),
      statuses: widget.config.visibleStatuses,
      statusLabelFor: widget.config.labelFor,
      dueSoonDays: _controller.policy.dueSoonDays,
      reviewAgeWarningDays: _controller.policy.reviewAgeWarningDays,
      statusStartedAt: _controller.statusStartedAtForTask(task),
    );
    if (result == null) return;

    await _detailActionDispatcher.dispatch(task, result);
  }

  BoardTaskDetailActionDispatcher get _detailActionDispatcher {
    return BoardTaskDetailActionDispatcher(
      onEdit: (task) => _openTaskEditor(task: task),
      onDelete: _confirmAndDeleteTask,
      onMove: _moveTaskFromDetails,
      onPriorityChanged: _updateTaskPriorityFromDetails,
      onNoteAdded: _addTaskNoteFromDetails,
    );
  }

  void _moveTaskFromDetails(ScrumTask task, ScrumTaskStatus status) {
    final result = _controller.placeTaskWithResult(task.id, status);
    if (!result.accepted) {
      _showSnackBar(result.message);
      return;
    }
    if (!result.changed) return;

    setState(() => _interactionState.removeSelectedTask(task.id));
    _showSnackBar(_feedback.movedTasks(1, widget.config.labelFor(status)));
  }

  void _updateTaskPriorityFromDetails(
    ScrumTask task,
    ScrumTaskPriority priority,
  ) {
    final updatedCount = _controller.updateTaskPriorities([task.id], priority);
    if (updatedCount == 0) return;

    _showSnackBar(_feedback.priorityChanged(priority));
  }

  void _addTaskNoteFromDetails(ScrumTask task, String note) {
    if (!_controller.addTaskNote(task.id, note)) return;

    _showSnackBar(_feedback.taskNoteAdded());
  }
}
