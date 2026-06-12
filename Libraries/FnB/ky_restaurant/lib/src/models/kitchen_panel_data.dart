import 'focused_visible_items.dart';
import 'restaurant_kitchen_filter.dart';
import 'restaurant_kitchen_summary.dart';
import 'restaurant_models.dart';

/// Derives filtered kitchen-station presentation state for the kitchen panel.
class RestaurantKitchenPanelData {
  const RestaurantKitchenPanelData._({
    required this.stations,
    required this.selectedFilter,
    required this.visibleStations,
    required this.summary,
    required this.pressureSignal,
  });

  factory RestaurantKitchenPanelData.fromStations({
    required Iterable<RestaurantKitchenStation> stations,
    required RestaurantKitchenFilter selectedFilter,
    String? focusedStationId,
  }) {
    final items = stations.toList(growable: false);
    final filteredStations = items
        .where(selectedFilter.includes)
        .toList(growable: false);
    final visibleStations = restaurantVisibleItemsWithFocus(
      visibleItems: filteredStations,
      sourceItems: items,
      focusedId: focusedStationId,
      idOf: (station) => station.id,
    );

    return RestaurantKitchenPanelData._(
      stations: items,
      selectedFilter: selectedFilter,
      visibleStations: visibleStations,
      summary: RestaurantKitchenSummary.fromStations(items),
      pressureSignal: RestaurantKitchenPressureSignal.fromStations(items),
    );
  }

  final List<RestaurantKitchenStation> stations;
  final RestaurantKitchenFilter selectedFilter;
  final List<RestaurantKitchenStation> visibleStations;
  final RestaurantKitchenSummary summary;
  final RestaurantKitchenPressureSignal pressureSignal;

  bool get hasStations => stations.isNotEmpty;

  bool get hasVisibleStations => visibleStations.isNotEmpty;
}
