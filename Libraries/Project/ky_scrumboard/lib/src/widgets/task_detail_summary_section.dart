import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_task_detail_common.dart';
import 'scrum_task_signal_badges.dart';

/// Status, priority, and estimate pills shown at the top of task details.
class TaskDetailSummaryPills extends StatelessWidget {
  const TaskDetailSummaryPills({
    super.key,
    required this.task,
    required this.statusLabelFor,
  });

  final ScrumTask task;
  final String Function(ScrumTaskStatus status) statusLabelFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ScrumTaskDetailPill(
          label: statusLabelFor(task.status),
          color: ScrumBoardPalette.statusColor(task.status),
        ),
        ScrumTaskDetailPill(
          label: task.priority.label,
          color: ScrumBoardPalette.priorityColor(task.priority),
        ),
        ScrumTaskDetailPill(
          label: '${task.storyPoints} story points',
          color: task.accentColor,
        ),
      ],
    );
  }
}

/// Preview for task detail summary pills.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail summary',
  size: Size(420, 100),
)
Widget taskDetailSummaryPillsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: TaskDetailSummaryPills(
          task: ScrumTask(
            id: 'summary',
            title: 'Summary task',
            description: 'Summary preview.',
            assignee: 'Alya',
            storyPoints: 5,
            createdAt: DateTime(2026, 1, 1),
            status: ScrumTaskStatus.review,
            priority: ScrumTaskPriority.high,
          ),
          statusLabelFor: (status) => status.label,
        ),
      ),
    ),
  );
}

/// Signal badges section shown only when a task needs extra attention.
class TaskDetailSignalSection extends StatelessWidget {
  const TaskDetailSignalSection({
    super.key,
    required this.task,
    required this.dueSoonDays,
    required this.reviewAgeWarningDays,
    required this.statusLabel,
    this.statusStartedAt,
    this.now,
  });

  final ScrumTask task;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final String statusLabel;
  final DateTime? statusStartedAt;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    if (!ScrumTaskSignalBadges.hasSignalsFor(
      task,
      dueSoonDays: dueSoonDays,
      reviewAgeWarningDays: reviewAgeWarningDays,
      statusStartedAt: statusStartedAt,
      now: now,
    )) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ScrumTaskSignalBadges(
        task: task,
        dueSoonDays: dueSoonDays,
        reviewAgeWarningDays: reviewAgeWarningDays,
        statusStartedAt: statusStartedAt,
        statusLabel: statusLabel,
        now: now,
      ),
    );
  }
}

/// Preview for task detail signal badges.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail signals',
  size: Size(420, 100),
)
Widget taskDetailSignalSectionPreview() {
  final now = DateTime(2026, 1, 10);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: TaskDetailSignalSection(
          task: ScrumTask(
            id: 'signal',
            title: 'Signal task',
            description: 'Signal preview.',
            assignee: 'Bima',
            storyPoints: 3,
            createdAt: DateTime(2026, 1, 1),
            dueAt: DateTime(2026, 1, 9),
            status: ScrumTaskStatus.review,
            priority: ScrumTaskPriority.critical,
          ),
          dueSoonDays: 2,
          reviewAgeWarningDays: 3,
          statusStartedAt: DateTime(2026, 1, 5),
          statusLabel: 'Review',
          now: now,
        ),
      ),
    ),
  );
}
