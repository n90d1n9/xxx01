import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR refresh feedback notice renders and dismisses', (
    tester,
  ) async {
    var dismissCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrRefreshFeedbackNotice(
        link: RestaurantReservationQrLink(
          action: RestaurantReservationIntakeAction.qrWaitlist,
          payload: RestaurantReservationQrPayload(
            token: 'qr-token',
            intent: RestaurantReservationQrIntent.waitlist,
            expiresAt: DateTime.utc(2026, 6, 10, 13, 30),
            zoneLabel: 'Terrace',
            tableLabel: 'Table 21',
          ),
          uri: Uri.parse(
            'https://tables.kaysir.test/restaurant/reservations/qr?payload=encoded',
          ),
          createdAt: DateTime.utc(2026, 6, 10, 13),
        ),
        onDismiss: () => dismissCount += 1,
      ),
    );

    expect(find.text('Join waitlist QR refreshed'), findsOneWidget);
    expect(
      find.text('New handoff link is live for Terrace - Table 21.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.byTooltip('Dismiss QR refresh feedback'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Join waitlist QR refreshed. '
        'New handoff link is live for Terrace - Table 21.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Dismiss QR refresh feedback'));
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
    expect(tester.takeException(), isNull);
  });
}
