import 'package:flutter/material.dart';

import '../../models/scrum_task_age_state.dart';
import '../scrum_board_palette.dart';

class ScrumTaskAgeBadge extends StatelessWidget {
  const ScrumTaskAgeBadge({
    super.key,
    required this.ageState,
    required this.statusLabel,
  });

  final ScrumTaskAgeState ageState;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    if (!ageState.shouldRender) return const SizedBox.shrink();

    final color = ageState.isWarning
        ? const Color(0xFFD97706)
        : ScrumBoardPalette.mutedInk;

    return Tooltip(
      message: '$statusLabel for ${ageState.durationLabel}',
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
            Icon(Icons.timelapse_rounded, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                '$statusLabel ${ageState.durationLabel}',
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
