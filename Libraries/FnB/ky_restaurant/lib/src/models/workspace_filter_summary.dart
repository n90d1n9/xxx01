import 'restaurant_activity_filter.dart';
import 'restaurant_floor_filter.dart';
import 'restaurant_kitchen_filter.dart';
import 'restaurant_menu_filter.dart';
import 'restaurant_menu_sort.dart';
import 'restaurant_reservation_filter.dart';
import 'restaurant_task_filter.dart';

/// Summarizes active workspace filters, searches, and sort selections.
class RestaurantWorkspaceFilterSummary {
  const RestaurantWorkspaceFilterSummary({
    required this.floor,
    required this.reservations,
    required this.kitchen,
    required this.menu,
    required this.task,
    required this.activity,
    required this.menuSearchQuery,
    required this.reservationSearchQuery,
    required this.menuSort,
  });

  final RestaurantFloorFilter floor;
  final RestaurantReservationFilter reservations;
  final RestaurantKitchenFilter kitchen;
  final RestaurantMenuFilter menu;
  final RestaurantTaskFilter task;
  final RestaurantActivityFilter activity;
  final String menuSearchQuery;
  final String reservationSearchQuery;
  final RestaurantMenuSort menuSort;

  int get activeFilterCount {
    return [
      floor != RestaurantFloorFilter.all,
      reservations != RestaurantReservationFilter.all,
      kitchen != RestaurantKitchenFilter.all,
      menu != RestaurantMenuFilter.all,
      task != RestaurantTaskFilter.all,
      activity != RestaurantActivityFilter.all,
      menuSort != RestaurantMenuSort.demand,
    ].where((active) => active).length;
  }

  bool get hasMenuSearchQuery => menuSearchQuery.trim().isNotEmpty;

  bool get hasReservationSearchQuery =>
      reservationSearchQuery.trim().isNotEmpty;

  bool get hasActivePreferences {
    return activeFilterCount > 0 ||
        hasMenuSearchQuery ||
        hasReservationSearchQuery;
  }
}
