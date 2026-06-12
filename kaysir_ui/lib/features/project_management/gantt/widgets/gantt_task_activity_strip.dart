import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_activity_time_service.dart';

class GanttTaskActivityStrip extends StatelessWidget {
  const GanttTaskActivityStrip({
    required this.activities,
    this.now,
    this.selectedTaskId,
    this.onActivitySelected,
    super.key,
  });

  final List<gantt.GanttTaskEditActivity> activities;
  final DateTime? now;
  final String? selectedTaskId;
  final ValueChanged<gantt.GanttTaskEditActivity>? onActivitySelected;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Edits',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final activity in activities) ...[
                _ActivityChip(
                  activity: activity,
                  now: now,
                  isSelected: activity.taskId == selectedTaskId,
                  onSelected:
                      onActivitySelected == null
                          ? null
                          : () => onActivitySelected!(activity),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.activity,
    required this.now,
    required this.isSelected,
    required this.onSelected,
  });

  final gantt.GanttTaskEditActivity activity;
  final DateTime? now;
  final bool isSelected;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _accentColorFor(context, activity.kind);
    final isInteractive = onSelected != null;
    final timeLabel = ganttActivityTimeLabel(activity.timestamp, now: now);

    final chip = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 172, maxWidth: 220),
      child: Material(
        color: accentColor.withValues(alpha: isSelected ? 0.14 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                isSelected
                    ? accentColor.withValues(alpha: 0.58)
                    : accentColor.withValues(alpha: 0.26),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelected,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_iconFor(activity.kind), size: 18, color: accentColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activity.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.taskTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.82,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.adjust_rounded,
                              size: 12,
                              color: accentColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: isInteractive,
      selected: isSelected,
      child:
          isInteractive
              ? Tooltip(message: 'Inspect ${activity.taskTitle}', child: chip)
              : chip,
    );
  }

  IconData _iconFor(gantt.GanttTaskEditKind kind) {
    switch (kind) {
      case gantt.GanttTaskEditKind.details:
        return Icons.edit_note_rounded;
      case gantt.GanttTaskEditKind.progress:
        return Icons.trending_up_rounded;
      case gantt.GanttTaskEditKind.taskType:
        return Icons.category_outlined;
      case gantt.GanttTaskEditKind.startDate:
      case gantt.GanttTaskEditKind.endDate:
      case gantt.GanttTaskEditKind.milestoneDate:
        return Icons.event_available_outlined;
      case gantt.GanttTaskEditKind.dependency:
        return Icons.link_rounded;
      case gantt.GanttTaskEditKind.undo:
        return Icons.undo_rounded;
    }
  }

  Color _accentColorFor(BuildContext context, gantt.GanttTaskEditKind kind) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (kind) {
      case gantt.GanttTaskEditKind.undo:
        return colorScheme.tertiary;
      case gantt.GanttTaskEditKind.dependency:
        return colorScheme.secondary;
      case gantt.GanttTaskEditKind.progress:
        return Colors.green.shade700;
      case gantt.GanttTaskEditKind.details:
      case gantt.GanttTaskEditKind.taskType:
      case gantt.GanttTaskEditKind.startDate:
      case gantt.GanttTaskEditKind.endDate:
      case gantt.GanttTaskEditKind.milestoneDate:
        return colorScheme.primary;
    }
  }
}
