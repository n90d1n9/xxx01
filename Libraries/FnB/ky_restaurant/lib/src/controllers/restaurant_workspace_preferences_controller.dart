import 'package:flutter/foundation.dart';

import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_operational_insight.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_task_filter.dart';
import '../models/restaurant_workspace_navigation_target.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_preferences.dart';
import '../models/restaurant_workspace_preset.dart';
import '../models/restaurant_workspace_view.dart';

/// Owns the selected workspace view, filters, search, sort, and lens state.
class RestaurantWorkspacePreferencesController extends ChangeNotifier {
  RestaurantWorkspacePreferencesController({
    RestaurantWorkspacePreferences initialPreferences =
        const RestaurantWorkspacePreferences(),
  }) : _preferences = initialPreferences;

  RestaurantWorkspacePreferences _preferences;

  RestaurantWorkspacePreferences get preferences => _preferences;

  RestaurantWorkspaceView get selectedView => _preferences.view;

  RestaurantWorkspacePanelFilters get filters => _preferences.filters;

  RestaurantWorkspacePanelFocus? get focus => _preferences.focus;

  bool setPreferences(RestaurantWorkspacePreferences preferences) {
    return _setPreferences(preferences);
  }

  bool selectView(RestaurantWorkspaceView view) {
    return _setPreferences(_preferences.copyWith(view: view, focus: null));
  }

  bool setFilters(RestaurantWorkspacePanelFilters filters) {
    return _setPreferences(
      _preferences.copyWith(filters: filters, focus: null),
    );
  }

  bool updateFilters(
    RestaurantWorkspacePanelFilters Function(
      RestaurantWorkspacePanelFilters filters,
    )
    update,
  ) {
    return setFilters(update(_preferences.filters));
  }

  bool selectPreset(RestaurantWorkspacePreset preset) {
    return _setPreferences(
      RestaurantWorkspacePreferences(
        view: preset.view,
        filters: preset.filters,
      ),
    );
  }

  bool selectInsight(RestaurantOperationalInsight insight) {
    return _setPreferences(
      RestaurantWorkspacePreferences(
        view: insight.targetView,
        filters: insight.targetFilters,
      ),
    );
  }

  bool selectNavigationTarget(RestaurantWorkspaceNavigationTarget target) {
    return _setPreferences(
      RestaurantWorkspacePreferences(
        view: target.view,
        filters: target.filters,
        focus: target.focus,
      ),
    );
  }

  bool selectFloorFilter(RestaurantFloorFilter filter) {
    return updateFilters((filters) => filters.copyWith(floor: filter));
  }

  bool selectKitchenFilter(RestaurantKitchenFilter filter) {
    return updateFilters((filters) => filters.copyWith(kitchen: filter));
  }

  bool selectReservationFilter(RestaurantReservationFilter filter) {
    return updateFilters((filters) => filters.copyWith(reservations: filter));
  }

  bool selectMenuFilter(RestaurantMenuFilter filter) {
    return updateFilters((filters) => filters.copyWith(menu: filter));
  }

  bool setMenuSearchQuery(String query) {
    return updateFilters((filters) => filters.copyWith(menuSearchQuery: query));
  }

  bool setReservationSearchQuery(String query) {
    return updateFilters(
      (filters) => filters.copyWith(reservationSearchQuery: query),
    );
  }

  bool selectMenuSort(RestaurantMenuSort sort) {
    return updateFilters((filters) => filters.copyWith(menuSort: sort));
  }

  bool selectTaskFilter(RestaurantTaskFilter filter) {
    return updateFilters((filters) => filters.copyWith(task: filter));
  }

  bool selectActivityFilter(RestaurantActivityFilter filter) {
    return updateFilters((filters) => filters.copyWith(activity: filter));
  }

  bool clearLens(RestaurantWorkspaceActiveLens lens) {
    return updateFilters((filters) => filters.withoutLens(lens.kind));
  }

  bool clearMenuSearch() {
    if (!_preferences.filters.hasMenuSearchQuery) return false;
    return updateFilters((filters) => filters.copyWith(menuSearchQuery: ''));
  }

  bool clearReservationSearch() {
    if (!_preferences.filters.hasReservationSearchQuery) return false;
    return updateFilters(
      (filters) => filters.copyWith(reservationSearchQuery: ''),
    );
  }

  bool resetFilters() {
    if (!_preferences.filters.hasActivePreferences) return false;
    return setFilters(const RestaurantWorkspacePanelFilters());
  }

  bool _setPreferences(RestaurantWorkspacePreferences preferences) {
    if (preferences == _preferences) return false;
    _preferences = preferences;
    notifyListeners();
    return true;
  }
}
