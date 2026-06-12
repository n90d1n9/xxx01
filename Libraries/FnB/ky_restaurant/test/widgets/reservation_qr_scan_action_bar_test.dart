import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation QR scan action bar emphasizes primary action', (
    tester,
  ) async {
    var continueCount = 0;
    var dismissCount = 0;
    final selectedActions = <RestaurantReservationQrScanAction>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationQrScanActionBar(
        plan: const RestaurantReservationQrScanActionPlan(
          primaryAction: RestaurantReservationQrScanAction.confirmCheckIn,
          secondaryActions: [RestaurantReservationQrScanAction.dismiss],
        ),
        onActionSelected: selectedActions.add,
        onContinue: () => continueCount += 1,
        onDismiss: () => dismissCount += 1,
      ),
    );

    expect(
      find.widgetWithText(FilledButton, 'Confirm check-in'),
      findsOneWidget,
    );
    expect(find.text('Confirm the arriving party.'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Dismiss'), findsOneWidget);
    expect(find.text('Close the scan result.'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm check-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Dismiss'));
    await tester.pumpAndSettle();

    expect(selectedActions, [
      RestaurantReservationQrScanAction.confirmCheckIn,
      RestaurantReservationQrScanAction.dismiss,
    ]);
    expect(continueCount, 1);
    expect(dismissCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation QR scan action bar hides unavailable actions', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantReservationQrScanActionBar(
        plan: RestaurantReservationQrScanActionPlan(
          primaryAction: RestaurantReservationQrScanAction.createBooking,
          secondaryActions: [RestaurantReservationQrScanAction.dismiss],
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(OutlinedButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
