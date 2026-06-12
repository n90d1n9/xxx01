import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import '../support/restaurant_test_data.dart';

void main() {
  test('task panel controller derives filtered data from local state', () {
    final controller = RestaurantTaskPanelController();

    expect(controller.selectedFilter, RestaurantTaskFilter.all);
    expect(
      controller.dataFor(restaurantTestShiftTasks).visibleTasks,
      hasLength(3),
    );

    expect(controller.selectFilter(RestaurantTaskFilter.attention), isTrue);

    final data = controller.dataFor(restaurantTestShiftTasks);

    expect(controller.selectedFilter, RestaurantTaskFilter.attention);
    expect(data.visibleTasks.map((task) => task.id), ['attention']);
    expect(data.summary.completedCount, 1);
  });

  test('task panel controller reports controlled changes externally', () {
    final filterChanges = <RestaurantTaskFilter>[];
    final controller = RestaurantTaskPanelController(
      selectedFilter: RestaurantTaskFilter.open,
      onFilterChanged: filterChanges.add,
    );

    expect(controller.selectFilter(RestaurantTaskFilter.done), isFalse);

    expect(filterChanges, [RestaurantTaskFilter.done]);
    expect(controller.selectedFilter, RestaurantTaskFilter.open);
  });

  test('task panel controller syncs untouched initial values', () {
    final controller = RestaurantTaskPanelController();

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantTaskFilter.attention,
        selectedFilter: null,
      ),
      isTrue,
    );
    expect(controller.selectedFilter, RestaurantTaskFilter.attention);

    controller.selectFilter(RestaurantTaskFilter.done);

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantTaskFilter.open,
        selectedFilter: null,
      ),
      isFalse,
    );
    expect(controller.selectedFilter, RestaurantTaskFilter.done);
  });

  test('task panel controller show all resets local filter', () {
    final controller = RestaurantTaskPanelController(
      initialFilter: RestaurantTaskFilter.attention,
    );

    expect(controller.showAll(), isTrue);
    expect(controller.selectedFilter, RestaurantTaskFilter.all);
  });
}
