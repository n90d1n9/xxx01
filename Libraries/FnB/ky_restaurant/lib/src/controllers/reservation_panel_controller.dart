import 'controlled_panel_value.dart';
import '../models/reservation_seating_queue.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_action_queue.dart';
import '../models/restaurant_reservation_arrival_window.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_reservation_panel_data.dart';
import '../models/restaurant_reservation_seating_assessment.dart';
import '../models/restaurant_reservation_zone_load.dart';
import '../services/restaurant_reservation_seating_advisor.dart';

/// Coordinates reservation panel filters, search state, and quick-select flows.
class RestaurantReservationPanelController {
  RestaurantReservationPanelController({
    RestaurantReservationFilter initialFilter = RestaurantReservationFilter.all,
    RestaurantReservationFilter? selectedFilter,
    void Function(RestaurantReservationFilter filter)? onFilterChanged,
    String initialSearchQuery = '',
    String? searchQuery,
    void Function(String query)? onSearchQueryChanged,
  }) : _initialFilter = initialFilter,
       _selectedFilter = RestaurantControlledPanelValue(initialFilter),
       _controlledFilter = selectedFilter,
       _filterChanged = onFilterChanged,
       _initialSearchQuery = initialSearchQuery,
       _searchQuery = RestaurantControlledPanelValue(initialSearchQuery),
       _controlledSearchQuery = searchQuery,
       _searchChanged = onSearchQueryChanged;

  RestaurantReservationFilter _initialFilter;
  final RestaurantControlledPanelValue<RestaurantReservationFilter>
  _selectedFilter;
  RestaurantReservationFilter? _controlledFilter;
  void Function(RestaurantReservationFilter filter)? _filterChanged;

  String _initialSearchQuery;
  final RestaurantControlledPanelValue<String> _searchQuery;
  String? _controlledSearchQuery;
  void Function(String query)? _searchChanged;

  RestaurantReservationFilter get selectedFilter {
    return _selectedFilter.resolve(_controlledFilter);
  }

  String get searchQuery => _searchQuery.resolve(_controlledSearchQuery);

  RestaurantReservationPanelData dataFor(
    Iterable<RestaurantReservation> reservations, {
    String? focusedReservationId,
    RestaurantReservationSeatingAdvisor seatingAdvisor =
        const RestaurantReservationSeatingAdvisor(),
  }) {
    return RestaurantReservationPanelData.fromReservations(
      reservations: reservations,
      selectedFilter: selectedFilter,
      searchQuery: searchQuery,
      focusedReservationId: focusedReservationId,
      seatingAdvisor: seatingAdvisor,
    );
  }

  bool updateConfiguration({
    required RestaurantReservationFilter initialFilter,
    required RestaurantReservationFilter? selectedFilter,
    void Function(RestaurantReservationFilter filter)? onFilterChanged,
    required String initialSearchQuery,
    required String? searchQuery,
    void Function(String query)? onSearchQueryChanged,
  }) {
    final filterChanged = _selectedFilter.syncInitial(
      previousInitialValue: _initialFilter,
      initialValue: initialFilter,
    );
    final searchChanged = _searchQuery.syncInitial(
      previousInitialValue: _initialSearchQuery,
      initialValue: initialSearchQuery,
    );

    _initialFilter = initialFilter;
    _controlledFilter = selectedFilter;
    _filterChanged = onFilterChanged;
    _initialSearchQuery = initialSearchQuery;
    _controlledSearchQuery = searchQuery;
    _searchChanged = onSearchQueryChanged;

    return filterChanged || searchChanged;
  }

  bool selectFilter(RestaurantReservationFilter filter) {
    final changed = _selectedFilter.select(
      value: filter,
      controlledValue: _controlledFilter,
      onChanged: _filterChanged,
    );
    return changed && _controlledFilter == null;
  }

  bool showAll() => selectFilter(RestaurantReservationFilter.all);

  bool selectActionBucket(RestaurantReservationActionBucketKind kind) {
    return selectFilter(kind.targetFilter);
  }

  bool selectArrivalWindow(RestaurantReservationArrivalWindowKind kind) {
    return selectFilter(kind.targetFilter);
  }

  bool selectSeatingReadiness(RestaurantReservationSeatingReadiness readiness) {
    return selectFilter(
      RestaurantReservationSeatingQueueBucket.targetFilterFor(readiness),
    );
  }

  bool selectZoneLoad(RestaurantReservationZoneLoad load) {
    final selectedZone = load.zoneLabel.trim();
    final currentSearchQuery = searchQuery.trim();
    if (selectedZone.toLowerCase() == currentSearchQuery.toLowerCase()) {
      return clearSearch();
    }

    final filterChanged = selectFilter(RestaurantReservationFilter.all);
    final searchChanged = selectSearchQuery(selectedZone);
    return filterChanged || searchChanged;
  }

  bool selectSearchQuery(String query) {
    final changed = _searchQuery.select(
      value: query,
      controlledValue: _controlledSearchQuery,
      onChanged: _searchChanged,
    );
    return changed && _controlledSearchQuery == null;
  }

  bool clearSearch() => selectSearchQuery('');
}
