import 'package:flutter/material.dart';

import '../controllers/floor_panel_controller.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_models.dart';
import 'floor_panel_body.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';

/// Shows floor readiness, section pressure, waitlists, and table turns.
class RestaurantFloorPanel extends StatefulWidget {
  const RestaurantFloorPanel({
    super.key,
    required this.zones,
    this.onZoneStatusChanged,
    this.initialFilter = RestaurantFloorFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
    this.focusedZoneId,
  });

  final List<RestaurantServiceZone> zones;
  final void Function(String zoneId, RestaurantServiceStatus status)?
  onZoneStatusChanged;
  final RestaurantFloorFilter initialFilter;
  final RestaurantFloorFilter? selectedFilter;
  final ValueChanged<RestaurantFloorFilter>? onFilterChanged;
  final String? focusedZoneId;

  @override
  State<RestaurantFloorPanel> createState() => _RestaurantFloorPanelState();
}

class _RestaurantFloorPanelState extends State<RestaurantFloorPanel> {
  late final RestaurantFloorPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantFloorPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantFloorPanel oldWidget) {
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
      widget.zones,
      focusedZoneId: widget.focusedZoneId,
    );

    return RestaurantPanel(
      title: 'Floor plan readiness',
      subtitle: 'Section load, waitlist pressure, and table turns.',
      leading: const Icon(Icons.table_restaurant_outlined),
      headerBadges: RestaurantPanelHeaderBadges.floor(data.summary),
      child: RestaurantFloorPanelBody(
        data: data,
        onFilterChanged: _selectFilter,
        onShowAll: _showAll,
        onZoneStatusChanged: widget.onZoneStatusChanged,
        focusedZoneId: widget.focusedZoneId,
      ),
    );
  }

  void _selectFilter(RestaurantFloorFilter filter) {
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
