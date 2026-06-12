import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_task_sort.dart';
import '../scrum_board_palette.dart';
import 'scrum_board_filter_surface.dart';

/// Popup button for choosing the visible task sort order.
class ScrumBoardSortButton extends StatelessWidget {
  const ScrumBoardSortButton({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScrumTaskSort>(
      tooltip: 'Sort tasks',
      onSelected: (sort) => onFilterChanged(filter.copyWith(sort: sort)),
      itemBuilder: (context) {
        return [
          for (final sort in ScrumTaskSort.values)
            CheckedPopupMenuItem<ScrumTaskSort>(
              value: sort,
              checked: filter.sort == sort,
              child: Row(
                children: [
                  Icon(_sortIcon(sort), size: 18),
                  const SizedBox(width: 8),
                  Text(sort.label),
                ],
              ),
            ),
        ];
      },
      child: ScrumBoardFilterSurface(
        enabled: true,
        selected: filter.hasCustomSort,
        icon: Icons.sort_rounded,
        label: filter.sort.label,
      ),
    );
  }
}

/// Preview for the scrumboard sort popup trigger.
@Preview(group: 'Ky Scrumboard', name: 'Sort button', size: Size(220, 90))
Widget scrumBoardSortButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardSortButton(
          filter: const ScrumBoardFilter(sort: ScrumTaskSort.priority),
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}

IconData _sortIcon(ScrumTaskSort sort) {
  switch (sort) {
    case ScrumTaskSort.laneOrder:
      return Icons.view_column_rounded;
    case ScrumTaskSort.priority:
      return Icons.priority_high_rounded;
    case ScrumTaskSort.dueDate:
      return Icons.event_rounded;
    case ScrumTaskSort.newest:
      return Icons.schedule_rounded;
    case ScrumTaskSort.storyPoints:
      return Icons.stacked_line_chart_rounded;
  }
}
