import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Compact label badge used inside scrum task cards.
class ScrumTaskCardBadge extends StatelessWidget {
  const ScrumTaskCardBadge({
    super.key,
    required this.label,
    required this.color,
    this.tonal = false,
  });

  final String label;
  final Color color;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tonal ? color.withValues(alpha: .1) : color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tonal ? color : Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Preview for task-card badge treatments.
@Preview(group: 'Ky Scrumboard', name: 'Task card badges', size: Size(260, 90))
Widget scrumTaskCardBadgePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: Wrap(
          spacing: 8,
          children: [
            ScrumTaskCardBadge(label: 'Payments', color: Color(0xFF2563EB)),
            ScrumTaskCardBadge(
              label: '5 SP',
              color: Color(0xFFDC2626),
              tonal: true,
            ),
          ],
        ),
      ),
    ),
  );
}
