import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('seating strip renders recovery guidance for large parties', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantReservationSeatingStrip(
        reservation: restaurantTestReservations.first,
      ),
    );

    expect(find.text('Recover arrival'), findsOneWidget);
    expect(find.text('Large party'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seating strip renders table assignment guidance', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantReservationSeatingStrip(
        reservation: restaurantTestReservations[2],
      ),
    );

    expect(find.text('Assign table'), findsOneWidget);
    expect(find.text('Large party'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
