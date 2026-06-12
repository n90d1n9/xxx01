import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Lane and priority dropdown fields for the task editor.
class TaskEditorWorkflowFields extends StatelessWidget {
  const TaskEditorWorkflowFields({
    super.key,
    required this.status,
    required this.priority,
    required this.statuses,
    required this.statusLabelFor,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  final ScrumTaskStatus status;
  final ScrumTaskPriority priority;
  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumTaskStatus> onStatusChanged;
  final ValueChanged<ScrumTaskPriority> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<ScrumTaskStatus>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Lane'),
            items: statuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(statusLabelFor(status)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onStatusChanged(value);
            },
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DropdownButtonFormField<ScrumTaskPriority>(
            initialValue: priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: ScrumTaskPriority.values
                .map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onPriorityChanged(value);
            },
          ),
        ),
      ],
    );
  }
}

/// Preview for lane and priority editor fields.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task editor workflow',
  size: Size(620, 110),
)
Widget taskEditorWorkflowFieldsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 560,
          child: TaskEditorWorkflowFields(
            status: ScrumTaskStatus.inProgress,
            priority: ScrumTaskPriority.high,
            statuses: const [
              ScrumTaskStatus.backlog,
              ScrumTaskStatus.todo,
              ScrumTaskStatus.inProgress,
              ScrumTaskStatus.review,
              ScrumTaskStatus.done,
            ],
            statusLabelFor: (status) => status.label,
            onStatusChanged: (_) {},
            onPriorityChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}
