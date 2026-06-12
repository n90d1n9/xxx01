import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../controllers/scrum_board_controller.dart';
import '../../models/scrum_board_config.dart';
import '../../models/scrum_board_filter.dart';
import '../../models/scrum_lane_health.dart';
import '../../models/scrum_task.dart';
import '../../models/scrum_task_status.dart';
import '../presentation/board_snack_bar_presenter.dart';
import '../scrum_board_palette.dart';
import 'board_lane_callbacks.dart';
import 'board_task_callbacks.dart';
import 'scrum_board_column.dart';

/// Renders board lanes in either compact vertical or desktop horizontal layout.
class BoardLaneCollection extends StatelessWidget {
  const BoardLaneCollection({
    super.key,
    required this.controller,
    required this.config,
    required this.filter,
    required this.statuses,
    required this.compact,
    required this.selectedTaskIds,
    required this.collapsedStatuses,
    required this.onFilterChanged,
    required this.onColumnCollapsedChanged,
    required this.onCreateTask,
    required this.onTaskPressed,
    this.onTaskSelectionChanged,
    this.onTaskBatchSelectionChanged,
  });

  final ScrumBoardController controller;
  final ScrumBoardConfig config;
  final ScrumBoardFilter filter;
  final List<ScrumTaskStatus> statuses;
  final bool compact;
  final Set<String> selectedTaskIds;
  final Set<ScrumTaskStatus> collapsedStatuses;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;
  final ScrumColumnCollapseChanged onColumnCollapsedChanged;
  final ScrumTaskCreateRequest onCreateTask;
  final ValueChanged<ScrumTask> onTaskPressed;
  final ScrumTaskSelectionHandler? onTaskSelectionChanged;
  final ScrumTaskBatchSelectionHandler? onTaskBatchSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ListView.separated(
        itemCount: statuses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildColumn(context, statuses[index], compact: true);
        },
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: statuses.length,
      separatorBuilder: (context, index) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        return _buildColumn(context, statuses[index], compact: false);
      },
    );
  }

  Widget _buildColumn(
    BuildContext context,
    ScrumTaskStatus status, {
    required bool compact,
  }) {
    final tasks = controller.tasksFor(status, filter: filter);
    final hiddenTaskCount = _hiddenTaskCountFor(status, tasks);

    return ScrumBoardColumn(
      status: status,
      statusLabel: config.labelFor(status),
      tasks: tasks,
      storyPoints: _storyPoints(tasks),
      health: _laneHealthFor(tasks),
      wipLimit: controller.policy.limitFor(status),
      enforceWipLimit: controller.policy.enforceWipLimits,
      dueSoonDays: controller.policy.dueSoonDays,
      reviewAgeWarningDays: controller.policy.reviewAgeWarningDays,
      statusStartedAtForTask: controller.statusStartedAtForTask,
      hiddenTaskCount: hiddenTaskCount,
      onClearFilters: hiddenTaskCount > 0
          ? () => onFilterChanged(filter.clearTaskFacets())
          : null,
      selectedTaskIds: selectedTaskIds,
      onTaskSelectionChanged: onTaskSelectionChanged,
      onTaskBatchSelectionChanged: onTaskBatchSelectionChanged,
      collapsed: collapsedStatuses.contains(status),
      onCollapsedChanged: (collapsed) =>
          onColumnCollapsedChanged(status, collapsed),
      width: compact ? null : config.columnWidth,
      height: compact ? config.compactColumnHeight : null,
      onAddTask: () => onCreateTask(status: status),
      onTaskPressed: onTaskPressed,
      onTaskDropped: (taskId, beforeTaskId) =>
          _handleTaskDrop(context, taskId, status, beforeTaskId: beforeTaskId),
    );
  }

  int _hiddenTaskCountFor(ScrumTaskStatus status, List<ScrumTask> tasks) {
    if (!filter.hasTaskFacets || tasks.isNotEmpty) return 0;
    return controller.countFor(status);
  }

  ScrumLaneHealth _laneHealthFor(List<ScrumTask> tasks) {
    return ScrumLaneHealth.forTasks(
      tasks,
      dueSoonDays: controller.policy.dueSoonDays,
      reviewAgeWarningDays: controller.policy.reviewAgeWarningDays,
      statusStartedAtForTask: controller.statusStartedAtForTask,
    );
  }

  void _handleTaskDrop(
    BuildContext context,
    String taskId,
    ScrumTaskStatus status, {
    String? beforeTaskId,
  }) {
    final result = controller.placeTaskWithResult(
      taskId,
      status,
      beforeTaskId: beforeTaskId,
    );
    if (result.accepted) return;

    const BoardSnackBarPresenter().show(context, result.message);
  }
}

/// Preview for the reusable desktop lane collection.
@Preview(group: 'Ky Scrumboard', name: 'Lane collection', size: Size(980, 620))
Widget boardLaneCollectionPreview() {
  const config = ScrumBoardConfig(showInsights: false);
  final controller = ScrumBoardController.demo(config: config);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BoardLaneCollection(
          controller: controller,
          config: config,
          filter: const ScrumBoardFilter(),
          statuses: const [
            ScrumTaskStatus.todo,
            ScrumTaskStatus.inProgress,
            ScrumTaskStatus.review,
          ],
          compact: false,
          selectedTaskIds: const {},
          collapsedStatuses: const {},
          onFilterChanged: (_) {},
          onColumnCollapsedChanged: (_, _) {},
          onCreateTask: ({ScrumTaskStatus? status}) {},
          onTaskPressed: (_) {},
        ),
      ),
    ),
  );
}

int _storyPoints(Iterable<ScrumTask> tasks) {
  return tasks.fold<int>(0, (total, task) => total + task.storyPoints);
}
