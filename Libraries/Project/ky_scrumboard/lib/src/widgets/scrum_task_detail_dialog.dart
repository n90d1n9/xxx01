import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import 'scrum_task_detail_actions.dart';
import 'scrum_task_detail_content.dart';
import 'scrum_task_detail_header.dart';
import 'task_detail_panel_shell.dart';

/// Actions that can be requested from the task detail panel.
enum ScrumTaskDetailAction { edit, delete, move, priority, note }

/// Command result returned when the task detail panel closes.
class ScrumTaskDetailResult {
  const ScrumTaskDetailResult._(
    this.action, {
    this.status,
    this.priority,
    this.note,
  });

  const ScrumTaskDetailResult.edit() : this._(ScrumTaskDetailAction.edit);

  const ScrumTaskDetailResult.delete() : this._(ScrumTaskDetailAction.delete);

  const ScrumTaskDetailResult.move(ScrumTaskStatus status)
    : this._(ScrumTaskDetailAction.move, status: status);

  const ScrumTaskDetailResult.priority(ScrumTaskPriority priority)
    : this._(ScrumTaskDetailAction.priority, priority: priority);

  const ScrumTaskDetailResult.note(String note)
    : this._(ScrumTaskDetailAction.note, note: note);

  final ScrumTaskDetailAction action;
  final ScrumTaskStatus? status;
  final ScrumTaskPriority? priority;
  final String? note;
}

/// Shows the task detail side panel and returns the requested task action.
Future<ScrumTaskDetailResult?> showScrumTaskDetails(
  BuildContext context, {
  required ScrumTask task,
  List<ScrumActivity> activities = const [],
  List<ScrumTaskStatus> statuses = const [],
  String Function(ScrumTaskStatus status) statusLabelFor =
      defaultTaskDetailStatusLabel,
  int dueSoonDays = 2,
  int reviewAgeWarningDays = 3,
  DateTime? statusStartedAt,
  DateTime? now,
}) {
  return showDialog<ScrumTaskDetailResult>(
    context: context,
    builder: (context) => ScrumTaskDetailDialog(
      task: task,
      activities: activities,
      statuses: statuses,
      statusLabelFor: statusLabelFor,
      dueSoonDays: dueSoonDays,
      reviewAgeWarningDays: reviewAgeWarningDays,
      statusStartedAt: statusStartedAt,
      now: now,
    ),
  );
}

/// Default task status label used by task details when no formatter is given.
String defaultTaskDetailStatusLabel(ScrumTaskStatus status) => status.label;

/// Task detail side panel with header, content, activity, and footer actions.
class ScrumTaskDetailDialog extends StatelessWidget {
  const ScrumTaskDetailDialog({
    super.key,
    required this.task,
    required this.activities,
    required this.statuses,
    required this.statusLabelFor,
    required this.dueSoonDays,
    required this.reviewAgeWarningDays,
    this.statusStartedAt,
    this.now,
  });

  final ScrumTask task;
  final List<ScrumActivity> activities;
  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return TaskDetailPanelShell(
      header: ScrumTaskDetailHeader(
        task: task,
        onClose: () => Navigator.of(context).pop(),
      ),
      content: ScrumTaskDetailContent(
        task: task,
        activities: activities,
        statusLabelFor: statusLabelFor,
        dueSoonDays: dueSoonDays,
        reviewAgeWarningDays: reviewAgeWarningDays,
        statusStartedAt: statusStartedAt,
        now: now,
      ),
      actions: ScrumTaskDetailActions(
        task: task,
        statuses: statuses,
        statusLabelFor: statusLabelFor,
        onEdit: () =>
            Navigator.of(context).pop(const ScrumTaskDetailResult.edit()),
        onDelete: () =>
            Navigator.of(context).pop(const ScrumTaskDetailResult.delete()),
        onClose: () => Navigator.of(context).pop(),
        onMove: (status) =>
            Navigator.of(context).pop(ScrumTaskDetailResult.move(status)),
        onPriorityChanged: (priority) =>
            Navigator.of(context).pop(ScrumTaskDetailResult.priority(priority)),
        onNoteAdded: (note) =>
            Navigator.of(context).pop(ScrumTaskDetailResult.note(note)),
      ),
    );
  }
}

/// Preview for the task detail side panel.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail dialog',
  size: Size(920, 620),
)
Widget scrumTaskDetailDialogPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: ScrumTaskDetailDialog(
        task: ScrumTask(
          id: 'checkout',
          title: 'Checkout readiness review',
          description: 'Validate payment copy and final release signals.',
          assignee: 'Alya',
          storyPoints: 5,
          createdAt: DateTime(2026, 1, 1),
          status: ScrumTaskStatus.todo,
          priority: ScrumTaskPriority.high,
        ),
        statuses: const [
          ScrumTaskStatus.todo,
          ScrumTaskStatus.inProgress,
          ScrumTaskStatus.done,
        ],
        statusLabelFor: defaultTaskDetailStatusLabel,
        dueSoonDays: 2,
        reviewAgeWarningDays: 3,
        activities: [
          ScrumActivity(
            id: 'activity-1',
            type: ScrumActivityType.taskMoved,
            createdAt: DateTime(2026, 1, 2, 9),
            taskId: 'checkout',
            taskTitle: 'Checkout readiness review',
            toStatus: ScrumTaskStatus.todo,
          ),
        ],
      ),
    ),
  );
}
