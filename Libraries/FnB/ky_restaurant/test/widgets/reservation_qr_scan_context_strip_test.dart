import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR scan context strip renders context chips', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanContextStrip(
        result: RestaurantReservationQrScanResult.valid(
          uri: Uri.parse(
            'https://tables.kaysir.test/restaurant/reservations/qr',
          ),
          payload: RestaurantReservationQrPayload(
            token: 'scan-token',
            intent: RestaurantReservationQrIntent.checkIn,
            expiresAt: DateTime.utc(2026, 6, 10, 12, 30),
            reservationId: 'RSV-42',
            zoneLabel: 'Main Floor',
            tableLabel: 'Table 8',
          ),
          scannedAt: DateTime.utc(2026, 6, 10, 12),
        ),
      ),
    );

    expect(find.text('QR link ready'), findsOneWidget);
    expect(find.text('Scanned 12:00 UTC'), findsOneWidget);
    expect(find.text('Reservation RSV-42'), findsOneWidget);
    expect(find.text('Expires 12:30 UTC'), findsOneWidget);
    expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'QR link ready. Scanned 12:00 UTC. Check in. Reservation RSV-42. '
        'Expires 12:30 UTC. Main Floor. Table 8',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
