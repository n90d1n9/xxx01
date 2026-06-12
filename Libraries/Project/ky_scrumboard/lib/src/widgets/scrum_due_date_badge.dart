import 'package:flutter/material.dart';

import '../../models/scrum_task_due_state.dart';
import '../scrum_board_palette.dart';

class ScrumDueDateBadge extends StatelessWidget {
  const ScrumDueDateBadge({super.key, required this.dueState});

  final ScrumTaskDueState dueState;

  @override
  Widget build(BuildContext context) {
    if (!dueState.shouldRender) return const SizedBox.shrink();

    final color = _colorFor(dueState.status);
    final icon = _iconFor(dueState.status);

    return Tooltip(
      message: dueState.tooltip,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 124),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: .22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                dueState.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorFor(ScrumTaskDueStatus status) {
  switch (status) {
    case ScrumTaskDueStatus.none:
      return ScrumBoardPalette.mutedInk;
    case ScrumTaskDueStatus.planned:
      return ScrumBoardPalette.mutedInk;
    case ScrumTaskDueStatus.dueSoon:
      return const Color(0xFFD97706);
    case ScrumTaskDueStatus.overdue:
      return const Color(0xFFDC2626);
  }
}

IconData _iconFor(ScrumTaskDueStatus status) {
  switch (status) {
    case ScrumTaskDueStatus.none:
      return Icons.event_rounded;
    case ScrumTaskDueStatus.planned:
      return Icons.event_rounded;
    case ScrumTaskDueStatus.dueSoon:
      return Icons.schedule_rounded;
    case ScrumTaskDueStatus.overdue:
      return Icons.warning_amber_rounded;
  }
}
