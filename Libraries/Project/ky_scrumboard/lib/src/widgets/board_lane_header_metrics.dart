import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../scrum_board_palette.dart';

/// Secondary task-count and estimate metadata under a board lane title.
class BoardLaneMetaText extends StatelessWidget {
  const BoardLaneMetaText({
    super.key,
    required this.count,
    required this.storyPoints,
    required this.wipLimit,
    required this.overLimit,
  });

  final int count;
  final int storyPoints;
  final int? wipLimit;
  final bool overLimit;

  @override
  Widget build(BuildContext context) {
    final limit = wipLimit;
    final taskText = limit == null ? '$count tasks' : '$count/$limit tasks';

    return Text(
      '$taskText · $storyPoints SP',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: overLimit ? const Color(0xFFDC2626) : ScrumBoardPalette.mutedInk,
        fontWeight: overLimit ? FontWeight.w800 : FontWeight.w500,
      ),
    );
  }
}

/// Preview for board lane metadata text.
@Preview(group: 'Ky Scrumboard', name: 'Lane metadata', size: Size(220, 80))
Widget boardLaneMetaTextPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: BoardLaneMetaText(
          count: 4,
          storyPoints: 13,
          wipLimit: 5,
          overLimit: false,
        ),
      ),
    ),
  );
}

/// Compact progress meter for a board lane WIP capacity limit.
class BoardLaneCapacityMeter extends StatelessWidget {
  const BoardLaneCapacityMeter({
    super.key,
    required this.count,
    required this.limit,
    required this.color,
    required this.overLimit,
  });

  final int count;
  final int limit;
  final Color color;
  final bool overLimit;

  @override
  Widget build(BuildContext context) {
    final fillColor = overLimit
        ? const Color(0xFFDC2626)
        : count >= limit
        ? const Color(0xFFD97706)
        : color;
    final progress = (count / limit).clamp(0, 1).toDouble();

    return Tooltip(
      message: 'WIP capacity: $count of $limit tasks',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 6,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: ScrumBoardPalette.border,
            color: fillColor,
          ),
        ),
      ),
    );
  }
}

/// Preview for the board lane WIP capacity meter.
@Preview(group: 'Ky Scrumboard', name: 'Lane capacity', size: Size(280, 80))
Widget boardLaneCapacityMeterPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 220,
          child: BoardLaneCapacityMeter(
            count: 4,
            limit: 5,
            color: Color(0xFF2563EB),
            overLimit: false,
          ),
        ),
      ),
    ),
  );
}
