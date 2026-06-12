import 'package:flutter/material.dart';

import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_panel_data.dart';
import '../models/restaurant_menu_sort.dart';
import 'filtered_panel_body.dart';
import 'menu_controls_section.dart';
import 'menu_signal_list.dart';
import 'restaurant_empty_state.dart';

/// Builds the menu panel body from menu presentation data and actions.
class RestaurantMenuPanelBody extends StatelessWidget {
  const RestaurantMenuPanelBody({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onSearchQueryChanged,
    required this.onSortChanged,
    required this.onClearSearch,
    required this.onShowAll,
    this.onResolveMenuRisk,
    this.focusedSignalId,
  });

  final RestaurantMenuPanelData data;
  final ValueChanged<RestaurantMenuFilter> onFilterChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<RestaurantMenuSort> onSortChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onShowAll;
  final ValueChanged<String>? onResolveMenuRisk;
  final String? focusedSignalId;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasSignals,
      hasVisibleItems: data.hasVisibleSignals,
      emptyState: const RestaurantEmptyState(
        icon: Icons.restaurant_menu_outlined,
        message: 'Menu signals will appear here during service.',
      ),
      controls: RestaurantMenuControlsSection(
        data: data,
        onFilterChanged: onFilterChanged,
        onSearchQueryChanged: onSearchQueryChanged,
        onSortChanged: onSortChanged,
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: data.hasSearch
            ? Icons.search_off_rounded
            : Icons.restaurant_menu_outlined,
        message: data.hasSearch
            ? 'No menu items match "${data.searchQuery}".'
            : 'No ${data.selectedFilter.label.toLowerCase()} menu items in this lens.',
        actionLabel: data.hasSearch ? 'Clear search' : 'Show all',
        onAction: data.hasSearch ? onClearSearch : onShowAll,
      ),
      results: RestaurantMenuSignalList(
        signals: data.visibleSignals,
        onResolveMenuRisk: onResolveMenuRisk,
        focusedSignalId: focusedSignalId,
      ),
    );
  }
}
