import 'package:flutter/material.dart';

import '../models/kitchen_panel_data.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_models.dart';
import 'filtered_panel_body.dart';
import 'restaurant_empty_state.dart';
import 'restaurant_kitchen_filter_bar.dart';
import 'restaurant_kitchen_pressure_callout.dart';
import 'restaurant_kitchen_station_card.dart';
import 'restaurant_kitchen_summary_strip.dart';
import 'restaurant_recipe_production_panel.dart';
import 'restaurant_spaced_list.dart';

/// Builds the kitchen panel body from station summary, filters, and results.
class RestaurantKitchenPanelBody extends StatelessWidget {
  const RestaurantKitchenPanelBody({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onShowAll,
    this.productionSummary,
    this.onStationStatusChanged,
    this.onReviewRecipeProduction,
    this.focusedStationId,
    this.focusedRecipeProductionId,
  });

  final RestaurantKitchenPanelData data;
  final RestaurantRecipeProductionSummary? productionSummary;
  final ValueChanged<RestaurantKitchenFilter> onFilterChanged;
  final VoidCallback onShowAll;
  final void Function(String stationId, RestaurantServiceStatus status)?
  onStationStatusChanged;
  final ValueChanged<String>? onReviewRecipeProduction;
  final String? focusedStationId;
  final String? focusedRecipeProductionId;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilteredPanelBody(
      hasItems: data.hasStations,
      hasVisibleItems: data.hasVisibleStations,
      emptyState: const RestaurantEmptyState(
        icon: Icons.soup_kitchen_outlined,
        message: 'Kitchen stations will appear here during service.',
      ),
      controls: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productionSummary case final summary?) ...[
            RestaurantRecipeProductionPanel(
              summary: summary,
              onReviewRecipe: onReviewRecipeProduction,
              focusedRecipeId: focusedRecipeProductionId,
            ),
            const SizedBox(height: 14),
          ],
          RestaurantKitchenSummaryStrip(summary: data.summary),
          if (data.pressureSignal.hasPressure) ...[
            const SizedBox(height: 12),
            RestaurantKitchenPressureCallout(
              signal: data.pressureSignal,
              onFocusPressure: () {
                onFilterChanged(RestaurantKitchenFilter.pressure);
              },
            ),
          ],
          const SizedBox(height: 14),
          RestaurantKitchenFilterBar(
            stations: data.stations,
            selectedFilter: data.selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
        ],
      ),
      emptyResultsState: RestaurantEmptyState(
        icon: Icons.soup_kitchen_outlined,
        message:
            'No ${data.selectedFilter.label.toLowerCase()} kitchen stations right now.',
        actionLabel: 'Show all',
        onAction: onShowAll,
      ),
      results: _KitchenStationList(
        stations: data.visibleStations,
        onStatusChanged: onStationStatusChanged,
        focusedStationId: focusedStationId,
      ),
    );
  }
}

/// Renders filtered kitchen station cards with consistent vertical spacing.
class _KitchenStationList extends StatelessWidget {
  const _KitchenStationList({
    required this.stations,
    required this.onStatusChanged,
    this.focusedStationId,
  });

  final List<RestaurantKitchenStation> stations;
  final void Function(String stationId, RestaurantServiceStatus status)?
  onStatusChanged;
  final String? focusedStationId;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantKitchenStation>(
      items: stations,
      itemBuilder: (context, station, index) {
        return RestaurantKitchenStationCard(
          station: station,
          onStatusChanged: onStatusChanged,
          focused: station.id == focusedStationId,
        );
      },
    );
  }
}
