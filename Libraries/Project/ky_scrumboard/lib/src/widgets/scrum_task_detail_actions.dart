import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_task_note_dialog.dart';
import 'task_detail_action_menus.dart';

/// Footer action row for editing, moving, annotating, and deleting a task.
class ScrumTaskDetailActions extends StatelessWidget {
  const ScrumTaskDetailActions({
    super.key,
    required this.task,
    required this.statuses,
    required this.statusLabelFor,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
    required this.onMove,
    required this.onPriorityChanged,
    required this.onNoteAdded,
  });

  final ScrumTask task;
  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  final ValueChanged<ScrumTaskStatus> onMove;
  final ValueChanged<ScrumTaskPriority> onPriorityChanged;
  final ValueChanged<String> onNoteAdded;

  Future<void> _captureNote(BuildContext context) async {
    final note = await showScrumTaskNoteDialog(context);
    if (note == null || !context.mounted) return;
    onNoteAdded(note);
  }

  @override
  Widget build(BuildContext context) {
    final moveStatuses = statuses
        .where((status) => status != task.status)
        .toList(growable: false);
    final priorities = ScrumTaskPriority.values
        .where((priority) => priority != task.priority)
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: [
          TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
            ),
          ),
          TextButton.icon(
            onPressed: () => _captureNote(context),
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Note'),
          ),
          TaskDetailPriorityMenu(
            priorities: priorities,
            onPriorityChanged: onPriorityChanged,
          ),
          if (moveStatuses.isNotEmpty)
            TaskDetailMoveMenu(
              statuses: moveStatuses,
              statusLabelFor: statusLabelFor,
              onMove: onMove,
            ),
          TextButton(onPressed: onClose, child: const Text('Close')),
          FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

/// Preview for the task detail action footer.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail actions',
  size: Size(620, 130),
)
Widget scrumTaskDetailActionsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumTaskDetailActions(
          task: ScrumTask(
            id: 'checkout',
            title: 'Checkout copy review',
            description: 'Review final checkout copy before release.',
            assignee: 'Alya',
            storyPoints: 3,
            createdAt: DateTime(2026, 1, 1),
            status: ScrumTaskStatus.todo,
            priority: ScrumTaskPriority.medium,
          ),
          statuses: const [
            ScrumTaskStatus.todo,
            ScrumTaskStatus.inProgress,
            ScrumTaskStatus.done,
          ],
          statusLabelFor: (status) => status.label,
          onEdit: () {},
          onDelete: () {},
          onClose: () {},
          onMove: (_) {},
          onPriorityChanged: (_) {},
          onNoteAdded: (_) {},
        ),
      ),
    ),
  );
}
