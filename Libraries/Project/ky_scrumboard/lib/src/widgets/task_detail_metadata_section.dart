import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_task_detail_common.dart';

/// Description block for the task detail panel.
class TaskDetailDescriptionSection extends StatelessWidget {
  const TaskDetailDescriptionSection({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: ScrumBoardPalette.mutedInk),
        ),
      ],
    );
  }
}

/// Ownership and schedule metadata for the task detail panel.
class TaskDetailMetadataSection extends StatelessWidget {
  const TaskDetailMetadataSection({super.key, required this.task});

  final ScrumTask task;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ScrumTaskDetailAvatar(name: task.assignee, color: task.accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: ScrumTaskDetailValue(
                label: 'Assignee',
                value: task.assignee,
              ),
            ),
            ScrumTaskDetailValue(
              label: 'Created',
              value: _shortDate(task.createdAt),
              alignEnd: true,
            ),
          ],
        ),
        if (task.dueAt != null) ...[
          const SizedBox(height: 14),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ScrumTaskDetailValue(
              label: 'Due date',
              value: _shortDate(task.dueAt!),
            ),
          ),
        ],
      ],
    );
  }
}

/// Preview for task detail description and metadata sections.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail metadata',
  size: Size(420, 220),
)
Widget taskDetailMetadataSectionPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TaskDetailDescriptionSection(
                description: 'Validate payment copy and release ownership.',
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 14),
              TaskDetailMetadataSection(
                task: ScrumTask(
                  id: 'metadata',
                  title: 'Metadata task',
                  description: 'Metadata preview.',
                  assignee: 'Alya Ramadhani',
                  storyPoints: 5,
                  createdAt: DateTime(2026, 1, 1),
                  dueAt: DateTime(2026, 1, 14),
                  status: ScrumTaskStatus.todo,
                  accentColor: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _shortDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
