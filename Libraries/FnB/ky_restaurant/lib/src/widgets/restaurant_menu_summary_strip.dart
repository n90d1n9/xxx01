import 'package:flutter/material.dart';

import '../models/restaurant_menu_summary.dart';
import '../models/restaurant_models.dart';
import 'restaurant_summary_strip.dart';

class RestaurantMenuSummaryStrip extends StatelessWidget {
  const RestaurantMenuSummaryStrip({super.key, required this.summary});

  final RestaurantMenuSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.riskCount > 0
        ? RestaurantServiceStatus.busy
        : RestaurantServiceStatus.calm;

    return RestaurantSummaryStrip(
      title: 'Availability watch',
      valueLabel: summary.riskLabel,
      progressValue: summary.riskRate,
      status: status,
      metrics: [
        RestaurantSummaryStripMetric(
          icon: Icons.restaurant_menu_outlined,
          label: '${summary.totalCount} items',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.trending_up_outlined,
          label: '${summary.averageMarginPercent}% avg margin',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.timer_outlined,
          label: '${summary.quickPrepCount} quick prep',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.inventory_2_outlined,
          label: '${summary.restockedCount} restocked',
        ),
      ],
    );
  }
}
