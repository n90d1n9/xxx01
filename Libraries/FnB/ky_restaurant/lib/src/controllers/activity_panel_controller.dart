import 'controlled_panel_value.dart';
import '../models/activity_panel_data.dart';
import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_operation_activity.dart';

/// Coordinates activity panel filter state and derived presentation data.
class RestaurantActivityPanelController {
  RestaurantActivityPanelController({
    RestaurantActivityFilter initialFilter = RestaurantActivityFilter.all,
    RestaurantActivityFilter? selectedFilter,
    void Function(RestaurantActivityFilter filter)? onFilterChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged;

  RestaurantActivityFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantActivityFilter>
  _selectedFilter;
  RestaurantActivityFilter? _controlledFilter;
  void Function(RestaurantActivityFilter filter)? _filterChanged;

  RestaurantActivityFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  RestaurantActivityPanelData dataFor({
    required Iterable<RestaurantOperationActivity> activities,
    required int visibleCount,
  }) {
    return RestaurantActivityPanelData.fromActivities(
      activities: activities,
      selectedFilter: selectedFilter,
      visibleCount: visibleCount,
    );
  }

  bool updateConfiguration({
    required RestaurantActivityFilter initialFilter,
    required RestaurantActivityFilter? selectedFilter,
    void Function(RestaurantActivityFilter filter)? onFilterChanged,
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

  bool selectFilter(RestaurantActivityFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantActivityFilter.all);
}
