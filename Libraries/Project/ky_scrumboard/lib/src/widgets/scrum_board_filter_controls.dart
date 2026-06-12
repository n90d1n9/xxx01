import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_board_view_preset.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_sort.dart';
import '../scrum_board_palette.dart';
import 'scrum_board_assignee_filter_button.dart';
import 'scrum_board_priority_filters.dart';
import 'scrum_board_sort_button.dart';
import 'scrum_board_view_preset_button.dart';

/// Advanced toolbar controls for saved views, facets, assignees, and sorting.
class ScrumBoardFilterControls extends StatelessWidget {
  const ScrumBoardFilterControls({
    super.key,
    required this.filter,
    required this.viewPresets,
    required this.assignees,
    required this.showPriorityFilter,
    required this.showAssigneeFilter,
    required this.showSortControl,
    required this.showViewPresets,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final List<ScrumBoardViewPreset> viewPresets;
  final List<String> assignees;
  final bool showPriorityFilter;
  final bool showAssigneeFilter;
  final bool showSortControl;
  final bool showViewPresets;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (!showPriorityFilter &&
        !showAssigneeFilter &&
        !showSortControl &&
        !showViewPresets &&
        !filter.isActive) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (showViewPresets)
          ScrumBoardViewPresetButton(
            filter: filter,
            viewPresets: viewPresets,
            onFilterChanged: onFilterChanged,
          ),
        if (showPriorityFilter)
          ScrumBoardPriorityFilters(
            filter: filter,
            onFilterChanged: onFilterChanged,
          ),
        if (showAssigneeFilter)
          ScrumBoardAssigneeFilterButton(
            filter: filter,
            assignees: assignees,
            onFilterChanged: onFilterChanged,
          ),
        if (showSortControl)
          ScrumBoardSortButton(
            filter: filter,
            onFilterChanged: onFilterChanged,
          ),
        if (filter.isActive)
          TextButton.icon(
            onPressed: () => onFilterChanged(filter.clearAll()),
            icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
            label: const Text('Clear filters'),
          ),
      ],
    );
  }
}

/// Preview for the reusable advanced scrumboard filter controls.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Advanced filter controls',
  size: Size(920, 140),
)
Widget scrumBoardFilterControlsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardFilterControls(
          filter: const ScrumBoardFilter(
            priorities: {ScrumTaskPriority.critical},
            assignees: {'Alya'},
            sort: ScrumTaskSort.priority,
          ),
          viewPresets: defaultScrumBoardViewPresets,
          assignees: const ['Alya', 'Bima', 'Citra'],
          showPriorityFilter: true,
          showAssigneeFilter: true,
          showSortControl: true,
          showViewPresets: true,
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}
