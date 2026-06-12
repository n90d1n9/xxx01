import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_reservation_summary.dart';
import 'restaurant_summary_strip.dart';

class RestaurantReservationSummaryStrip extends StatelessWidget {
  const RestaurantReservationSummaryStrip({super.key, required this.summary});

  final RestaurantReservationSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.lateCount > 0
        ? RestaurantServiceStatus.busy
        : RestaurantServiceStatus.calm;
    final progress = summary.reservationCount == 0
        ? 0.0
        : summary.seatedCount / summary.reservationCount;

    return RestaurantSummaryStrip(
      title: 'Reservation flow',
      valueLabel: summary.lateCount > 0
          ? '${summary.lateCount} late'
          : '${summary.upcomingCount} upcoming',
      progressValue: progress,
      status: status,
      metrics: [
        RestaurantSummaryStripMetric(
          icon: Icons.groups_2_outlined,
          label: '${summary.expectedCovers} covers',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.event_available_outlined,
          label: '${summary.upcomingCount} upcoming',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.event_seat_outlined,
          label: '${summary.seatedCount} seated',
        ),
        RestaurantSummaryStripMetric(
          icon: Icons.stars_outlined,
          label: '${summary.vipCount} VIP',
        ),
      ],
    );
  }
}
