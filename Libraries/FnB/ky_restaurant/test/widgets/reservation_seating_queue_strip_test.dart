import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('seating queue strip renders readiness buckets and selection', (
    tester,
  ) async {
    final selections = <RestaurantReservationSeatingReadiness>[];
    final summary = RestaurantReservationSeatingQueueSummary.fromReservations(
      restaurantTestReservations,
    );

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationSeatingQueueStrip(
        summary: summary,
        onBucketSelected: selections.add,
      ),
    );

    expect(find.text('Seating readiness'), findsOneWidget);
    expect(find.text('3 active states'), findsOneWidget);
    expect(find.text('Recover arrival'), findsOneWidget);
    expect(find.text('Prepare table'), findsOneWidget);
    expect(find.text('Assign table'), findsOneWidget);

    await tester.tap(find.text('Assign table'));
    await tester.pumpAndSettle();

    expect(selections, [RestaurantReservationSeatingReadiness.assignTable]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('seating queue strip renders all-clear state', (tester) async {
    final summary = RestaurantReservationSeatingQueueSummary.fromReservations([
      restaurantTestReservations.last,
    ]);

    await pumpRestaurantPanel(
      tester,
      RestaurantReservationSeatingQueueStrip(summary: summary),
    );

    expect(find.text('Seating readiness'), findsOneWidget);
    expect(find.text('All clear'), findsOneWidget);
    expect(find.text('No active seating work'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
