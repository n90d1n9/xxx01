import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR activity trail renders recent events', (
    tester,
  ) async {
    final activities = [
      RestaurantReservationQrSessionActivity.actionHandled(
        action: RestaurantReservationQrScanAction.confirmCheckIn,
        label: 'Confirm check-in completed',
        detail: 'Reservation workflow updated from QR scan.',
        occurredAt: DateTime.utc(2026, 6, 10, 13, 10),
      ),
      RestaurantReservationQrSessionActivity.actionSelected(
        action: RestaurantReservationQrScanAction.confirmCheckIn,
        occurredAt: DateTime.utc(2026, 6, 10, 13, 9),
      ),
      RestaurantReservationQrSessionActivity.scanCleared(
        occurredAt: DateTime.utc(2026, 6, 10, 13, 11),
      ),
    ];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrActivityTrail(
        activities: activities,
        maxVisible: 2,
      ),
    );

    expect(find.text('Recent QR activity'), findsOneWidget);
    expect(find.text('2 shown'), findsOneWidget);
    expect(find.text('Confirm check-in completed'), findsOneWidget);
    expect(find.text('Confirm check-in selected'), findsOneWidget);
    expect(find.text('Scan cleared'), findsNothing);
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'Confirm check-in completed\. Reservation workflow updated from QR scan\. Recorded at \d{2}:\d{2}\.',
        ),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
