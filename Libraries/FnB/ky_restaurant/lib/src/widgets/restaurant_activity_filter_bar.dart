import 'package:flutter/material.dart';

import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_operation_activity.dart';
import 'restaurant_filter_chip_bar.dart';

/// Renders activity workflow filters with live counts for each activity kind.
class RestaurantActivityFilterBar extends StatelessWidget {
  const RestaurantActivityFilterBar({
    super.key,
    required this.activities,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantOperationActivity> activities;
  final RestaurantActivityFilter selectedFilter;
  final ValueChanged<RestaurantActivityFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantActivityFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantActivityFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantActivityFilter filter) {
    return activities.where(filter.includes).length;
  }
}
