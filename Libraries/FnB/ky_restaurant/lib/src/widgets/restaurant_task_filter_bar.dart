import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_task_filter.dart';
import 'restaurant_filter_chip_bar.dart';

class RestaurantTaskFilterBar extends StatelessWidget {
  const RestaurantTaskFilterBar({
    super.key,
    required this.tasks,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantShiftTask> tasks;
  final RestaurantTaskFilter selectedFilter;
  final ValueChanged<RestaurantTaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantTaskFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantTaskFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantTaskFilter filter) {
    return tasks.where(filter.includes).length;
  }
}
