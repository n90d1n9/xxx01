import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation status timeline renders active lifecycle state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      final timeline = RestaurantReservationStatusTimelineData.fromReservation(
        restaurantTestReservations.first,
      );

      await pumpRestaurantPanel(
        tester,
        RestaurantReservationStatusTimeline(timeline: timeline),
      );

      expect(find.text('Status path'), findsOneWidget);
      expect(find.text('Requested'), findsOneWidget);
      expect(find.text('Late'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final progressSemantics = tester.getSemantics(
        find.byType(LinearProgressIndicator),
      );
      expect(
        progressSemantics.label,
        'Reservation status Late, 25% through lifecycle',
      );
      expect(progressSemantics.value, '25%');
    } finally {
      semantics.dispose();
    }
  });
}
