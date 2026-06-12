import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../scrum_board_palette.dart';
import 'scrum_board_filter_surface.dart';

/// Popup button for applying one or more assignee filters.
class ScrumBoardAssigneeFilterButton extends StatelessWidget {
  const ScrumBoardAssigneeFilterButton({
    super.key,
    required this.filter,
    required this.assignees,
    required this.onFilterChanged,
  });

  static const _clearAssigneesValue = '__clear_assignees__';

  final ScrumBoardFilter filter;
  final List<String> assignees;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final selectedCount = filter.assignees.length;
    final enabled = assignees.isNotEmpty || selectedCount > 0;

    return PopupMenuButton<String>(
      tooltip: 'Filter assignees',
      enabled: enabled,
      onSelected: (value) {
        if (value == _clearAssigneesValue) {
          onFilterChanged(filter.copyWith(assignees: const {}));
          return;
        }
        onFilterChanged(filter.toggleAssignee(value));
      },
      itemBuilder: (context) {
        if (assignees.isEmpty) {
          return [
            const PopupMenuItem<String>(
              enabled: false,
              child: Text('No assignees'),
            ),
          ];
        }

        return [
          if (filter.hasAssignees)
            const PopupMenuItem<String>(
              value: _clearAssigneesValue,
              child: Row(
                children: [
                  Icon(Icons.close_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Clear assignees'),
                ],
              ),
            ),
          for (final assignee in assignees)
            CheckedPopupMenuItem<String>(
              value: assignee,
              checked: filter.assignees.contains(assignee),
              child: Text(assignee),
            ),
        ];
      },
      child: ScrumBoardFilterSurface(
        enabled: enabled,
        selected: selectedCount > 0,
        icon: Icons.group_outlined,
        label: selectedCount == 0 ? 'Assignee' : '$selectedCount assignees',
      ),
    );
  }
}

/// Preview for the assignee filter popup trigger.
@Preview(group: 'Ky Scrumboard', name: 'Assignee filter', size: Size(240, 90))
Widget scrumBoardAssigneeFilterButtonPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBoardAssigneeFilterButton(
          filter: const ScrumBoardFilter(assignees: {'Alya'}),
          assignees: const ['Alya', 'Bima', 'Citra'],
          onFilterChanged: (_) {},
        ),
      ),
    ),
  );
}
