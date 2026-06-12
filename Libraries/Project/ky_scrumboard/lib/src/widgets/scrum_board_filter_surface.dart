import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Shared compact surface used by scrumboard toolbar popup controls.
class ScrumBoardFilterSurface extends StatelessWidget {
  const ScrumBoardFilterSurface({
    super.key,
    required this.enabled,
    required this.selected,
    required this.icon,
    required this.label,
  });

  final bool enabled;
  final bool selected;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2563EB) : ScrumBoardPalette.ink;

    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB).withValues(alpha: .08)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB).withValues(alpha: .28)
                : ScrumBoardPalette.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// Preview for the selected toolbar popup surface.
@Preview(group: 'Ky Scrumboard', name: 'Filter surface', size: Size(220, 90))
Widget scrumBoardFilterSurfacePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardFilterSurface(
          enabled: true,
          selected: true,
          icon: Icons.sort_rounded,
          label: 'Priority',
        ),
      ),
    ),
  );
}
