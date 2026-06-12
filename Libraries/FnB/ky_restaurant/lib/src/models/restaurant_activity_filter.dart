import 'restaurant_operation_activity.dart';

/// Groups recent operating activity by the workflow that produced it.
enum RestaurantActivityFilter {
  all,
  floor,
  reservations,
  kitchen,
  menu,
  tasks;

  String get label => switch (this) {
    RestaurantActivityFilter.all => 'All',
    RestaurantActivityFilter.floor => 'Floor',
    RestaurantActivityFilter.reservations => 'Reservations',
    RestaurantActivityFilter.kitchen => 'Kitchen',
    RestaurantActivityFilter.menu => 'Menu',
    RestaurantActivityFilter.tasks => 'Tasks',
  };

  bool includes(RestaurantOperationActivity activity) {
    return switch (this) {
      RestaurantActivityFilter.all => true,
      RestaurantActivityFilter.floor =>
        activity.kind == RestaurantOperationActivityKind.zoneStatusChanged,
      RestaurantActivityFilter.reservations =>
        activity.kind ==
            RestaurantOperationActivityKind.reservationStatusChanged,
      RestaurantActivityFilter.kitchen =>
        activity.kind == RestaurantOperationActivityKind.stationStatusChanged ||
            activity.kind ==
                RestaurantOperationActivityKind.recipeProductionReviewed,
      RestaurantActivityFilter.menu =>
        activity.kind == RestaurantOperationActivityKind.menuRiskResolved ||
            activity.kind ==
                RestaurantOperationActivityKind.menuCatalogReviewed,
      RestaurantActivityFilter.tasks =>
        activity.kind == RestaurantOperationActivityKind.taskCompleted,
    };
  }
}
