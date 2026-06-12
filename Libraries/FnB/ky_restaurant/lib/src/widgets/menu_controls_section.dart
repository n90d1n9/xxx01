import 'package:flutter/material.dart';

import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_panel_data.dart';
import '../models/restaurant_menu_sort.dart';
import 'restaurant_menu_filter_bar.dart';
import 'restaurant_menu_sort_button.dart';
import 'restaurant_menu_summary_strip.dart';
import 'restaurant_search_field.dart';

/// Displays menu summary, filter, search, and sort controls.
class RestaurantMenuControlsSection extends StatelessWidget {
  const RestaurantMenuControlsSection({
    super.key,
    required this.data,
    required this.onFilterChanged,
    required this.onSearchQueryChanged,
    required this.onSortChanged,
  });

  final RestaurantMenuPanelData data;
  final ValueChanged<RestaurantMenuFilter> onFilterChanged;
  final ValueChanged<String> onSearchQueryChanged;
  final ValueChanged<RestaurantMenuSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantMenuSummaryStrip(summary: data.summary),
        const SizedBox(height: 14),
        RestaurantMenuFilterBar(
          signals: data.signals,
          selectedFilter: data.selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RestaurantSearchField(
                value: data.searchQuery,
                hintText: 'Search menu items',
                onChanged: onSearchQueryChanged,
              ),
            ),
            const SizedBox(width: 10),
            RestaurantMenuSortButton(
              selectedSort: data.selectedSort,
              onChanged: onSortChanged,
            ),
          ],
        ),
      ],
    );
  }
}
