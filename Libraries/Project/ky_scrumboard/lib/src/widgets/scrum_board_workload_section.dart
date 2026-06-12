import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_assignee_load.dart';
import '../scrum_board_palette.dart';

/// Workload section that compares active story points by assignee.
class ScrumBoardWorkloadSection extends StatelessWidget {
  const ScrumBoardWorkloadSection({
    super.key,
    required this.assigneeLoads,
    this.maxVisibleAssignees = 4,
  });

  final List<ScrumAssigneeLoad> assigneeLoads;
  final int maxVisibleAssignees;

  @override
  Widget build(BuildContext context) {
    if (assigneeLoads.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final maxStoryPoints = _maxStoryPoints(assigneeLoads);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Workload',
          style: textTheme.labelLarge?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        for (final load in assigneeLoads.take(maxVisibleAssignees)) ...[
          _ScrumAssigneeLoadRow(load: load, maxStoryPoints: maxStoryPoints),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

/// Preview for assignee workload distribution.
@Preview(group: 'Ky Scrumboard', name: 'Workload section', size: Size(360, 220))
Widget scrumBoardWorkloadSectionPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 320,
          child: ScrumBoardWorkloadSection(
            assigneeLoads: [
              ScrumAssigneeLoad(
                assignee: 'Alya',
                activeTasks: 3,
                activeStoryPoints: 13,
                criticalTasks: 1,
              ),
              ScrumAssigneeLoad(
                assignee: 'Bima',
                activeTasks: 2,
                activeStoryPoints: 8,
                criticalTasks: 0,
              ),
              ScrumAssigneeLoad(
                assignee: 'Citra',
                activeTasks: 1,
                activeStoryPoints: 5,
                criticalTasks: 0,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Single workload row for one assignee.
class _ScrumAssigneeLoadRow extends StatelessWidget {
  const _ScrumAssigneeLoadRow({
    required this.load,
    required this.maxStoryPoints,
  });

  final ScrumAssigneeLoad load;
  final int maxStoryPoints;

  @override
  Widget build(BuildContext context) {
    final ratio = maxStoryPoints == 0
        ? 0.0
        : load.activeStoryPoints / maxStoryPoints;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                load.assignee,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ScrumBoardPalette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${load.activeStoryPoints} SP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: load.criticalTasks > 0
                    ? const Color(0xFFDC2626)
                    : ScrumBoardPalette.mutedInk,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 7,
            backgroundColor: ScrumBoardPalette.border,
            color: load.criticalTasks > 0
                ? const Color(0xFFDC2626)
                : const Color(0xFF0891B2),
          ),
        ),
      ],
    );
  }
}

int _maxStoryPoints(List<ScrumAssigneeLoad> loads) {
  if (loads.isEmpty) return 0;
  return loads.fold<int>(
    0,
    (maxValue, load) => math.max(maxValue, load.activeStoryPoints),
  );
}
