import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR action feedback notice renders handled state', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrActionFeedbackNotice(
        result: RestaurantReservationQrActionHandlingResult.handled(
          RestaurantReservationQrScanAction.confirmCheckIn,
        ),
      ),
    );

    expect(find.text('Confirm check-in handled'), findsOneWidget);
    expect(
      find.text('Reservation workflow updated from QR scan.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Confirm check-in handled. Reservation workflow updated from QR scan.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR action feedback notice dismisses feedback', (
    tester,
  ) async {
    var dismissCount = 0;

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrActionFeedbackNotice(
        result: RestaurantReservationQrActionHandlingResult.unavailable(
          RestaurantReservationQrScanAction.joinWaitlist,
        ),
        onDismiss: () => dismissCount += 1,
      ),
    );

    expect(find.text('Action needs setup'), findsOneWidget);
    expect(find.byTooltip('Dismiss QR action feedback'), findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss QR action feedback'));
    await tester.pumpAndSettle();

    expect(dismissCount, 1);
    expect(tester.takeException(), isNull);
  });
}
