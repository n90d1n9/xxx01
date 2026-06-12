import 'package:flutter/material.dart';

import '../controllers/activity_panel_controller.dart';
import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_operation_activity.dart';
import 'activity_panel_body.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';

/// Shows recent operating activity with filter controls for each restaurant workflow.
class RestaurantActivityPanel extends StatefulWidget {
  const RestaurantActivityPanel({
    super.key,
    required this.activities,
    this.visibleCount = 5,
    this.initialFilter = RestaurantActivityFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
  });

  final List<RestaurantOperationActivity> activities;
  final int visibleCount;
  final RestaurantActivityFilter initialFilter;
  final RestaurantActivityFilter? selectedFilter;
  final ValueChanged<RestaurantActivityFilter>? onFilterChanged;

  @override
  State<RestaurantActivityPanel> createState() =>
      _RestaurantActivityPanelState();
}

class _RestaurantActivityPanelState extends State<RestaurantActivityPanel> {
  late final RestaurantActivityPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantActivityPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantActivityPanel oldWidget) {
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
      activities: widget.activities,
      visibleCount: widget.visibleCount,
    );

    return RestaurantPanel(
      title: 'Recent actions',
      subtitle: 'Operational changes captured during this shift.',
      leading: const Icon(Icons.timeline_rounded),
      headerBadges: RestaurantPanelHeaderBadges.activity(
        totalCount: data.totalCount,
        visibleCount: data.shownCount,
      ),
      child: RestaurantActivityPanelBody(
        data: data,
        onFilterChanged: _selectFilter,
        onShowAll: _showAll,
      ),
    );
  }

  void _selectFilter(RestaurantActivityFilter filter) {
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
