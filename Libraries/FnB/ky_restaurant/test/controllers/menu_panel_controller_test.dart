import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('menu panel controller derives filtered data from local state', () {
    final controller = RestaurantMenuPanelController();

    expect(controller.selectedFilter, RestaurantMenuFilter.all);
    expect(controller.selectedSort, RestaurantMenuSort.demand);
    expect(
      controller
          .dataFor(restaurantTestMenuSignals)
          .visibleSignals
          .map((signal) => signal.id),
      ['risk', 'quick', 'dessert'],
    );

    expect(controller.selectFilter(RestaurantMenuFilter.quick), isTrue);

    expect(
      controller
          .dataFor(restaurantTestMenuSignals)
          .visibleSignals
          .map((signal) => signal.id),
      ['quick', 'dessert'],
    );
  });

  test('menu panel controller searches and clears query', () {
    final controller = RestaurantMenuPanelController();

    expect(controller.selectSearchQuery('cheese'), isTrue);
    expect(controller.searchQuery, 'cheese');
    expect(
      controller
          .dataFor(restaurantTestMenuSignals)
          .visibleSignals
          .map((signal) => signal.id),
      ['dessert'],
    );

    expect(controller.clearSearch(), isTrue);
    expect(controller.searchQuery, isEmpty);
  });

  test('menu panel controller applies sort selection', () {
    final controller = RestaurantMenuPanelController();

    expect(controller.selectSort(RestaurantMenuSort.prep), isTrue);

    expect(controller.selectedSort, RestaurantMenuSort.prep);
    expect(
      controller
          .dataFor(restaurantTestMenuSignals)
          .visibleSignals
          .map((signal) => signal.id),
      ['quick', 'dessert', 'risk'],
    );
  });

  test('menu panel controller reports controlled changes externally', () {
    final filterChanges = <RestaurantMenuFilter>[];
    final searchChanges = <String>[];
    final sortChanges = <RestaurantMenuSort>[];
    final controller = RestaurantMenuPanelController(
      selectedFilter: RestaurantMenuFilter.risk,
      onFilterChanged: filterChanges.add,
      searchQuery: 'rendang',
      onSearchQueryChanged: searchChanges.add,
      selectedSort: RestaurantMenuSort.margin,
      onSortChanged: sortChanges.add,
    );

    expect(controller.selectFilter(RestaurantMenuFilter.quick), isFalse);
    expect(controller.selectSearchQuery('spritz'), isFalse);
    expect(controller.selectSort(RestaurantMenuSort.prep), isFalse);

    expect(filterChanges, [RestaurantMenuFilter.quick]);
    expect(searchChanges, ['spritz']);
    expect(sortChanges, [RestaurantMenuSort.prep]);
    expect(controller.selectedFilter, RestaurantMenuFilter.risk);
    expect(controller.searchQuery, 'rendang');
    expect(controller.selectedSort, RestaurantMenuSort.margin);
  });

  test('menu panel controller syncs untouched initial values', () {
    final controller = RestaurantMenuPanelController();

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantMenuFilter.margin,
        selectedFilter: null,
        initialSearchQuery: 'stock',
        searchQuery: null,
        initialSort: RestaurantMenuSort.risk,
        selectedSort: null,
      ),
      isTrue,
    );
    expect(controller.selectedFilter, RestaurantMenuFilter.margin);
    expect(controller.searchQuery, 'stock');
    expect(controller.selectedSort, RestaurantMenuSort.risk);

    controller.selectFilter(RestaurantMenuFilter.quick);
    controller.selectSearchQuery('cheese');
    controller.selectSort(RestaurantMenuSort.prep);

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantMenuFilter.restocked,
        selectedFilter: null,
        initialSearchQuery: 'rendang',
        searchQuery: null,
        initialSort: RestaurantMenuSort.margin,
        selectedSort: null,
      ),
      isFalse,
    );
    expect(controller.selectedFilter, RestaurantMenuFilter.quick);
    expect(controller.searchQuery, 'cheese');
    expect(controller.selectedSort, RestaurantMenuSort.prep);
  });
}
