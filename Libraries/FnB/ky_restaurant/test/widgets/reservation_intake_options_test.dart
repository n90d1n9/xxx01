import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('reservation intake options render QR alternatives', (
    tester,
  ) async {
    final selectedActions = <RestaurantReservationIntakeAction>[];

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationIntakeOptions(onActionSelected: selectedActions.add),
    );

    expect(find.text('Intake options'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('QR booking'), findsOneWidget);
    expect(find.text('QR waitlist'), findsOneWidget);
    expect(find.text('QR check-in'), findsOneWidget);
    expect(find.text('3 QR flows'), findsOneWidget);

    await tester.tap(find.text('QR waitlist'));
    await tester.pumpAndSettle();

    expect(selectedActions, [RestaurantReservationIntakeAction.qrWaitlist]);
  });
}
