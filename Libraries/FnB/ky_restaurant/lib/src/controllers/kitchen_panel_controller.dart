import 'controlled_panel_value.dart';
import '../models/kitchen_panel_data.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_models.dart';

/// Coordinates kitchen panel filter state and derived presentation data.
class RestaurantKitchenPanelController {
  RestaurantKitchenPanelController({
    RestaurantKitchenFilter initialFilter = RestaurantKitchenFilter.all,
    RestaurantKitchenFilter? selectedFilter,
    void Function(RestaurantKitchenFilter filter)? onFilterChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged;

  RestaurantKitchenFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantKitchenFilter> _selectedFilter;
  RestaurantKitchenFilter? _controlledFilter;
  void Function(RestaurantKitchenFilter filter)? _filterChanged;

  RestaurantKitchenFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  RestaurantKitchenPanelData dataFor(
    Iterable<RestaurantKitchenStation> stations, {
    String? focusedStationId,
  }) {
    return RestaurantKitchenPanelData.fromStations(
      stations: stations,
      selectedFilter: selectedFilter,
      focusedStationId: focusedStationId,
    );
  }

  bool updateConfiguration({
    required RestaurantKitchenFilter initialFilter,
    required RestaurantKitchenFilter? selectedFilter,
    void Function(RestaurantKitchenFilter filter)? onFilterChanged,
  }) {
    final changed = _selectedFilter.syncInitial(
      previousInitialValue: _initialFilter,
      initialValue: initialFilter,
    );

    _initialFilter = initialFilter;
    _controlledFilter = selectedFilter;
    _filterChanged = onFilterChanged;

    return changed;
  }

  bool selectFilter(RestaurantKitchenFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantKitchenFilter.all);
}
