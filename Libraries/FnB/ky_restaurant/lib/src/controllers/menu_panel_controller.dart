import 'controlled_panel_value.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_panel_data.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_models.dart';

/// Coordinates menu panel filters, search state, and sort selection.
class RestaurantMenuPanelController {
  RestaurantMenuPanelController({
    RestaurantMenuFilter initialFilter = RestaurantMenuFilter.all,
    RestaurantMenuFilter? selectedFilter,
    void Function(RestaurantMenuFilter filter)? onFilterChanged,
    String initialSearchQuery = '',
    String? searchQuery,
    void Function(String query)? onSearchQueryChanged,
    RestaurantMenuSort initialSort = RestaurantMenuSort.demand,
    RestaurantMenuSort? selectedSort,
    void Function(RestaurantMenuSort sort)? onSortChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged,
       _initialSearchQuery = initialSearchQuery,
       _searchQuery = RestaurantControlledPanelValue(initialSearchQuery),
       _controlledSearchQuery = searchQuery,
       _searchChanged = onSearchQueryChanged,
       _initialSort = initialSort,
       _selectedSort = RestaurantControlledPanelValue(initialSort),
       _controlledSort = selectedSort,
       _sortChanged = onSortChanged;

  RestaurantMenuFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantMenuFilter> _selectedFilter;
  RestaurantMenuFilter? _controlledFilter;
  void Function(RestaurantMenuFilter filter)? _filterChanged;

  String _initialSearchQuery;
  final RestaurantControlledPanelValue<String> _searchQuery;
  String? _controlledSearchQuery;
  void Function(String query)? _searchChanged;

  RestaurantMenuSort _initialSort;
  final RestaurantControlledPanelValue<RestaurantMenuSort> _selectedSort;
  RestaurantMenuSort? _controlledSort;
  void Function(RestaurantMenuSort sort)? _sortChanged;

  RestaurantMenuFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  String get searchQuery => _searchQuery.resolve(_controlledSearchQuery);

  RestaurantMenuSort get selectedSort {
    return _selectedSort.resolve(_controlledSort);
  }

  RestaurantMenuPanelData dataFor(
    Iterable<RestaurantMenuSignal> signals, {
    String? focusedSignalId,
  }) {
    return RestaurantMenuPanelData.fromSignals(
      signals: signals,
      selectedFilter: selectedFilter,
      selectedSort: selectedSort,
      searchQuery: searchQuery,
      focusedSignalId: focusedSignalId,
    );
  }

  bool updateConfiguration({
    required RestaurantMenuFilter initialFilter,
    required RestaurantMenuFilter? selectedFilter,
    void Function(RestaurantMenuFilter filter)? onFilterChanged,
    required String initialSearchQuery,
    required String? searchQuery,
    void Function(String query)? onSearchQueryChanged,
    required RestaurantMenuSort initialSort,
    required RestaurantMenuSort? selectedSort,
    void Function(RestaurantMenuSort sort)? onSortChanged,
  }) {
    final filterChanged = _selectedFilter.syncInitial(
      previousInitialValue: _initialFilter,
      initialValue: initialFilter,
    );
    final searchChanged = _searchQuery.syncInitial(
      previousInitialValue: _initialSearchQuery,
      initialValue: initialSearchQuery,
    );
    final sortChanged = _selectedSort.syncInitial(
      previousInitialValue: _initialSort,
      initialValue: initialSort,
    );

    _initialFilter = initialFilter;
    _controlledFilter = selectedFilter;
    _filterChanged = onFilterChanged;
    _initialSearchQuery = initialSearchQuery;
    _controlledSearchQuery = searchQuery;
    _searchChanged = onSearchQueryChanged;
    _initialSort = initialSort;
    _controlledSort = selectedSort;
    _sortChanged = onSortChanged;

    return filterChanged || searchChanged || sortChanged;
  }

  bool selectFilter(RestaurantMenuFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantMenuFilter.all);

  bool selectSearchQuery(String query) {
    final changed = _searchQuery.select(
      value: query,
      controlledValue: _controlledSearchQuery,
      onChanged: _searchChanged,
    );
    return changed && _controlledSearchQuery == null;
  }

  bool clearSearch() => selectSearchQuery('');

  bool selectSort(RestaurantMenuSort sort) {
    final changed = _selectedSort.select(
      value: sort,
      controlledValue: _controlledSort,
      onChanged: _sortChanged,
    );
    return changed && _controlledSort == null;
  }
}
