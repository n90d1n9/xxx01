import 'package:flutter/material.dart';

import '../../models/scrum_lane_health.dart';

class ScrumLaneHealthChips extends StatelessWidget {
  const ScrumLaneHealthChips({super.key, required this.health});

  final ScrumLaneHealth health;

  @override
  Widget build(BuildContext context) {
    if (!health.hasSignals) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (health.overdueTasks > 0)
          _LaneHealthChip(
            label: _countLabel(health.overdueTasks, 'overdue'),
            tooltip: _countLabel(
              health.overdueTasks,
              'overdue task',
              'overdue tasks',
            ),
            icon: Icons.warning_amber_rounded,
            color: const Color(0xFFDC2626),
          ),
        if (health.dueSoonTasks > 0)
          _LaneHealthChip(
            label: _countLabel(health.dueSoonTasks, 'due soon', 'due soon'),
            tooltip: _countLabel(
              health.dueSoonTasks,
              'task due soon',
              'tasks due soon',
            ),
            icon: Icons.schedule_rounded,
            color: const Color(0xFFD97706),
          ),
        if (health.agedReviewTasks > 0)
          _LaneHealthChip(
            label: _countLabel(health.agedReviewTasks, 'aging', 'aging'),
            tooltip: _countLabel(
              health.agedReviewTasks,
              'review task aging',
              'review tasks aging',
            ),
            icon: Icons.timelapse_rounded,
            color: const Color(0xFF7C3AED),
          ),
      ],
    );
  }
}

class _LaneHealthChip extends StatelessWidget {
  const _LaneHealthChip({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.color,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 132),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: .24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
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

String _countLabel(int count, String singularLabel, [String? pluralLabel]) {
  if (count == 1) return '1 $singularLabel';
  return '$count ${pluralLabel ?? '${singularLabel}s'}';
}
