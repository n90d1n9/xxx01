import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'metric_card.dart';
import 'restaurant_adaptive_grid.dart';

/// Shows operating metrics in a responsive grid of reusable metric cards.
class RestaurantMetricGrid extends StatelessWidget {
  const RestaurantMetricGrid({super.key, required this.metrics});

  final List<RestaurantMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return RestaurantAdaptiveGrid(
      itemCount: metrics.length,
      itemExtent: 134,
      itemBuilder: (context, index) =>
          RestaurantMetricCard(metric: metrics[index]),
    );
  }
}
