import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR session summary header renders compact state', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationQrSessionSummaryHeader(
        summary: RestaurantReservationQrSessionSummaryPresentation(
          title: 'QR scan ready',
          message: 'Check in is ready to continue.',
          tone: RestaurantReservationQrSessionSummaryTone.success,
          metrics: [
            RestaurantReservationQrSessionSummaryMetric(
              label: 'Link',
              value: 'Check in',
            ),
            RestaurantReservationQrSessionSummaryMetric(
              label: 'Scan',
              value: 'QR link ready',
            ),
          ],
        ),
      ),
    );

    expect(find.text('QR scan ready'), findsOneWidget);
    expect(find.text('Check in is ready to continue.'), findsOneWidget);
    expect(find.text('Link: Check in'), findsOneWidget);
    expect(find.text('Scan: QR link ready'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'QR scan ready. Check in is ready to continue. '
        'Link: Check in. Scan: QR link ready.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
