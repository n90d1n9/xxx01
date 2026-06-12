import 'package:flutter/material.dart';

import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_filter.dart';
import 'restaurant_filter_chip_bar.dart';

class RestaurantReservationFilterBar extends StatelessWidget {
  const RestaurantReservationFilterBar({
    super.key,
    required this.reservations,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<RestaurantReservation> reservations;
  final RestaurantReservationFilter selectedFilter;
  final ValueChanged<RestaurantReservationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return RestaurantFilterChipBar<RestaurantReservationFilter>(
      selectedValue: selectedFilter,
      onChanged: onFilterChanged,
      options: [
        for (final filter in RestaurantReservationFilter.values)
          RestaurantFilterChipOption(
            value: filter,
            label: filter.label,
            count: _countFor(filter),
          ),
      ],
    );
  }

  int _countFor(RestaurantReservationFilter filter) {
    return reservations.where(filter.includes).length;
  }
}
