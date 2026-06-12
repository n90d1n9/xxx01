import 'package:flutter/material.dart';

import '../controllers/kitchen_panel_controller.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_models.dart';
import 'kitchen_panel_body.dart';
import 'panel_header_badges.dart';
import 'restaurant_panel.dart';

/// Shows kitchen station pressure, firing pace, and station status actions.
class RestaurantKitchenPanel extends StatefulWidget {
  const RestaurantKitchenPanel({
    super.key,
    required this.stations,
    this.menu,
    this.recipes = const [],
    this.onStationStatusChanged,
    this.onReviewRecipeProduction,
    this.initialFilter = RestaurantKitchenFilter.all,
    this.selectedFilter,
    this.onFilterChanged,
    this.focusedStationId,
    this.focusedRecipeProductionId,
    this.showRecipeProductionPanel = true,
  });

  final List<RestaurantKitchenStation> stations;
  final RestaurantMenu? menu;
  final List<RestaurantRecipe> recipes;
  final void Function(String stationId, RestaurantServiceStatus status)?
  onStationStatusChanged;
  final ValueChanged<String>? onReviewRecipeProduction;
  final RestaurantKitchenFilter initialFilter;
  final RestaurantKitchenFilter? selectedFilter;
  final ValueChanged<RestaurantKitchenFilter>? onFilterChanged;
  final String? focusedStationId;
  final String? focusedRecipeProductionId;
  final bool showRecipeProductionPanel;

  @override
  State<RestaurantKitchenPanel> createState() => _RestaurantKitchenPanelState();
}

class _RestaurantKitchenPanelState extends State<RestaurantKitchenPanel> {
  late final RestaurantKitchenPanelController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestaurantKitchenPanelController(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  void didUpdateWidget(covariant RestaurantKitchenPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateConfiguration(
      initialFilter: widget.initialFilter,
      selectedFilter: widget.selectedFilter,
      onFilterChanged: widget.onFilterChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _controller.dataFor(
      widget.stations,
      focusedStationId: widget.focusedStationId,
    );
    final productionSummary =
        widget.showRecipeProductionPanel && widget.recipes.isNotEmpty
        ? RestaurantRecipeProductionSummary.fromCatalog(
            recipes: widget.recipes,
            menu: widget.menu,
          )
        : null;

    return RestaurantPanel(
      title: 'Kitchen flow',
      subtitle: 'Station load and firing pace by lead.',
      leading: const Icon(Icons.soup_kitchen_outlined),
      headerBadges: RestaurantPanelHeaderBadges.kitchen(data.summary),
      child: RestaurantKitchenPanelBody(
        data: data,
        productionSummary: productionSummary,
        onFilterChanged: _selectFilter,
        onShowAll: _showAll,
        onStationStatusChanged: widget.onStationStatusChanged,
        onReviewRecipeProduction: widget.onReviewRecipeProduction,
        focusedStationId: widget.focusedStationId,
        focusedRecipeProductionId: widget.focusedRecipeProductionId,
      ),
    );
  }

  void _selectFilter(RestaurantKitchenFilter filter) {
    _refreshWhenLocalStateChanges(() => _controller.selectFilter(filter));
  }

  void _showAll() {
    _refreshWhenLocalStateChanges(_controller.showAll);
  }

  void _refreshWhenLocalStateChanges(bool Function() update) {
    if (update()) {
      setState(() {});
    }
  }
}
