import 'package:flutter/material.dart';

import '../controllers/menu_panel_controller.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_catalog_summary.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_models.dart';
import 'menu_panel_body.dart';
import 'panel_header_badges.dart';
import 'restaurant_menu_catalog_panel.dart';
import 'restaurant_panel.dart';

/// Shows menu demand, margin, availability, and restock risk controls.
class RestaurantMenuPanel extends StatefulWidget {
  const RestaurantMenuPanel({
    super.key,
    required this.signals,
    this.menu,
    this.recipes = const [],
    this.stations,
    this.onResolveMenuRisk,
    this.onReviewCatalogItem,
    this.initialFilter = RestaurantMenuFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
    this.initialSearchQuery = '',
    this.searchQuery,
    this.onSearchQueryChanged,
    this.initialSort = RestaurantMenuSort.demand,
    this.selectedSort,
    this.onSortChanged,
    this.showCatalogPanel = true,
    this.focusedSignalId,
    this.focusedCatalogItemId,
  });

  final List<RestaurantMenuSignal> signals;
  final RestaurantMenu? menu;
  final List<RestaurantRecipe> recipes;
  final List<RestaurantKitchenStation>? stations;
  final ValueChanged<String>? onResolveMenuRisk;
  final ValueChanged<String>? onReviewCatalogItem;
  final RestaurantMenuFilter initialFilter;
  final RestaurantMenuFilter? selectedFilter;
  final ValueChanged<RestaurantMenuFilter>? onFilterChanged;
  final String initialSearchQuery;
  final String? searchQuery;
  final ValueChanged<String>? onSearchQueryChanged;
  final RestaurantMenuSort initialSort;
  final RestaurantMenuSort? selectedSort;
  final ValueChanged<RestaurantMenuSort>? onSortChanged;
  final bool showCatalogPanel;
  final String? focusedSignalId;
  final String? focusedCatalogItemId;

  @override
  State<RestaurantMenuPanel> createState() => _RestaurantMenuPanelState();
}

class _RestaurantMenuPanelState extends State<RestaurantMenuPanel> {
  late final RestaurantMenuPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantMenuPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
      initialSearchQuery: widget.initialSearchQuery,
      searchQuery: widget.searchQuery,
      onSearchQueryChanged: widget.onSearchQueryChanged,
      initialSort: widget.initialSort,
      selectedSort: widget.selectedSort,
      onSortChanged: widget.onSortChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantMenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateConfiguration(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
      initialSearchQuery: widget.initialSearchQuery,
      searchQuery: widget.searchQuery,
      onSearchQueryChanged: widget.onSearchQueryChanged,
      initialSort: widget.initialSort,
      selectedSort: widget.selectedSort,
      onSortChanged: widget.onSortChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _controller.dataFor(
      widget.signals,
      focusedSignalId: widget.focusedSignalId,
    );
    final catalogSummary = widget.menu == null
        ? null
        : RestaurantMenuCatalogSummary.fromMenu(
            menu: widget.menu!,
            recipes: widget.recipes,
            stations: widget.stations,
          );

    return RestaurantPanel(
      title: 'Menu mix',
      subtitle: 'Demand, margin, and availability decisions.',
      leading: const Icon(Icons.restaurant_menu_outlined),
      headerBadges: RestaurantPanelHeaderBadges.menu(data.summary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showCatalogPanel && catalogSummary != null) ...[
            RestaurantMenuCatalogPanel(
              summary: catalogSummary,
              onReviewItem: widget.onReviewCatalogItem,
              focusedItemId: widget.focusedCatalogItemId,
            ),
            const SizedBox(height: 14),
          ],
          RestaurantMenuPanelBody(
            data: data,
            onFilterChanged: _selectFilter,
            onSearchQueryChanged: _selectSearchQuery,
            onSortChanged: _selectSort,
            onClearSearch: _clearSearch,
            onShowAll: _showAll,
            onResolveMenuRisk: widget.onResolveMenuRisk,
            focusedSignalId: widget.focusedSignalId,
          ),
        ],
      ),
    );
  }

  void _selectFilter(RestaurantMenuFilter filter) {
    _refreshWhenLocalStateChanges(() => _controller.selectFilter(filter));
  }

  void _selectSearchQuery(String query) {
    _refreshWhenLocalStateChanges(() => _controller.selectSearchQuery(query));
  }

  void _clearSearch() {
    _refreshWhenLocalStateChanges(_controller.clearSearch);
  }

  void _showAll() {
    _refreshWhenLocalStateChanges(_controller.showAll);
  }

  void _selectSort(RestaurantMenuSort sort) {
    _refreshWhenLocalStateChanges(() => _controller.selectSort(sort));
  }

  void _refreshWhenLocalStateChanges(bool Function() update) {
    if (update()) {
      setState(() {});
    }
  }
}
