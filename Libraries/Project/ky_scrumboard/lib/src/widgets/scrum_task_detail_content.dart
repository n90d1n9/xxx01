import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_activity.dart';
import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_activity_timeline_section.dart';
import 'task_detail_metadata_section.dart';
import 'task_detail_summary_section.dart';

/// Body content for the task detail panel.
class ScrumTaskDetailContent extends StatelessWidget {
  const ScrumTaskDetailContent({
    super.key,
    required this.task,
    required this.activities,
    required this.statusLabelFor,
    required this.dueSoonDays,
    required this.reviewAgeWarningDays,
    this.statusStartedAt,
    this.now,
  });

  final ScrumTask task;
  final List<ScrumActivity> activities;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final int dueSoonDays;
  final int reviewAgeWarningDays;
  final DateTime? statusStartedAt;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskDetailSummaryPills(task: task, statusLabelFor: statusLabelFor),
        TaskDetailSignalSection(
          task: task,
          dueSoonDays: dueSoonDays,
          reviewAgeWarningDays: reviewAgeWarningDays,
          statusStartedAt: statusStartedAt,
          statusLabel: statusLabelFor(task.status),
          now: now,
        ),
        const SizedBox(height: 18),
        TaskDetailDescriptionSection(description: task.description),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 14),
        TaskDetailMetadataSection(task: task),
        if (activities.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 14),
          ScrumActivityTimelineSection(
            title: 'Activity',
            activities: activities,
            statusLabelFor: statusLabelFor,
          ),
        ],
      ],
    );
  }
}

/// Preview for the complete task detail content body.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail content',
  size: Size(420, 520),
)
Widget scrumTaskDetailContentPreview() {
  final createdAt = DateTime(2026, 1, 1);

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 360,
          child: ScrumTaskDetailContent(
            task: ScrumTask(
              id: 'content',
              title: 'Content task',
              description: 'Validate detail content composition.',
              assignee: 'Alya',
              storyPoints: 5,
              createdAt: createdAt,
              dueAt: DateTime(2026, 1, 10),
              status: ScrumTaskStatus.review,
              priority: ScrumTaskPriority.high,
            ),
            activities: [
              ScrumActivity(
                id: 'activity',
                type: ScrumActivityType.taskMoved,
                createdAt: DateTime(2026, 1, 2, 9),
                taskId: 'content',
                taskTitle: 'Content task',
                toStatus: ScrumTaskStatus.review,
              ),
            ],
            statusLabelFor: (status) => status.label,
            dueSoonDays: 2,
            reviewAgeWarningDays: 3,
            statusStartedAt: createdAt,
            now: DateTime(2026, 1, 10),
          ),
        ),
      ),
    ),
  );
}
