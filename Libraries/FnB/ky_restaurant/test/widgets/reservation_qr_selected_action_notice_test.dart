import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR selected action notice renders detail copy', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationQrSelectedActionNotice(
        action: RestaurantReservationQrScanAction.confirmCheckIn,
      ),
    );

    expect(find.text('Selected action: Confirm check-in'), findsOneWidget);
    expect(
      find.text(
        'Confirm the arriving party and mark the reservation as present.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.assignment_turned_in_outlined), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Selected action: Confirm check-in. '
        'Confirm the arriving party and mark the reservation as present.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
