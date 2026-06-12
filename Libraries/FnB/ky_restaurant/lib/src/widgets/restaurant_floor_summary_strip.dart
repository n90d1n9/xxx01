import 'package:flutter/material.dart';

import '../models/restaurant_floor_summary.dart';
import '../models/restaurant_models.dart';
import 'restaurant_summary_strip.dart';

class RestaurantFloorSummaryStrip extends StatelessWidget {
  const RestaurantFloorSummaryStrip({super.key, required this.summary});

  final RestaurantFloorSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.attentionCount > 0
        ? RestaurantServiceStatus.busy
        : RestaurantServiceStatus.calm;

    return RestaurantSummaryStrip(
      title: 'Floor readiness',
      valueLabel: summary.readinessLabel,
      progressValue: summary.occupancyRate,
      status: status,
      metrics: [
        RestaurantSummaryStripMetric(
          icon: Icons.event_seat_outlined,
          label: '${summary.occupiedTables}/${summary.totalTables} tables',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.groups_2_outlined,
          label: '${summary.totalCovers} covers',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.hourglass_bottom_outlined,
          label: '${summary.totalWaitList} waiting',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.schedule_outlined,
          label: '${summary.averageTicketMinutes}m avg ticket',
        ),
      ],
    );
  }
}
