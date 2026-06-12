import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_task_priority.dart';
import '../scrum_board_palette.dart';

/// Priority chip collection for scrumboard toolbar filtering.
class ScrumBoardPriorityFilters extends StatelessWidget {
  const ScrumBoardPriorityFilters({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final priority in ScrumTaskPriority.values)
          _ScrumBoardPriorityFilterChip(
            priority: priority,
            selected: filter.priorities.contains(priority),
            onSelected: () => onFilterChanged(filter.togglePriority(priority)),
          ),
      ],
    );
  }
}

/// Preview for priority facet chips.
@Preview(group: 'Ky Scrumboard', name: 'Priority filters', size: Size(620, 96))
Widget scrumBoardPriorityFiltersPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardPriorityFilters(
          filter: const ScrumBoardFilter(
            priorities: {ScrumTaskPriority.critical},
          ),
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}

/// Single priority facet chip with color and priority iconography.
class _ScrumBoardPriorityFilterChip extends StatelessWidget {
  const _ScrumBoardPriorityFilterChip({
    required this.priority,
    required this.selected,
    required this.onSelected,
  });

  final ScrumTaskPriority priority;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final color = ScrumBoardPalette.priorityColor(priority);

    return FilterChip(
      label: Text(priority.label),
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: Icon(_priorityIcon(priority), size: 16, color: color),
      selectedColor: color.withValues(alpha: .12),
      checkmarkColor: color,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? color : ScrumBoardPalette.ink,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

IconData _priorityIcon(ScrumTaskPriority priority) {
  switch (priority) {
    case ScrumTaskPriority.low:
      return Icons.keyboard_arrow_down_rounded;
    case ScrumTaskPriority.medium:
      return Icons.drag_handle_rounded;
    case ScrumTaskPriority.high:
      return Icons.keyboard_arrow_up_rounded;
    case ScrumTaskPriority.critical:
      return Icons.priority_high_rounded;
  }
}
