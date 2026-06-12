import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';
import '../support/restaurant_widget_test_harness.dart';

void main() {
  testWidgets('floor and kitchen panel bodies render controls and results', (
    tester,
  ) async {
    await pumpRestaurantPanel(
      tester,
      Column(
        children: [
          RestaurantFloorPanelBody(
            data: RestaurantFloorPanelData.fromZones(
              zones: restaurantTestFloorZones,
              selectedFilter: RestaurantFloorFilter.all,
            ),
            onFilterChanged: (_) {},
            onShowAll: () {},
          ),
          RestaurantKitchenPanelBody(
            data: RestaurantKitchenPanelData.fromStations(
              stations: restaurantTestKitchenStations,
              selectedFilter: RestaurantKitchenFilter.all,
            ),
            onFilterChanged: (_) {},
            onShowAll: () {},
          ),
        ],
      ),
    );

    expect(find.text('Floor readiness'), findsOneWidget);
    expect(find.text('Kitchen pressure'), findsOneWidget);
    expect(find.text('Recover Grill'), findsOneWidget);
    expect(find.text('Show pressure'), findsOneWidget);
    expect(find.byType(RestaurantFloorZoneCard), findsWidgets);
    expect(find.byType(RestaurantKitchenStationCard), findsWidgets);
  });
}
