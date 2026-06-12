import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../../models/scrum_lane_health.dart';
import '../scrum_board_palette.dart';
import 'board_lane_task_list.dart';
import 'board_task_callbacks.dart';
import 'scrum_board_column_header.dart';

/// Scrumboard lane that renders task cards, lane actions, and drop targets.
class ScrumBoardColumn extends StatelessWidget {
  const ScrumBoardColumn({
    super.key,
    required this.status,
    required this.statusLabel,
    required this.tasks,
    required this.storyPoints,
    required this.onAddTask,
    required this.onTaskPressed,
    required this.onTaskDropped,
    this.selectedTaskIds = const {},
    this.onTaskSelectionChanged,
    this.onTaskBatchSelectionChanged,
    this.health = ScrumLaneHealth.empty,
    this.collapsed = false,
    this.onCollapsedChanged,
    this.dueSoonDays = 2,
    this.reviewAgeWarningDays = 3,
    this.statusStartedAtForTask,
    this.hiddenTaskCount = 0,
    this.onClearFilters,
    this.wipLimit,
    this.enforceWipLimit = false,
    this.width,
    this.height,
  });

  final ScrumTaskStatus status;
  final String statusLabel;
  final List<ScrumTask> tasks;
  final int storyPoints;
  final ScrumLaneHealth health;
  final VoidCallback onAddTask;
  final ValueChanged<ScrumTask> onTaskPressed;
  final ScrumTaskDropHandler onTaskDropped;
  final Set<String> selectedTaskIds;
  final ScrumTaskSelectionHandler? onTaskSelectionChanged;
  final ScrumTaskBatchSelectionHandler? onTaskBatchSelectionChanged;
  final bool collapsed;
  final ValueChanged<bool>? onCollapsedChanged;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime Function(ScrumTask task)? statusStartedAtForTask;
  final int hiddenTaskCount;
  final VoidCallback? onClearFilters;
  final int? wipLimit;
  final bool enforceWipLimit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final color = ScrumBoardPalette.statusColor(status);
    final overLimit = wipLimit != null && tasks.length > wipLimit!;
    final guarded = enforceWipLimit && wipLimit != null;
    final atGuardedLimit = guarded && tasks.length >= wipLimit!;
    final selectedCount = tasks
        .where((task) => selectedTaskIds.contains(task.id))
        .length;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: overLimit
                ? const Color(0xFFDC2626)
                : atGuardedLimit
                ? const Color(0xFFF59E0B)
                : ScrumBoardPalette.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScrumBoardColumnHeader(
              statusLabel: statusLabel,
              color: color,
              count: tasks.length,
              storyPoints: storyPoints,
              health: health,
              wipLimit: wipLimit,
              overLimit: overLimit,
              guarded: guarded,
              selectedCount: selectedCount,
              canSelectTasks:
                  onTaskBatchSelectionChanged != null && tasks.isNotEmpty,
              collapsed: collapsed,
              onCollapsedChanged: onCollapsedChanged,
              onToggleTaskSelection: () => onTaskBatchSelectionChanged?.call(
                tasks.map((task) => task.id),
                selectedCount < tasks.length,
              ),
              onAddTask: onAddTask,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BoardLaneTaskList(
                color: color,
                tasks: tasks,
                statusLabel: statusLabel,
                storyPoints: storyPoints,
                hiddenTaskCount: hiddenTaskCount,
                collapsed: collapsed,
                onClearFilters: onClearFilters,
                selectedTaskIds: selectedTaskIds,
                onTaskSelectionChanged: onTaskSelectionChanged,
                dueSoonDays: dueSoonDays,
                reviewAgeWarningDays: reviewAgeWarningDays,
                statusStartedAtForTask: statusStartedAtForTask,
                onTaskDropped: onTaskDropped,
                onTaskPressed: onTaskPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview for a complete scrumboard lane with selectable task cards.
@Preview(group: 'Ky Scrumboard', name: 'Board column', size: Size(360, 620))
Widget scrumBoardColumnPreview() {
  final createdAt = DateTime(2026, 1, 1);
  final tasks = [
    ScrumTask(
      id: 'checkout',
      title: 'Checkout handoff polish',
      description: 'Tighten payment review states and gateway copy.',
      assignee: 'Alya',
      storyPoints: 5,
      createdAt: createdAt,
      dueAt: DateTime(2026, 1, 4),
      status: ScrumTaskStatus.inProgress,
      priority: ScrumTaskPriority.high,
      label: 'Payments',
      accentColor: const Color(0xFF2563EB),
    ),
    ScrumTask(
      id: 'reports',
      title: 'Daily settlement report',
      description: 'Expose the settlement export from the operations board.',
      assignee: 'Bima',
      storyPoints: 3,
      createdAt: createdAt,
      status: ScrumTaskStatus.inProgress,
      priority: ScrumTaskPriority.medium,
      label: 'Ops',
      accentColor: const Color(0xFF0891B2),
    ),
  ];

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardColumn(
          width: 320,
          height: 560,
          status: ScrumTaskStatus.inProgress,
          statusLabel: 'In Progress',
          tasks: tasks,
          storyPoints: 8,
          health: const ScrumLaneHealth(
            overdueTasks: 0,
            dueSoonTasks: 1,
            agedReviewTasks: 0,
          ),
          wipLimit: 4,
          enforceWipLimit: true,
          selectedTaskIds: const {'checkout'},
          onAddTask: () {},
          onTaskPressed: (_) {},
          onTaskDropped: (_, _) {},
          onTaskSelectionChanged: (_, _) {},
          onTaskBatchSelectionChanged: (_, _) {},
          onCollapsedChanged: (_) {},
        ),
      ),
    ),
  );
}
