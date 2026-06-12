import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_move_preview.dart';
import '../../models/scrum_task_move_result.dart';
import '../../models/scrum_task_status.dart';
import 'move_preview_blocked_list.dart';
import 'move_preview_summary.dart';

/// Shows a confirmation dialog for selected task moves before applying them.
Future<bool> showScrumTaskMovePreview(
  BuildContext context, {
  required ScrumTaskMovePreview preview,
  required String Function(ScrumTaskStatus status) statusLabelFor,
  String Function(String taskId)? taskTitleFor,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ScrumTaskMovePreviewDialog(
      preview: preview,
      statusLabelFor: statusLabelFor,
      taskTitleFor: taskTitleFor,
    ),
  );
  return confirmed ?? false;
}

/// Confirmation dialog that summarizes movable and blocked bulk task moves.
class ScrumTaskMovePreviewDialog extends StatelessWidget {
  const ScrumTaskMovePreviewDialog({
    super.key,
    required this.preview,
    required this.statusLabelFor,
    this.taskTitleFor,
  });

  final ScrumTaskMovePreview preview;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final String Function(String taskId)? taskTitleFor;

  @override
  Widget build(BuildContext context) {
    final targetLabel = statusLabelFor(preview.toStatus);
    final blockedResults = preview.blockedResults.take(4).toList();

    return AlertDialog(
      icon: Icon(
        preview.hasBlocks
            ? Icons.warning_amber_rounded
            : Icons.swap_horiz_rounded,
        color: preview.hasBlocks
            ? const Color(0xFFD97706)
            : const Color(0xFF2563EB),
      ),
      title: const Text('Move selected tasks?'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MovePreviewSummary(
              targetLabel: targetLabel,
              changedCount: preview.changedCount,
              blockedCount: preview.blockedCount,
              unchangedCount: preview.unchangedCount,
            ),
            if (blockedResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              MovePreviewBlockedList(
                blockedResults: blockedResults,
                extraBlockedCount: preview.blockedCount - blockedResults.length,
                taskTitleFor: taskTitleFor,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: preview.canApply
              ? () => Navigator.of(context).pop(true)
              : null,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Apply move'),
        ),
      ],
    );
  }
}

/// Preview for a move confirmation dialog with workflow guardrails.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Move preview dialog',
  size: Size(560, 360),
)
Widget scrumTaskMovePreviewDialogPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      body: Center(
        child: ScrumTaskMovePreviewDialog(
          preview: ScrumTaskMovePreview(
            toStatus: ScrumTaskStatus.inProgress,
            results: const [
              ScrumTaskMoveResult(
                taskId: 'checkout',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.inProgress,
                accepted: true,
                changed: true,
                targetCount: 2,
                targetLimit: 3,
                message: 'Task moved.',
              ),
              ScrumTaskMoveResult(
                taskId: 'risk',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.inProgress,
                accepted: false,
                changed: false,
                blockReason: ScrumTaskMoveBlockReason.wipLimit,
                targetCount: 4,
                targetLimit: 3,
                message: 'In Progress is at its WIP limit of 3 tasks.',
              ),
            ],
          ),
          statusLabelFor: (status) => status.label,
          taskTitleFor: (taskId) => switch (taskId) {
            'checkout' => 'Checkout copy',
            'risk' => 'Risk review',
            _ => taskId,
          },
        ),
      ),
    ),
  );
}
