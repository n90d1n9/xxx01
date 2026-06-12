import 'package:flutter/material.dart';

import '../models/restaurant_reservation_zone_load.dart';
import 'zone_load_card.dart';
import 'restaurant_adaptive_grid.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_section_header.dart';

/// Shows reservation pressure grouped by seating zone in a responsive grid.
class RestaurantReservationZoneLoadGrid extends StatelessWidget {
  const RestaurantReservationZoneLoadGrid({
    super.key,
    required this.loads,
    this.title = 'Zone load',
    this.selectedZoneLabel,
    this.onZoneSelected,
  });

  final List<RestaurantReservationZoneLoad> loads;
  final String title;
  final String? selectedZoneLabel;
  final ValueChanged<RestaurantReservationZoneLoad>? onZoneSelected;

  @override
  Widget build(BuildContext context) {
    if (loads.isEmpty) {
      return const RestaurantEmptyState(
        icon: Icons.table_restaurant_outlined,
        message: 'No active reservation load by zone.',
      );
    }

    return Semantics(
      container: true,
      label: _semanticLabel(title, loads),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RestaurantSectionHeader(
            icon: Icons.table_restaurant_outlined,
            title: title,
            trailingLabel:
                '${loads.length} active ${loads.length == 1 ? 'zone' : 'zones'}',
          ),
          const SizedBox(height: 10),
          RestaurantAdaptiveGrid(
            itemCount: loads.length,
            itemExtent: 170,
            wideBreakpoint: 960,
            mediumBreakpoint: 560,
            wideColumns: 3,
            mediumColumns: 2,
            itemBuilder: (context, index) {
              final load = loads[index];
              return RestaurantReservationZoneLoadCard(
                load: load,
                isSelected: _matchesZone(load.zoneLabel, selectedZoneLabel),
                onSelected: onZoneSelected == null
                    ? null
                    : () => onZoneSelected!(load),
              );
            },
          ),
        ],
      ),
    );
  }
}

bool _matchesZone(String zoneLabel, String? selectedZoneLabel) {
  if (selectedZoneLabel == null) return false;
  return zoneLabel.trim().toLowerCase() ==
      selectedZoneLabel.trim().toLowerCase();
}

String _semanticLabel(String title, List<RestaurantReservationZoneLoad> loads) {
  final loadLabels = loads.map(
    (load) =>
        '${load.zoneLabel}: ${load.bookingLabel}, ${load.coverLabel}, '
        '${load.pressureLabel}',
  );
  return '$title. ${loadLabels.join('. ')}.';
}
