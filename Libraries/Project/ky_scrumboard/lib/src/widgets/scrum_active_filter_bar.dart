import 'package:flutter/material.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_sort.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

class ScrumActiveFilterBar extends StatelessWidget {
  const ScrumActiveFilterBar({
    super.key,
    required this.filter,
    required this.statusLabelFor,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (!filter.isActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.filter_alt_rounded,
              size: 20,
              color: ScrumBoardPalette.mutedInk,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (filter.hasQuery)
                  _ActiveFilterChip(
                    label: 'Search: ${filter.query.trim()}',
                    icon: Icons.search_rounded,
                    tooltip: 'Remove search filter',
                    onDeleted: () => onFilterChanged(filter.clearQuery()),
                  ),
                if (filter.status != null)
                  _ActiveFilterChip(
                    label: statusLabelFor(filter.status!),
                    icon: Icons.view_column_rounded,
                    tooltip: 'Remove status filter',
                    onDeleted: () => onFilterChanged(filter.withStatus(null)),
                  ),
                for (final priority in filter.priorities)
                  _ActiveFilterChip(
                    label: priority.label,
                    icon: Icons.flag_rounded,
                    tooltip: 'Remove ${priority.label} priority filter',
                    onDeleted: () =>
                        onFilterChanged(filter.withoutPriority(priority)),
                  ),
                for (final assignee in filter.assignees)
                  _ActiveFilterChip(
                    label: assignee,
                    icon: Icons.person_outline_rounded,
                    tooltip: 'Remove $assignee assignee filter',
                    onDeleted: () =>
                        onFilterChanged(filter.withoutAssignee(assignee)),
                  ),
                if (filter.hasCustomSort)
                  _ActiveFilterChip(
                    label: filter.sort.label,
                    icon: Icons.sort_rounded,
                    tooltip: 'Remove sort filter',
                    onDeleted: () => onFilterChanged(filter.clearSort()),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            tooltip: 'Clear filters',
            visualDensity: VisualDensity.compact,
            onPressed: () => onFilterChanged(filter.clearAll()),
            icon: const Icon(Icons.filter_alt_off_rounded),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.icon,
    required this.tooltip,
    required this.onDeleted,
  });

  final String label;
  final IconData icon;
  final String tooltip;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFF2563EB)),
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 180),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: tooltip,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      backgroundColor: const Color(0xFF2563EB).withValues(alpha: .08),
      side: BorderSide(color: const Color(0xFF2563EB).withValues(alpha: .22)),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: const Color(0xFF2563EB),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
