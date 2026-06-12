import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR link expiry notice renders recovery copy', (
    tester,
  ) async {
    var refreshCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrLinkExpiryNotice(
        status: const RestaurantReservationQrExpiryStatus(
          urgency: RestaurantReservationQrExpiryUrgency.expiringSoon,
          label: 'Expires in 4 min',
        ),
        onRefresh: () => refreshCount += 1,
      ),
    );

    expect(find.text('QR link expiring soon'), findsOneWidget);
    expect(
      find.text('Expires in 4 min. Refresh if the guest has not scanned yet.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.byTooltip('Refresh QR link'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'QR link expiring soon. '
        'Expires in 4 min. Refresh if the guest has not scanned yet.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();

    expect(refreshCount, 1);
    expect(tester.takeException(), isNull);
  });
}
