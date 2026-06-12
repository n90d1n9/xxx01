import 'package:flutter/material.dart';

import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_models.dart';
import 'restaurant_filter_chip_bar.dart';

class RestaurantKitchenFilterBar extends StatelessWidget {
  const RestaurantKitchenFilterBar({
    super.key,
    required this.stations,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantKitchenStation> stations;
  final RestaurantKitchenFilter selectedFilter;
  final ValueChanged<RestaurantKitchenFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantKitchenFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantKitchenFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantKitchenFilter filter) {
    return stations.where(filter.includes).length;
  }
}
