import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Compact summary for the task move preview dialog.
class MovePreviewSummary extends StatelessWidget {
  const MovePreviewSummary({
    super.key,
    required this.targetLabel,
    required this.changedCount,
    required this.blockedCount,
    required this.unchangedCount,
  });

  final String targetLabel;
  final int changedCount;
  final int blockedCount;
  final int unchangedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$changedCount ${_taskWord(changedCount)} will move to $targetLabel.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MovePreviewPill(
              label: '$changedCount movable',
              color: const Color(0xFF16A34A),
            ),
            if (blockedCount > 0)
              MovePreviewPill(
                label: '$blockedCount blocked',
                color: const Color(0xFFD97706),
              ),
            if (unchangedCount > 0)
              MovePreviewPill(
                label: '$unchangedCount already there',
                color: ScrumBoardPalette.mutedInk,
              ),
          ],
        ),
      ],
    );
  }
}

/// Preview for the task move summary block.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Move preview summary',
  size: Size(440, 130),
)
Widget movePreviewSummaryPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 360,
          child: MovePreviewSummary(
            targetLabel: 'In Progress',
            changedCount: 2,
            blockedCount: 1,
            unchangedCount: 1,
          ),
        ),
      ),
    ),
  );
}

/// Small status pill used by move preview summaries.
class MovePreviewPill extends StatelessWidget {
  const MovePreviewPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String _taskWord(int count) => count == 1 ? 'task' : 'tasks';
