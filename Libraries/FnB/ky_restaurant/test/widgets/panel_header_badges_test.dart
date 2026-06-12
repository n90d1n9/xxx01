import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  testWidgets('panel header badges render operating summary labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              ...RestaurantPanelHeaderBadges.service(restaurantDemoSnapshot),
              ...RestaurantPanelHeaderBadges.briefing(
                const RestaurantBriefingBuilder().build(restaurantDemoSnapshot),
              ),
              ...RestaurantPanelHeaderBadges.floor(
                RestaurantFloorSummary.fromZones(restaurantTestFloorZones),
              ),
              ...RestaurantPanelHeaderBadges.kitchen(
                RestaurantKitchenSummary.fromStations(
                  restaurantTestKitchenStations,
                ),
              ),
              ...RestaurantPanelHeaderBadges.menu(
                RestaurantMenuSummary.fromSignals(restaurantTestMenuSignals),
              ),
              ...RestaurantPanelHeaderBadges.reservation(
                RestaurantReservationSummary.fromReservations(
                  restaurantTestReservations,
                ),
              ),
              ...RestaurantPanelHeaderBadges.task(
                RestaurantTaskSummary.fromTasks(restaurantTestShiftTasks),
              ),
              ...RestaurantPanelHeaderBadges.activity(
                totalCount: 3,
                visibleCount: 2,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3 zones'), findsOneWidget);
    expect(find.text('148 covers live'), findsOneWidget);
    expect(find.text('36 pending'), findsOneWidget);
    expect(find.text('18m average'), findsOneWidget);
    expect(find.text('4 moves'), findsOneWidget);
    expect(find.text('Floor'), findsOneWidget);
    expect(find.text('31 tables used'), findsOneWidget);
    expect(find.text('2 watch'), findsOneWidget);
    expect(find.text('3 stations'), findsOneWidget);
    expect(find.text('15m fire'), findsOneWidget);
    expect(find.text('2 warm'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('2 margin'), findsOneWidget);
    expect(find.text('1 risk'), findsOneWidget);
    expect(find.text('4 bookings'), findsOneWidget);
    expect(find.text('16 covers'), findsOneWidget);
    expect(find.text('1 late'), findsOneWidget);
    expect(find.text('3 tasks'), findsOneWidget);
    expect(find.text('2 open'), findsOneWidget);
    expect(find.text('1 watch'), findsOneWidget);
    expect(find.text('3 logged'), findsOneWidget);
    expect(find.text('2 visible'), findsOneWidget);
  });
}
