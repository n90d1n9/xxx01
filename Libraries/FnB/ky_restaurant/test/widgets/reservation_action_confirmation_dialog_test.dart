import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation action confirmation dialog reports decisions', (
    tester,
  ) async {
    final decisions = <String>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationActionConfirmationDialog(
        confirmation: const RestaurantReservationStatusActionConfirmation(
          action: RestaurantReservationStatusAction.markNoShow,
          title: 'Mark no-show?',
          message: 'Move this guest out of the active arrival flow.',
          confirmLabel: 'Mark no-show',
        ),
        onCancel: () => decisions.add('cancel'),
        onConfirm: () => decisions.add('confirm'),
      ),
    );

    expect(find.text('Mark no-show?'), findsOneWidget);
    expect(
      find.text('Move this guest out of the active arrival flow.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Keep reservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Mark no-show'));
    await tester.pumpAndSettle();

    expect(decisions, ['cancel', 'confirm']);
    expect(tester.takeException(), isNull);
  });
}
