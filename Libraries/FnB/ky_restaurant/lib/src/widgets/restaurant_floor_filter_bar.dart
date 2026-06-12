import 'package:flutter/material.dart';

import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_models.dart';
import 'restaurant_filter_chip_bar.dart';

class RestaurantFloorFilterBar extends StatelessWidget {
  const RestaurantFloorFilterBar({
    super.key,
    required this.zones,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantServiceZone> zones;
  final RestaurantFloorFilter selectedFilter;
  final ValueChanged<RestaurantFloorFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantFloorFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantFloorFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantFloorFilter filter) {
    return zones.where(filter.includes).length;
  }
}
