import 'restaurant_activity_filter.dart';
import 'restaurant_floor_filter.dart';
import 'restaurant_kitchen_filter.dart';
import 'restaurant_menu_filter.dart';
import 'restaurant_menu_sort.dart';
import 'restaurant_reservation_filter.dart';
import 'restaurant_task_filter.dart';
import 'workspace_active_lens.dart';
import 'workspace_filter_lenses.dart';
import 'workspace_filter_summary.dart';

export 'workspace_active_lens.dart';
export 'workspace_filter_lenses.dart';
export 'workspace_filter_summary.dart';

/// Stores the active filter, search, and sort preferences for workspace panels.
class RestaurantWorkspacePanelFilters {
  const RestaurantWorkspacePanelFilters({
    this.floor = RestaurantFloorFilter.all,
    this.reservations = RestaurantReservationFilter.all,
    this.kitchen = RestaurantKitchenFilter.all,
    this.menu = RestaurantMenuFilter.all,
    this.task = RestaurantTaskFilter.all,
    this.activity = RestaurantActivityFilter.all,
    this.menuSearchQuery = '',
    this.reservationSearchQuery = '',
    this.menuSort = RestaurantMenuSort.demand,
  });

  factory RestaurantWorkspacePanelFilters.fromJson(Map<String, Object?>? json) {
    if (json == null) return const RestaurantWorkspacePanelFilters();

    return RestaurantWorkspacePanelFilters(
      floor: _enumValue(
        RestaurantFloorFilter.values,
        json['floor'],
        RestaurantFloorFilter.all,
      ),
      kitchen: _enumValue(
        RestaurantKitchenFilter.values,
        json['kitchen'],
        RestaurantKitchenFilter.all,
      ),
      reservations: _enumValue(
        RestaurantReservationFilter.values,
        json['reservations'],
        RestaurantReservationFilter.all,
      ),
      menu: _enumValue(
        RestaurantMenuFilter.values,
        json['menu'],
        RestaurantMenuFilter.all,
      ),
      task: _enumValue(
        RestaurantTaskFilter.values,
        json['task'],
        RestaurantTaskFilter.all,
      ),
      activity: _enumValue(
        RestaurantActivityFilter.values,
        json['activity'],
        RestaurantActivityFilter.all,
      ),
      menuSearchQuery: _stringValue(json['menuSearchQuery']),
      reservationSearchQuery: _stringValue(json['reservationSearchQuery']),
      menuSort: _enumValue(
        RestaurantMenuSort.values,
        json['menuSort'],
        RestaurantMenuSort.demand,
      ),
    );
  }

  final RestaurantFloorFilter floor;
  final RestaurantReservationFilter reservations;
  final RestaurantKitchenFilter kitchen;
  final RestaurantMenuFilter menu;
  final RestaurantTaskFilter task;
  final RestaurantActivityFilter activity;
  final String menuSearchQuery;
  final String reservationSearchQuery;
  final RestaurantMenuSort menuSort;

  Map<String, Object?> toJson() {
    return {
      'floor': floor.name,
      'reservations': reservations.name,
      'kitchen': kitchen.name,
      'menu': menu.name,
      'task': task.name,
      'activity': activity.name,
      'menuSearchQuery': menuSearchQuery,
      'reservationSearchQuery': reservationSearchQuery,
      'menuSort': menuSort.name,
    };
  }

  RestaurantWorkspaceFilterSummary get filterSummary {
    return RestaurantWorkspaceFilterSummary(
      floor: floor,
      reservations: reservations,
      kitchen: kitchen,
      menu: menu,
      task: task,
      activity: activity,
      menuSearchQuery: menuSearchQuery,
      reservationSearchQuery: reservationSearchQuery,
      menuSort: menuSort,
    );
  }

  int get activeFilterCount {
    return filterSummary.activeFilterCount;
  }

  bool get hasMenuSearchQuery => filterSummary.hasMenuSearchQuery;

  bool get hasReservationSearchQuery => filterSummary.hasReservationSearchQuery;

  bool get hasActivePreferences => filterSummary.hasActivePreferences;

  RestaurantWorkspaceFilterLensSet get lensSet {
    return RestaurantWorkspaceFilterLensSet(
      floor: floor,
      reservations: reservations,
      kitchen: kitchen,
      menu: menu,
      task: task,
      activity: activity,
      menuSort: menuSort,
    );
  }

  List<String> get activeLensLabels {
    return lensSet.labels;
  }

  List<RestaurantWorkspaceActiveLens> get activeLenses {
    return lensSet.activeLenses;
  }

  RestaurantWorkspacePanelFilters withoutLens(
    RestaurantWorkspaceLensKind kind,
  ) {
    return switch (kind) {
      RestaurantWorkspaceLensKind.floor => copyWith(
        floor: RestaurantFloorFilter.all,
      ),
      RestaurantWorkspaceLensKind.reservations => copyWith(
        reservations: RestaurantReservationFilter.all,
      ),
      RestaurantWorkspaceLensKind.kitchen => copyWith(
        kitchen: RestaurantKitchenFilter.all,
      ),
      RestaurantWorkspaceLensKind.menu => copyWith(
        menu: RestaurantMenuFilter.all,
      ),
      RestaurantWorkspaceLensKind.task => copyWith(
        task: RestaurantTaskFilter.all,
      ),
      RestaurantWorkspaceLensKind.activity => copyWith(
        activity: RestaurantActivityFilter.all,
      ),
      RestaurantWorkspaceLensKind.menuSort => copyWith(
        menuSort: RestaurantMenuSort.demand,
      ),
      RestaurantWorkspaceLensKind.menuSearch => copyWith(menuSearchQuery: ''),
      RestaurantWorkspaceLensKind.reservationSearch => copyWith(
        reservationSearchQuery: '',
      ),
    };
  }

  RestaurantWorkspacePanelFilters copyWith({
    RestaurantFloorFilter? floor,
    RestaurantReservationFilter? reservations,
    RestaurantKitchenFilter? kitchen,
    RestaurantMenuFilter? menu,
    RestaurantTaskFilter? task,
    RestaurantActivityFilter? activity,
    String? menuSearchQuery,
    String? reservationSearchQuery,
    RestaurantMenuSort? menuSort,
  }) {
    return RestaurantWorkspacePanelFilters(
      floor: floor ?? this.floor,
      reservations: reservations ?? this.reservations,
      kitchen: kitchen ?? this.kitchen,
      menu: menu ?? this.menu,
      task: task ?? this.task,
      activity: activity ?? this.activity,
      menuSearchQuery: menuSearchQuery ?? this.menuSearchQuery,
      reservationSearchQuery:
          reservationSearchQuery ?? this.reservationSearchQuery,
      menuSort: menuSort ?? this.menuSort,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RestaurantWorkspacePanelFilters &&
            floor == other.floor &&
            reservations == other.reservations &&
            kitchen == other.kitchen &&
            menu == other.menu &&
            task == other.task &&
            activity == other.activity &&
            menuSearchQuery == other.menuSearchQuery &&
            reservationSearchQuery == other.reservationSearchQuery &&
            menuSort == other.menuSort;
  }

  @override
  int get hashCode {
    return Object.hash(
      floor,
      reservations,
      kitchen,
      menu,
      task,
      activity,
      menuSearchQuery,
      reservationSearchQuery,
      menuSort,
    );
  }
}

T _enumValue<T extends Enum>(List<T> values, Object? value, T fallback) {
  if (value is! String) return fallback;
  for (final item in values) {
    if (item.name == value) return item;
  }
  return fallback;
}

String _stringValue(Object? value) {
  return value is String ? value : '';
}
