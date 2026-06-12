import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation action bar emphasizes primary action', (
    tester,
  ) async {
    final selections = <RestaurantReservationStatusAction>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationActionBar(
        actions: RestaurantReservationStatus.confirmed.nextActions,
        onActionSelected: selections.add,
      ),
    );

    expect(find.widgetWithText(FilledButton, 'Arrived'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'No-show'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Arrived'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'No-show'));
    await tester.pumpAndSettle();

    expect(selections, [
      RestaurantReservationStatusAction.markArrived,
      RestaurantReservationStatusAction.markNoShow,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reservation action bar can render caution-only plans', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      RestaurantReservationActionBar(
        actions: const [RestaurantReservationStatusAction.cancel],
        onActionSelected: (_) {},
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
