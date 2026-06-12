import 'package:flutter/material.dart';

Future<bool> showScrumTaskDeleteConfirmation(
  BuildContext context, {
  required int taskCount,
  String? taskTitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ScrumTaskDeleteConfirmationDialog(
      taskCount: taskCount,
      taskTitle: taskTitle,
    ),
  );
  return confirmed ?? false;
}

class ScrumTaskDeleteConfirmationDialog extends StatelessWidget {
  const ScrumTaskDeleteConfirmationDialog({
    super.key,
    required this.taskCount,
    this.taskTitle,
  });

  final int taskCount;
  final String? taskTitle;

  @override
  Widget build(BuildContext context) {
    final count = taskCount < 1 ? 1 : taskCount;
    final singleTask = count == 1;
    final title = singleTask ? 'Delete task?' : 'Delete selected tasks?';
    final objectLabel = singleTask ? 'task' : '$count tasks';
    final taskName = taskTitle?.trim();
    final content = taskName == null || taskName.isEmpty
        ? 'This will permanently remove $objectLabel from the board.'
        : 'This will permanently remove "$taskName" from the board.';

    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}
