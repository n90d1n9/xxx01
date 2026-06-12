import 'controlled_panel_value.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_task_filter.dart';
import '../models/restaurant_task_panel_data.dart';

/// Coordinates task panel filter state and derived presentation data.
class RestaurantTaskPanelController {
  RestaurantTaskPanelController({
    RestaurantTaskFilter initialFilter = RestaurantTaskFilter.all,
    RestaurantTaskFilter? selectedFilter,
    void Function(RestaurantTaskFilter filter)? onFilterChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged;

  RestaurantTaskFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantTaskFilter> _selectedFilter;
  RestaurantTaskFilter? _controlledFilter;
  void Function(RestaurantTaskFilter filter)? _filterChanged;

  RestaurantTaskFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  RestaurantTaskPanelData dataFor(
    Iterable<RestaurantShiftTask> tasks, {
    String? focusedTaskId,
  }) {
    return RestaurantTaskPanelData.fromTasks(
      tasks: tasks,
      selectedFilter: selectedFilter,
      focusedTaskId: focusedTaskId,
    );
  }

  bool updateConfiguration({
    required RestaurantTaskFilter initialFilter,
    required RestaurantTaskFilter? selectedFilter,
    void Function(RestaurantTaskFilter filter)? onFilterChanged,
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

  bool selectFilter(RestaurantTaskFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantTaskFilter.all);
}
