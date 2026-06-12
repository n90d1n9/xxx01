import 'package:flutter/material.dart';

import '../controllers/task_panel_controller.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_task_filter.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';
import 'task_panel_body.dart';

/// Shows shift follow-up progress with filter controls and task completion actions.
class RestaurantTaskPanel extends StatefulWidget {
  const RestaurantTaskPanel({
    super.key,
    required this.tasks,
    this.onCompleteTask,
    this.initialFilter = RestaurantTaskFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
    this.focusedTaskId,
  });

  final List<RestaurantShiftTask> tasks;
  final ValueChanged<String>? onCompleteTask;
  final RestaurantTaskFilter initialFilter;
  final RestaurantTaskFilter? selectedFilter;
  final ValueChanged<RestaurantTaskFilter>? onFilterChanged;
  final String? focusedTaskId;

  @override
  State<RestaurantTaskPanel> createState() => _RestaurantTaskPanelState();
}

class _RestaurantTaskPanelState extends State<RestaurantTaskPanel> {
  late final RestaurantTaskPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantTaskPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantTaskPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateConfiguration(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _controller.dataFor(
      widget.tasks,
      focusedTaskId: widget.focusedTaskId,
    );

    return RestaurantPanel(
      title: 'Shift follow-up',
      subtitle: 'Work that keeps the next service wave clean.',
      leading: const Icon(Icons.task_alt_outlined),
      headerBadges: RestaurantPanelHeaderBadges.task(data.summary),
      child: RestaurantTaskPanelBody(
        data: data,
        onFilterChanged: _selectFilter,
        onShowAll: _showAll,
        onCompleteTask: widget.onCompleteTask,
        focusedTaskId: widget.focusedTaskId,
      ),
    );
  }

  void _selectFilter(RestaurantTaskFilter filter) {
    _refreshWhenLocalStateChanges(() => _controller.selectFilter(filter));
  }

  void _showAll() {
    _refreshWhenLocalStateChanges(_controller.showAll);
  }

  void _refreshWhenLocalStateChanges(bool Function() update) {
    if (update()) {
      setState(() {});
    }
  }
}
