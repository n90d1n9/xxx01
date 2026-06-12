import 'restaurant_activity_filter.dart';
import 'restaurant_floor_filter.dart';
import 'restaurant_kitchen_filter.dart';
import 'restaurant_menu_filter.dart';
import 'restaurant_menu_sort.dart';
import 'restaurant_reservation_filter.dart';
import 'restaurant_task_filter.dart';
import 'workspace_active_lens.dart';

/// Builds active workspace lenses from filter and sort selections.
class RestaurantWorkspaceFilterLensSet {
  const RestaurantWorkspaceFilterLensSet({
    required this.floor,
    required this.reservations,
    required this.kitchen,
    required this.menu,
    required this.task,
    required this.activity,
    required this.menuSort,
  });

  final RestaurantFloorFilter floor;
  final RestaurantReservationFilter reservations;
  final RestaurantKitchenFilter kitchen;
  final RestaurantMenuFilter menu;
  final RestaurantTaskFilter task;
  final RestaurantActivityFilter activity;
  final RestaurantMenuSort menuSort;

  List<String> get labels {
    return activeLenses.map((lens) => lens.label).toList(growable: false);
  }

  List<RestaurantWorkspaceActiveLens> get activeLenses {
    return [
      if (floor != RestaurantFloorFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.floor,
          label: 'Floor: ${floor.label}',
        ),
      if (reservations != RestaurantReservationFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.reservations,
          label: 'Reservations: ${reservations.label}',
        ),
      if (kitchen != RestaurantKitchenFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.kitchen,
          label: 'Kitchen: ${kitchen.label}',
        ),
      if (menu != RestaurantMenuFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menu,
          label: 'Menu: ${menu.label}',
        ),
      if (task != RestaurantTaskFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.task,
          label: 'Tasks: ${task.label}',
        ),
      if (activity != RestaurantActivityFilter.all)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.activity,
          label: 'Activity: ${activity.label}',
        ),
      if (menuSort != RestaurantMenuSort.demand)
        RestaurantWorkspaceActiveLens(
          kind: RestaurantWorkspaceLensKind.menuSort,
          label: 'Menu sort: ${menuSort.label}',
        ),
    ];
  }
}
