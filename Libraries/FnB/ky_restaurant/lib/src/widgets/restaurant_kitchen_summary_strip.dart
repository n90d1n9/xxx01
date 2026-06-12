import 'package:flutter/material.dart';

import '../models/restaurant_kitchen_summary.dart';
import '../models/restaurant_models.dart';
import 'restaurant_summary_strip.dart';

class RestaurantKitchenSummaryStrip extends StatelessWidget {
  const RestaurantKitchenSummaryStrip({super.key, required this.summary});

  final RestaurantKitchenSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.delayedCount > 0
        ? RestaurantServiceStatus.critical
        : summary.pressureCount > 0
        ? RestaurantServiceStatus.busy
        : RestaurantServiceStatus.calm;

    return RestaurantSummaryStrip(
      title: 'Kitchen pressure',
      valueLabel: summary.pressureLabel,
      progressValue: summary.pressureRate,
      status: status,
      metrics: [
        RestaurantSummaryStripMetric(
          icon: Icons.receipt_long_outlined,
          label: '${summary.totalTickets} tickets',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.local_fire_department_outlined,
          label: '${summary.averageFireMinutes}m avg fire',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.timelapse_outlined,
          label: '${summary.delayedCount} delayed',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.check_circle_outline_rounded,
          label: '${summary.calmCount} calm',
        ),
      ],
    );
  }
}
