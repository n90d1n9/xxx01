import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('floor panel controller derives filtered zone data', () {
    final controller = RestaurantFloorPanelController();

    expect(controller.selectedFilter, RestaurantFloorFilter.all);
    expect(
      controller.dataFor(restaurantTestFloorZones).visibleZones,
      hasLength(3),
    );

    expect(controller.selectFilter(RestaurantFloorFilter.attention), isTrue);

    final data = controller.dataFor(restaurantTestFloorZones);

    expect(controller.selectedFilter, RestaurantFloorFilter.attention);
    expect(data.visibleZones.map((zone) => zone.id), [
      'main-floor',
      'private-room',
    ]);
    expect(data.summary.waitlistCount, 2);
  });

  test('floor panel controller supports controlled filter ownership', () {
    final filterChanges = <RestaurantFloorFilter>[];
    final controller = RestaurantFloorPanelController(
      selectedFilter: RestaurantFloorFilter.calm,
      onFilterChanged: filterChanges.add,
    );

    expect(controller.selectFilter(RestaurantFloorFilter.waitlist), isFalse);

    expect(filterChanges, [RestaurantFloorFilter.waitlist]);
    expect(controller.selectedFilter, RestaurantFloorFilter.calm);
  });

  test('kitchen panel controller derives filtered station data', () {
    final controller = RestaurantKitchenPanelController();

    expect(controller.selectedFilter, RestaurantKitchenFilter.all);
    expect(
      controller.dataFor(restaurantTestKitchenStations).visibleStations,
      hasLength(3),
    );

    expect(controller.selectFilter(RestaurantKitchenFilter.pressure), isTrue);

    final data = controller.dataFor(restaurantTestKitchenStations);

    expect(controller.selectedFilter, RestaurantKitchenFilter.pressure);
    expect(data.visibleStations.map((station) => station.id), ['grill', 'wok']);
    expect(data.pressureSignal.hasPressure, isTrue);
  });

  test('kitchen panel controller supports controlled filter ownership', () {
    final filterChanges = <RestaurantKitchenFilter>[];
    final controller = RestaurantKitchenPanelController(
      selectedFilter: RestaurantKitchenFilter.all,
      onFilterChanged: filterChanges.add,
    );

    expect(controller.selectFilter(RestaurantKitchenFilter.delayed), isFalse);

    expect(filterChanges, [RestaurantKitchenFilter.delayed]);
    expect(controller.selectedFilter, RestaurantKitchenFilter.all);
  });

  test('floor and kitchen controllers sync untouched initial values', () {
    final floor = RestaurantFloorPanelController();
    final kitchen = RestaurantKitchenPanelController();

    expect(
      floor.updateConfiguration(
        initialFilter: RestaurantFloorFilter.waitlist,
        selectedFilter: null,
      ),
      isTrue,
    );
    expect(
      kitchen.updateConfiguration(
        initialFilter: RestaurantKitchenFilter.calm,
        selectedFilter: null,
      ),
      isTrue,
    );
    expect(floor.selectedFilter, RestaurantFloorFilter.waitlist);
    expect(kitchen.selectedFilter, RestaurantKitchenFilter.calm);

    floor.selectFilter(RestaurantFloorFilter.attention);
    kitchen.selectFilter(RestaurantKitchenFilter.pressure);

    expect(
      floor.updateConfiguration(
        initialFilter: RestaurantFloorFilter.calm,
        selectedFilter: null,
      ),
      isFalse,
    );
    expect(
      kitchen.updateConfiguration(
        initialFilter: RestaurantKitchenFilter.delayed,
        selectedFilter: null,
      ),
      isFalse,
    );
    expect(floor.selectedFilter, RestaurantFloorFilter.attention);
    expect(kitchen.selectedFilter, RestaurantKitchenFilter.pressure);
  });
}
