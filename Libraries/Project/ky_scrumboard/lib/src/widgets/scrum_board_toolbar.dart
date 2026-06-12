import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_board_filter.dart';
import '../../models/scrum_board_view_preset.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'scrum_board_filter_controls.dart';
import 'scrum_board_search_field.dart';
import 'scrum_board_status_filters.dart';

/// Responsive toolbar that composes search, lane filters, and board controls.
class ScrumBoardToolbar extends StatefulWidget {
  const ScrumBoardToolbar({
    super.key,
    required this.filter,
    required this.statuses,
    required this.statusCounts,
    required this.viewPresets,
    required this.assignees,
    required this.showPriorityFilter,
    required this.showAssigneeFilter,
    required this.showSortControl,
    required this.showViewPresets,
    required this.statusLabelFor,
    required this.onFilterChanged,
  });

  final ScrumBoardFilter filter;
  final List<ScrumTaskStatus> statuses;
  final Map<ScrumTaskStatus, int> statusCounts;
  final List<ScrumBoardViewPreset> viewPresets;
  final List<String> assignees;
  final bool showPriorityFilter;
  final bool showAssigneeFilter;
  final bool showSortControl;
  final bool showViewPresets;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumBoardFilter> onFilterChanged;

  @override
  State<ScrumBoardToolbar> createState() => _ScrumBoardToolbarState();
}

class _ScrumBoardToolbarState extends State<ScrumBoardToolbar> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.filter.query);
  }

  @override
  void didUpdateWidget(covariant ScrumBoardToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter.query != widget.filter.query &&
        _queryController.text != widget.filter.query) {
      _queryController
        ..text = widget.filter.query
        ..selection = TextSelection.collapsed(
          offset: widget.filter.query.length,
        );
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 960;
          final search = ScrumBoardSearchField(
            width: compact ? double.infinity : 320,
            controller: _queryController,
            onChanged: (value) {
              widget.onFilterChanged(widget.filter.copyWith(query: value));
            },
          );

          final filters = ScrumBoardStatusFilters(
            statuses: widget.statuses,
            statusCounts: widget.statusCounts,
            selectedStatus: widget.filter.status,
            statusLabelFor: widget.statusLabelFor,
            onStatusChanged: (status) {
              widget.onFilterChanged(widget.filter.withStatus(status));
            },
          );
          final advancedFilters = ScrumBoardFilterControls(
            filter: widget.filter,
            viewPresets: widget.viewPresets,
            assignees: widget.assignees,
            showPriorityFilter: widget.showPriorityFilter,
            showAssigneeFilter: widget.showAssigneeFilter,
            showSortControl: widget.showSortControl,
            showViewPresets: widget.showViewPresets,
            onFilterChanged: widget.onFilterChanged,
          );
          final filterStack = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [filters, const SizedBox(height: 10), advancedFilters],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [search, const SizedBox(height: 12), filterStack],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              search,
              const SizedBox(width: 16),
              Expanded(child: filterStack),
            ],
          );
        },
      ),
    );
  }
}

/// Preview for the composed desktop scrumboard toolbar.
@Preview(group: 'Ky Scrumboard', name: 'Board toolbar', size: Size(1180, 180))
Widget scrumBoardToolbarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: ScrumBoardToolbar(
        filter: const ScrumBoardFilter(),
        statuses: const [
          ScrumTaskStatus.backlog,
          ScrumTaskStatus.todo,
          ScrumTaskStatus.inProgress,
          ScrumTaskStatus.review,
          ScrumTaskStatus.done,
        ],
        statusCounts: const {
          ScrumTaskStatus.backlog: 4,
          ScrumTaskStatus.todo: 8,
          ScrumTaskStatus.inProgress: 3,
          ScrumTaskStatus.review: 2,
          ScrumTaskStatus.done: 12,
        },
        viewPresets: defaultScrumBoardViewPresets,
        assignees: const ['Alya', 'Bima', 'Citra'],
        showPriorityFilter: true,
        showAssigneeFilter: true,
        showSortControl: true,
        showViewPresets: true,
        statusLabelFor: (status) => status.label,
        onFilterChanged: (_) {},
      ),
    ),
  );
}
