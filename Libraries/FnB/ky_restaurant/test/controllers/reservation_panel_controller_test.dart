import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('reservation panel controller derives data from local state', () {
    final controller = RestaurantReservationPanelController();

    expect(controller.selectedFilter, RestaurantReservationFilter.all);
    expect(
      controller.dataFor(restaurantTestReservations).visibleReservations,
      hasLength(4),
    );

    expect(
      controller.selectActionBucket(
        RestaurantReservationActionBucketKind.recoverLate,
      ),
      isTrue,
    );

    final data = controller.dataFor(restaurantTestReservations);

    expect(controller.selectedFilter, RestaurantReservationFilter.late);
    expect(data.visibleReservations.map((reservation) => reservation.id), [
      'late',
    ]);

    expect(
      controller.selectSeatingReadiness(
        RestaurantReservationSeatingReadiness.assignTable,
      ),
      isTrue,
    );
    expect(controller.selectedFilter, RestaurantReservationFilter.arrived);
  });

  test('reservation panel controller selects and toggles zone search', () {
    final controller = RestaurantReservationPanelController(
      initialFilter: RestaurantReservationFilter.vip,
    );
    final terraceLoad = controller
        .dataFor(restaurantTestReservations)
        .zoneLoads
        .singleWhere((load) => load.zoneLabel == 'Terrace');

    expect(controller.selectZoneLoad(terraceLoad), isTrue);
    expect(controller.selectedFilter, RestaurantReservationFilter.all);
    expect(controller.searchQuery, 'Terrace');
    expect(
      controller
          .dataFor(restaurantTestReservations)
          .visibleReservations
          .map((reservation) => reservation.id),
      ['late'],
    );

    expect(controller.selectZoneLoad(terraceLoad), isTrue);
    expect(controller.searchQuery, isEmpty);
  });

  test(
    'reservation panel controller reports controlled changes externally',
    () {
      final filterChanges = <RestaurantReservationFilter>[];
      final searchChanges = <String>[];
      final controller = RestaurantReservationPanelController(
        selectedFilter: RestaurantReservationFilter.vip,
        onFilterChanged: filterChanges.add,
        searchQuery: 'Main Floor',
        onSearchQueryChanged: searchChanges.add,
      );

      expect(
        controller.selectFilter(RestaurantReservationFilter.late),
        isFalse,
      );
      expect(controller.selectSearchQuery('Terrace'), isFalse);

      expect(filterChanges, [RestaurantReservationFilter.late]);
      expect(searchChanges, ['Terrace']);
      expect(controller.selectedFilter, RestaurantReservationFilter.vip);
      expect(controller.searchQuery, 'Main Floor');
    },
  );

  test('reservation panel controller syncs untouched initial values', () {
    final controller = RestaurantReservationPanelController(
      initialFilter: RestaurantReservationFilter.all,
      initialSearchQuery: '',
    );

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantReservationFilter.late,
        selectedFilter: null,
        initialSearchQuery: 'Terrace',
        searchQuery: null,
      ),
      isTrue,
    );
    expect(controller.selectedFilter, RestaurantReservationFilter.late);
    expect(controller.searchQuery, 'Terrace');

    controller.selectFilter(RestaurantReservationFilter.vip);
    controller.selectSearchQuery('Main Floor');

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantReservationFilter.closed,
        selectedFilter: null,
        initialSearchQuery: 'Bar Counter',
        searchQuery: null,
      ),
      isFalse,
    );
    expect(controller.selectedFilter, RestaurantReservationFilter.vip);
    expect(controller.searchQuery, 'Main Floor');
  });
}
