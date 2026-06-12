import 'controlled_panel_value.dart';
import '../models/floor_panel_data.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_models.dart';

/// Coordinates floor panel filter state and derived presentation data.
class RestaurantFloorPanelController {
  RestaurantFloorPanelController({
    RestaurantFloorFilter initialFilter = RestaurantFloorFilter.all,
    RestaurantFloorFilter? selectedFilter,
    void Function(RestaurantFloorFilter filter)? onFilterChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged;

  RestaurantFloorFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantFloorFilter> _selectedFilter;
  RestaurantFloorFilter? _controlledFilter;
  void Function(RestaurantFloorFilter filter)? _filterChanged;

  RestaurantFloorFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  RestaurantFloorPanelData dataFor(
    Iterable<RestaurantServiceZone> zones, {
    String? focusedZoneId,
  }) {
    return RestaurantFloorPanelData.fromZones(
      zones: zones,
      selectedFilter: selectedFilter,
      focusedZoneId: focusedZoneId,
    );
  }

  bool updateConfiguration({
    required RestaurantFloorFilter initialFilter,
    required RestaurantFloorFilter? selectedFilter,
    void Function(RestaurantFloorFilter filter)? onFilterChanged,
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

  bool selectFilter(RestaurantFloorFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantFloorFilter.all);
}
