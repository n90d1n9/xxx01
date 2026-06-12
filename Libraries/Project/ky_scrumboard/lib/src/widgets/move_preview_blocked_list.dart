import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_move_result.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Policy warning list for task moves that cannot be applied.
class MovePreviewBlockedList extends StatelessWidget {
  const MovePreviewBlockedList({
    super.key,
    required this.blockedResults,
    required this.extraBlockedCount,
    required this.taskTitleFor,
  });

  final List<ScrumTaskMoveResult> blockedResults;
  final int extraBlockedCount;
  final String Function(String taskId)? taskTitleFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: .2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blocked by workflow policy',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ScrumBoardPalette.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (final result in blockedResults)
            MovePreviewBlockedRow(result: result, taskTitleFor: taskTitleFor),
          if (extraBlockedCount > 0)
            Text(
              '+$extraBlockedCount more blocked',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ScrumBoardPalette.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

/// Preview for the blocked task move policy list.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Blocked move list',
  size: Size(440, 170),
)
Widget movePreviewBlockedListPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 380,
          child: MovePreviewBlockedList(
            blockedResults: [
              ScrumTaskMoveResult.blocked(
                taskId: 'risk',
                fromStatus: ScrumTaskStatus.todo,
                toStatus: ScrumTaskStatus.inProgress,
                reason: ScrumTaskMoveBlockReason.wipLimit,
                targetCount: 4,
                targetLimit: 3,
                message: 'In Progress is at its WIP limit of 3 tasks.',
              ),
            ],
            extraBlockedCount: 2,
            taskTitleFor: (taskId) => 'Risk review',
          ),
        ),
      ),
    ),
  );
}

/// Single blocked move row with the task title and policy reason.
class MovePreviewBlockedRow extends StatelessWidget {
  const MovePreviewBlockedRow({
    super.key,
    required this.result,
    required this.taskTitleFor,
  });

  final ScrumTaskMoveResult result;
  final String Function(String taskId)? taskTitleFor;

  @override
  Widget build(BuildContext context) {
    final title = taskTitleFor?.call(result.taskId) ?? result.taskId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.block_rounded, size: 16, color: Color(0xFFD97706)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: ${result.message}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ScrumBoardPalette.mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
