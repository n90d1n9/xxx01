import 'package:flutter/material.dart';

import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_models.dart';
import 'restaurant_filter_chip_bar.dart';

class RestaurantMenuFilterBar extends StatelessWidget {
  const RestaurantMenuFilterBar({
    super.key,
    required this.signals,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantMenuSignal> signals;
  final RestaurantMenuFilter selectedFilter;
  final ValueChanged<RestaurantMenuFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantMenuFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantMenuFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantMenuFilter filter) {
    return signals.where(filter.includes).length;
  }
}
