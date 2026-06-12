import 'focused_visible_items.dart';
import 'restaurant_floor_filter.dart';
import 'restaurant_floor_summary.dart';
import 'restaurant_models.dart';

/// Derives filtered floor-zone presentation state for the floor panel.
class RestaurantFloorPanelData {
  const RestaurantFloorPanelData._({
    required this.zones,
    required this.selectedFilter,
    required this.visibleZones,
    required this.summary,
  });

  factory RestaurantFloorPanelData.fromZones({
    required Iterable<RestaurantServiceZone> zones,
    required RestaurantFloorFilter selectedFilter,
    String? focusedZoneId,
  }) {
    final items = zones.toList(growable: false);
    final filteredZones = items
        .where(selectedFilter.includes)
        .toList(growable: false);
    final visibleZones = restaurantVisibleItemsWithFocus(
      visibleItems: filteredZones,
      sourceItems: items,
      focusedId: focusedZoneId,
      idOf: (zone) => zone.id,
    );

    return RestaurantFloorPanelData._(
      zones: items,
      selectedFilter: selectedFilter,
      visibleZones: visibleZones,
      summary: RestaurantFloorSummary.fromZones(items),
    );
  }

  final List<RestaurantServiceZone> zones;
  final RestaurantFloorFilter selectedFilter;
  final List<RestaurantServiceZone> visibleZones;
  final RestaurantFloorSummary summary;

  bool get hasZones => zones.isNotEmpty;

  bool get hasVisibleZones => visibleZones.isNotEmpty;
}
