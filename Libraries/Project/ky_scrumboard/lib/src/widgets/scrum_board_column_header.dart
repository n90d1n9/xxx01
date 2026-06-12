import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_lane_health.dart';
import '../scrum_board_palette.dart';
import 'board_lane_header_metrics.dart';
import 'scrum_lane_health_chips.dart';

/// Header for a scrumboard lane with selection, WIP, health, and actions.
class ScrumBoardColumnHeader extends StatelessWidget {
  const ScrumBoardColumnHeader({
    super.key,
    required this.statusLabel,
    required this.color,
    required this.count,
    required this.storyPoints,
    required this.health,
    required this.wipLimit,
    required this.overLimit,
    required this.guarded,
    required this.selectedCount,
    required this.canSelectTasks,
    required this.collapsed,
    required this.onAddTask,
    this.onToggleTaskSelection,
    this.onCollapsedChanged,
  });

  final String statusLabel;
  final Color color;
  final int count;
  final int storyPoints;
  final ScrumLaneHealth health;
  final int? wipLimit;
  final bool overLimit;
  final bool guarded;
  final int selectedCount;
  final bool canSelectTasks;
  final bool collapsed;
  final VoidCallback onAddTask;
  final VoidCallback? onToggleTaskSelection;
  final ValueChanged<bool>? onCollapsedChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasSelection = selectedCount > 0;
    final allSelected = count > 0 && selectedCount == count;
    final showCapacityMeter = wipLimit != null && wipLimit! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: ScrumBoardPalette.ink,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  BoardLaneMetaText(
                    count: count,
                    storyPoints: storyPoints,
                    wipLimit: wipLimit,
                    overLimit: overLimit,
                  ),
                ],
              ),
            ),
            if (guarded) ...[
              Tooltip(
                message: 'WIP limit enforced',
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: overLimit
                      ? const Color(0xFFDC2626)
                      : ScrumBoardPalette.mutedInk,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (canSelectTasks) ...[
              IconButton(
                tooltip: allSelected
                    ? 'Deselect $statusLabel tasks'
                    : 'Select $statusLabel tasks',
                visualDensity: VisualDensity.compact,
                onPressed: onToggleTaskSelection,
                icon: Icon(
                  allSelected
                      ? Icons.library_add_check_rounded
                      : hasSelection
                      ? Icons.indeterminate_check_box_rounded
                      : Icons.playlist_add_check_rounded,
                  color: hasSelection
                      ? const Color(0xFF2563EB)
                      : ScrumBoardPalette.mutedInk,
                ),
              ),
              const SizedBox(width: 4),
            ],
            IconButton(
              tooltip: collapsed
                  ? 'Expand $statusLabel'
                  : 'Collapse $statusLabel',
              visualDensity: VisualDensity.compact,
              onPressed: onCollapsedChanged == null
                  ? null
                  : () => onCollapsedChanged!(!collapsed),
              icon: Icon(
                collapsed
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                color: ScrumBoardPalette.mutedInk,
              ),
            ),
            const SizedBox(width: 4),
            IconButton.filledTonal(
              tooltip: 'Add task',
              onPressed: onAddTask,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (showCapacityMeter) ...[
          const SizedBox(height: 10),
          BoardLaneCapacityMeter(
            count: count,
            limit: wipLimit!,
            color: color,
            overLimit: overLimit,
          ),
        ],
        if (health.hasSignals) ...[
          const SizedBox(height: 8),
          ScrumLaneHealthChips(health: health),
        ],
      ],
    );
  }
}

/// Preview for the lane header with WIP and health signals.
@Preview(group: 'Ky Scrumboard', name: 'Column header', size: Size(360, 156))
Widget scrumBoardColumnHeaderPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ScrumBoardPalette.border),
          ),
          child: ScrumBoardColumnHeader(
            statusLabel: 'In Progress',
            color: const Color(0xFF2563EB),
            count: 4,
            storyPoints: 13,
            health: const ScrumLaneHealth(
              overdueTasks: 1,
              dueSoonTasks: 2,
              agedReviewTasks: 0,
            ),
            wipLimit: 5,
            overLimit: false,
            guarded: true,
            selectedCount: 1,
            canSelectTasks: true,
            collapsed: false,
            onAddTask: () {},
            onToggleTaskSelection: () {},
            onCollapsedChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}
