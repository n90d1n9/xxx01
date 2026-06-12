import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../data/restaurant_demo_snapshot.dart';
import '../models/reservation_status_timeline.dart';
import 'reservation_status_timeline.dart';

/// Preview entry for reservation lifecycle progress.
@Preview(name: 'Reservation Status Timeline', group: 'Restaurant')
Widget restaurantReservationStatusTimelinePreview() {
  final timeline = RestaurantReservationStatusTimelineData.fromReservation(
    restaurantDemoReservations[1],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RestaurantReservationStatusTimeline(timeline: timeline),
      ),
    ),
  );
}
