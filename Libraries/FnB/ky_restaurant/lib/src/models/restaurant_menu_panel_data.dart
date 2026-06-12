import 'focused_visible_items.dart';
import 'restaurant_menu_filter.dart';
import 'restaurant_menu_sort.dart';
import 'restaurant_menu_summary.dart';
import 'restaurant_models.dart';

/// Derives sorted, filtered, and searchable menu presentation state.
class RestaurantMenuPanelData {
  const RestaurantMenuPanelData._({
    required this.signals,
    required this.selectedFilter,
    required this.searchQuery,
    required this.selectedSort,
    required this.sortedSignals,
    required this.filteredSignals,
    required this.visibleSignals,
    required this.summary,
  });

  factory RestaurantMenuPanelData.fromSignals({
    required Iterable<RestaurantMenuSignal> signals,
    required RestaurantMenuFilter selectedFilter,
    required RestaurantMenuSort selectedSort,
    String searchQuery = '',
    String? focusedSignalId,
  }) {
    final items = signals.toList(growable: false);
    final sortedSignals = sortRestaurantMenuSignals(items, selectedSort);
    final filteredSignals = sortedSignals
        .where(selectedFilter.includes)
        .toList(growable: false);
    final searchedSignals = filteredSignals
        .where((signal) => matchesSearch(signal, searchQuery))
        .toList(growable: false);
    final visibleSignals = restaurantVisibleItemsWithFocus(
      visibleItems: searchedSignals,
      sourceItems: sortedSignals,
      focusedId: focusedSignalId,
      idOf: (signal) => signal.id,
    );

    return RestaurantMenuPanelData._(
      signals: items,
      selectedFilter: selectedFilter,
      searchQuery: searchQuery,
      selectedSort: selectedSort,
      sortedSignals: sortedSignals,
      filteredSignals: filteredSignals,
      visibleSignals: visibleSignals,
      summary: RestaurantMenuSummary.fromSignals(items),
    );
  }

  final List<RestaurantMenuSignal> signals;
  final RestaurantMenuFilter selectedFilter;
  final String searchQuery;
  final RestaurantMenuSort selectedSort;
  final List<RestaurantMenuSignal> sortedSignals;
  final List<RestaurantMenuSignal> filteredSignals;
  final List<RestaurantMenuSignal> visibleSignals;
  final RestaurantMenuSummary summary;

  bool get hasSignals => signals.isNotEmpty;

  bool get hasSearch => searchQuery.trim().isNotEmpty;

  bool get hasVisibleSignals => visibleSignals.isNotEmpty;

  static bool matchesSearch(RestaurantMenuSignal signal, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    bool containsQuery(String value) {
      return value.toLowerCase().contains(normalizedQuery);
    }

    return containsQuery(signal.name) ||
        containsQuery(signal.category) ||
        signal.tags.any(containsQuery);
  }
}
