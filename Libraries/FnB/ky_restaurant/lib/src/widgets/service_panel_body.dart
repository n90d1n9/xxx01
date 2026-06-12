import 'package:flutter/material.dart';

import '../models/service_pulse_metric.dart';
import 'pulse_metric_card.dart';
import 'restaurant_spaced_list.dart';

/// Renders service pulse metrics as a consistent stack of pulse cards.
class RestaurantServicePanelBody extends StatelessWidget {
  const RestaurantServicePanelBody({super.key, required this.metrics});

  final List<RestaurantServicePulseMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return RestaurantSpacedList<RestaurantServicePulseMetric>(
      items: metrics,
      itemBuilder: (context, metric, index) {
        return RestaurantPulseMetricCard(
          icon: _iconForKind(metric.kind),
          label: metric.label,
          value: metric.value,
          status: metric.status,
          detail: metric.detail,
        );
      },
    );
  }
}

IconData _iconForKind(RestaurantServicePulseMetricKind kind) {
  return switch (kind) {
    RestaurantServicePulseMetricKind.floor => Icons.table_restaurant_outlined,
    RestaurantServicePulseMetricKind.reservations =>
      Icons.event_available_outlined,
    RestaurantServicePulseMetricKind.kitchen => Icons.soup_kitchen_outlined,
    RestaurantServicePulseMetricKind.menu => Icons.restaurant_menu_outlined,
  };
}
