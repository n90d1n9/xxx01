import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('contact coverage strip renders reachable channel coverage', (
    tester,
  ) async {
    final summary =
        RestaurantReservationContactCoverageSummary.fromReservations(
          restaurantTestReservations,
        );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationContactCoverageStrip(summary: summary),
    );

    expect(find.text('Guest contact'), findsOneWidget);
    expect(find.text('2 reachable guests'), findsWidgets);
    expect(find.text('1 missing contact'), findsOneWidget);
    expect(find.text('2 phone/SMS'), findsOneWidget);
    expect(find.text('2 WhatsApp'), findsOneWidget);
    expect(find.text('1 email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contact coverage strip renders no-open-guests state', (
    tester,
  ) async {
    final summary =
        RestaurantReservationContactCoverageSummary.fromReservations([
          restaurantTestReservations.last,
        ]);

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationContactCoverageStrip(summary: summary),
    );

    expect(find.text('Guest contact'), findsOneWidget);
    expect(find.text('No open guests'), findsOneWidget);
    expect(find.text('No open reservations'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
