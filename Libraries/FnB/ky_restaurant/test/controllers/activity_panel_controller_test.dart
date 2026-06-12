import 'package:flutter_test/flutter_test.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

void main() {
  test('activity panel controller filters and caps visible activities', () {
    final controller = RestaurantActivityPanelController();
    final activities = _activities();

    expect(controller.selectedFilter, RestaurantActivityFilter.all);
    expect(
      controller
          .dataFor(activities: activities, visibleCount: 2)
          .visibleActivities
          .map((activity) => activity.id),
      ['task-1', 'menu-1'],
    );

    expect(controller.selectFilter(RestaurantActivityFilter.menu), isTrue);

    final data = controller.dataFor(activities: activities, visibleCount: 5);

    expect(controller.selectedFilter, RestaurantActivityFilter.menu);
    expect(data.visibleActivities.map((activity) => activity.id), ['menu-1']);
    expect(data.totalCount, 3);
    expect(data.shownCount, 1);
    expect(
      controller
          .dataFor(activities: activities, visibleCount: -1)
          .visibleActivities,
      isEmpty,
    );
  });

  test('activity panel controller reports controlled changes externally', () {
    final filterChanges = <RestaurantActivityFilter>[];
    final controller = RestaurantActivityPanelController(
      selectedFilter: RestaurantActivityFilter.tasks,
      onFilterChanged: filterChanges.add,
    );

    expect(
      controller.selectFilter(RestaurantActivityFilter.reservations),
      isFalse,
    );

    expect(filterChanges, [RestaurantActivityFilter.reservations]);
    expect(controller.selectedFilter, RestaurantActivityFilter.tasks);
  });

  test('activity panel controller syncs untouched initial values', () {
    final controller = RestaurantActivityPanelController();

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantActivityFilter.kitchen,
        selectedFilter: null,
      ),
      isTrue,
    );
    expect(controller.selectedFilter, RestaurantActivityFilter.kitchen);

    controller.selectFilter(RestaurantActivityFilter.floor);

    expect(
      controller.updateConfiguration(
        initialFilter: RestaurantActivityFilter.menu,
        selectedFilter: null,
      ),
      isFalse,
    );
    expect(controller.selectedFilter, RestaurantActivityFilter.floor);
  });

  test('activity panel controller show all resets local filter', () {
    final controller = RestaurantActivityPanelController(
      initialFilter: RestaurantActivityFilter.tasks,
    );

    expect(controller.showAll(), isTrue);
    expect(controller.selectedFilter, RestaurantActivityFilter.all);
  });
}

List<RestaurantOperationActivity> _activities() {
  return [
    RestaurantOperationActivity(
      id: 'task-1',
      kind: RestaurantOperationActivityKind.taskCompleted,
      title: 'Task completed',
      description: 'Dessert restock finished.',
      createdAt: DateTime(2026, 1, 1, 18),
    ),
    RestaurantOperationActivity(
      id: 'menu-1',
      kind: RestaurantOperationActivityKind.menuRiskResolved,
      title: 'Menu risk resolved',
      description: 'Short rib restocked.',
      createdAt: DateTime(2026, 1, 1, 18, 5),
    ),
    RestaurantOperationActivity(
      id: 'station-1',
      kind: RestaurantOperationActivityKind.stationStatusChanged,
      title: 'Station recovered',
      description: 'Grill moved to calm.',
      createdAt: DateTime(2026, 1, 1, 18, 10),
    ),
  ];
}
