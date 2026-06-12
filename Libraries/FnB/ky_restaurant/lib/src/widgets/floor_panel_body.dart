import 'package:flutter/material.dart';

import '../models/floor_panel_data.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_models.dart';
import 'filtered_panel_body.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_floor_filter_bar.dart';
import 'restaurant_floor_summary_strip.dart';
import 'restaurant_floor_zone_card.dart';
import 'restaurant_spaced_list.dart';

/// Builds the floor panel body from zone summary, filters, and visible zones.
class RestaurantFloorPanelBody extends StatelessWidget {
  const RestaurantFloorPanelBody({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onShowAll,
    this.onZoneStatusChanged,
    this.focusedZoneId,
  });

  final RestaurantFloorPanelData data;
  final ValueChanged<RestaurantFloorFilter> onFilterChanged;
  final VoidCallback onShowAll;
  final void Function(String zoneId, RestaurantServiceStatus status)?
  onZoneStatusChanged;
  final String? focusedZoneId;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasZones,
      hasVisibleItems: data.hasVisibleZones,
      emptyState: const RestaurantEmptyState(
        icon: Icons.table_restaurant_outlined,
        message: 'Floor zones will appear here during service.',
      ),
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantFloorSummaryStrip(summary: data.summary),
          const SizedBox(height: 14),
          RestaurantFloorFilterBar(
            zones: data.zones,
            selectedFilter: data.selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: Icons.table_restaurant_outlined,
        message:
            'No ${data.selectedFilter.label.toLowerCase()} floor zones right now.',
        actionLabel: 'Show all',
        onAction: onShowAll,
      ),
      results: _FloorZoneList(
        zones: data.visibleZones,
        onStatusChanged: onZoneStatusChanged,
        focusedZoneId: focusedZoneId,
      ),
    );
  }
}

/// Renders filtered floor zone cards with consistent vertical spacing.
class _FloorZoneList extends StatelessWidget {
  const _FloorZoneList({
    required this.zones,
    required this.onStatusChanged,
    this.focusedZoneId,
  });

  final List<RestaurantServiceZone> zones;
  final void Function(String zoneId, RestaurantServiceStatus status)?
  onStatusChanged;
  final String? focusedZoneId;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantServiceZone>(
      items: zones,
      itemBuilder: (context, zone, index) {
        return RestaurantFloorZoneCard(
          zone: zone,
          onStatusChanged: onStatusChanged,
          focused: zone.id == focusedZoneId,
        );
      },
    );
  }
}
