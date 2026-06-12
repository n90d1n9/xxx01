import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'board_task_callbacks.dart';
import 'scrum_board_column_body.dart';
import 'scrum_task_card.dart';

/// Task-card list for a board lane, including empty and collapsed states.
class BoardLaneTaskList extends StatelessWidget {
  const BoardLaneTaskList({
    super.key,
    required this.color,
    required this.tasks,
    required this.statusLabel,
    required this.storyPoints,
    required this.hiddenTaskCount,
    required this.collapsed,
    required this.onTaskDropped,
    required this.onTaskPressed,
    this.selectedTaskIds = const {},
    this.onTaskSelectionChanged,
    this.onClearFilters,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
    this.statusStartedAtForTask,
  });

  final Color color;
  final List<ScrumTask> tasks;
  final String statusLabel;
  final int storyPoints;
  final int hiddenTaskCount;
  final bool collapsed;
  final ScrumTaskDropHandler onTaskDropped;
  final ValueChanged<ScrumTask> onTaskPressed;
  final Set<String> selectedTaskIds;
  final ScrumTaskSelectionHandler? onTaskSelectionChanged;
  final VoidCallback? onClearFilters;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime Function(ScrumTask task)? statusStartedAtForTask;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return BoardTaskDropTarget(
        color: color,
        beforeTaskId: null,
        onTaskDropped: onTaskDropped,
        child: ScrumBoardCollapsedColumnBody(
          color: color,
          count: tasks.length,
          storyPoints: storyPoints,
          hiddenTaskCount: hiddenTaskCount,
          onClearFilters: onClearFilters,
        ),
      );
    }

    if (tasks.isEmpty) {
      return BoardTaskDropTarget(
        color: color,
        beforeTaskId: null,
        onTaskDropped: onTaskDropped,
        child: ScrumBoardEmptyColumn(
          color: color,
          hiddenTaskCount: hiddenTaskCount,
          onClearFilters: onClearFilters,
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length + 1,
      itemBuilder: (context, index) {
        if (index == tasks.length) {
          return BoardTaskDropTarget(
            color: color,
            beforeTaskId: null,
            onTaskDropped: onTaskDropped,
            child: const ScrumBoardEndDropZone(),
          );
        }

        final task = tasks[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BoardTaskDropTarget(
            color: color,
            beforeTaskId: task.id,
            onTaskDropped: onTaskDropped,
            child: ScrumTaskCard(
              task: task,
              dueSoonDays: dueSoonDays,
              reviewAgeWarningDays: reviewAgeWarningDays,
              statusStartedAt: statusStartedAtForTask?.call(task),
              statusLabel: statusLabel,
              selected: selectedTaskIds.contains(task.id),
              onSelectedChanged: (selected) =>
                  onTaskSelectionChanged?.call(task.id, selected),
              onPressed: () => onTaskPressed(task),
            ),
          ),
        );
      },
    );
  }
}

/// Preview for a board lane task list with drop zones.
@Preview(group: 'Ky Scrumboard', name: 'Lane task list', size: Size(340, 360))
Widget boardLaneTaskListPreview() {
  final now = DateTime(2026, 1, 10);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: SizedBox(
        width: 320,
        child: BoardLaneTaskList(
          color: const Color(0xFF2563EB),
          tasks: [
            ScrumTask(
              id: 'review',
              title: 'Review payment copy',
              description: 'Confirm checkout copy before release.',
              assignee: 'Alya',
              storyPoints: 5,
              createdAt: DateTime(2026, 1, 3),
              dueAt: now.add(const Duration(days: 1)),
              status: ScrumTaskStatus.review,
              priority: ScrumTaskPriority.high,
              label: 'Payments',
              accentColor: const Color(0xFF2563EB),
            ),
          ],
          statusLabel: 'Review',
          storyPoints: 5,
          hiddenTaskCount: 0,
          collapsed: false,
          selectedTaskIds: const {'review'},
          statusStartedAtForTask: (_) => DateTime(2026, 1, 6),
          onTaskDropped: (_, _) {},
          onTaskPressed: (_) {},
          onTaskSelectionChanged: (_, _) {},
        ),
      ),
    ),
  );
}

/// Drop target wrapper for task-card and lane-empty positions.
class BoardTaskDropTarget extends StatelessWidget {
  const BoardTaskDropTarget({
    super.key,
    required this.color,
    required this.beforeTaskId,
    required this.onTaskDropped,
    required this.child,
  });

  final Color color;
  final String? beforeTaskId;
  final ScrumTaskDropHandler onTaskDropped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) =>
          onTaskDropped(details.data, beforeTaskId),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.all(hovering ? 6 : 0),
          decoration: BoxDecoration(
            color: hovering ? color.withValues(alpha: .08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: hovering
                ? Border.all(color: color.withValues(alpha: .35))
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

/// Preview for a standalone board task drop target.
@Preview(group: 'Ky Scrumboard', name: 'Task drop target', size: Size(260, 100))
Widget boardTaskDropTargetPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 220,
          child: BoardTaskDropTarget(
            color: const Color(0xFF0891B2),
            beforeTaskId: null,
            onTaskDropped: (_, _) {},
            child: const ScrumBoardEndDropZone(),
          ),
        ),
      ),
    ),
  );
}
