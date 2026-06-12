import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Drop zone displayed after the final task in a scrumboard lane.
class ScrumBoardEndDropZone extends StatelessWidget {
  const ScrumBoardEndDropZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ScrumBoardPalette.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Text(
        'Drop at end',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ScrumBoardPalette.mutedInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Summary body shown when a lane is collapsed.
class ScrumBoardCollapsedColumnBody extends StatelessWidget {
  const ScrumBoardCollapsedColumnBody({
    super.key,
    required this.color,
    required this.count,
    required this.storyPoints,
    required this.hiddenTaskCount,
    this.onClearFilters,
  });

  final Color color;
  final int count;
  final int storyPoints;
  final int hiddenTaskCount;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final filtered = hiddenTaskCount > 0 && onClearFilters != null;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_column_rounded, size: 24, color: color),
            const SizedBox(height: 10),
            Text(
              _taskCountText(count),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ScrumBoardPalette.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              _storyPointsText(storyPoints),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ScrumBoardPalette.mutedInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (filtered) ...[
              const SizedBox(height: 8),
              Text(
                _hiddenTaskText(hiddenTaskCount),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ScrumBoardPalette.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Show all tasks'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty body shown when a lane has no visible tasks.
class ScrumBoardEmptyColumn extends StatelessWidget {
  const ScrumBoardEmptyColumn({
    super.key,
    required this.color,
    required this.hiddenTaskCount,
    this.onClearFilters,
  });

  final Color color;
  final int hiddenTaskCount;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final filtered = hiddenTaskCount > 0 && onClearFilters != null;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.filter_alt_rounded : Icons.inbox_outlined,
              size: 22,
              color: filtered ? color : ScrumBoardPalette.mutedInk,
            ),
            const SizedBox(height: 8),
            Text(
              filtered ? 'No matching tasks' : 'No tasks',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ScrumBoardPalette.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (filtered) ...[
              const SizedBox(height: 4),
              Text(
                _hiddenTaskText(hiddenTaskCount),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ScrumBoardPalette.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Show all tasks'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preview for an empty filtered lane body.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Empty column body',
  size: Size(320, 180),
)
Widget scrumBoardEmptyColumnPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardEmptyColumn(
          color: const Color(0xFF2563EB),
          hiddenTaskCount: 3,
          onClearFilters: () {},
        ),
      ),
    ),
  );
}

/// Preview for a collapsed lane body.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Collapsed column body',
  size: Size(320, 220),
)
Widget scrumBoardCollapsedColumnPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 280,
          child: ScrumBoardCollapsedColumnBody(
            color: const Color(0xFF0891B2),
            count: 5,
            storyPoints: 18,
            hiddenTaskCount: 0,
            onClearFilters: () {},
          ),
        ),
      ),
    ),
  );
}

String _taskCountText(int count) {
  if (count == 1) return '1 task';
  return '$count tasks';
}

String _storyPointsText(int storyPoints) {
  if (storyPoints == 1) return '1 SP';
  return '$storyPoints SP';
}

String _hiddenTaskText(int count) {
  if (count == 1) return '1 task is hidden by filters.';
  return '$count tasks are hidden by filters.';
}
