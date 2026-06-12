import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('restaurant kitchen pressure callout renders focus guidance', (
    tester,
  ) async {
    var focused = false;

    await pumpRestaurantPanel(
      tester,
      RestaurantKitchenPressureCallout(
        signal: RestaurantKitchenPressureSignal.fromStations(
          restaurantTestKitchenStations,
        ),
        onFocusPressure: () => focused = true,
      ),
    );

    expect(find.text('Recover Grill'), findsOneWidget);
    expect(
      find.text('Steaks with 12 tickets, 21m average fire. Lead Ari.'),
      findsOneWidget,
    );
    expect(find.text('Send support to Grill'), findsOneWidget);
    expect(find.text('Show pressure'), findsOneWidget);

    await tester.tap(find.text('Show pressure'));
    await tester.pumpAndSettle();

    expect(focused, isTrue);
  });

  testWidgets('restaurant kitchen pressure callout hides clear signal', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      const RestaurantKitchenPressureCallout(
        signal: RestaurantKitchenPressureSignal.clear,
      ),
    );

    expect(find.text('Kitchen flow steady'), findsNothing);
  });
}
