import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_task_filter.dart';
import '../models/restaurant_workspace_navigation_target.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';

/// Resolves cross-FnB attention signals into restaurant workspace destinations.
class RestaurantAttentionSignalTargetResolver {
  const RestaurantAttentionSignalTargetResolver();

  RestaurantWorkspaceNavigationTarget resolve(
    RestaurantAttentionSignal signal,
  ) {
    return switch (signal.kind) {
      RestaurantAttentionSignalKind.floorZone =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.floor,
          filters: const RestaurantWorkspacePanelFilters(
            floor: RestaurantFloorFilter.attention,
            activity: RestaurantActivityFilter.floor,
          ),
          focus: _focusFor(signal, RestaurantWorkspacePanelFocusKind.floorZone),
        ),
      RestaurantAttentionSignalKind.reservation =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.reservations,
          filters: RestaurantWorkspacePanelFilters(
            reservations: _reservationFilterFor(signal),
            activity: RestaurantActivityFilter.reservations,
          ),
          focus: _focusFor(
            signal,
            RestaurantWorkspacePanelFocusKind.reservation,
          ),
        ),
      RestaurantAttentionSignalKind.kitchenStation ||
      RestaurantAttentionSignalKind.recipeProduction =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.kitchen,
          filters: const RestaurantWorkspacePanelFilters(
            kitchen: RestaurantKitchenFilter.pressure,
            activity: RestaurantActivityFilter.kitchen,
          ),
          focus: _focusFor(signal, _kitchenFocusKind(signal)),
        ),
      RestaurantAttentionSignalKind.menuRisk =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.menu,
          filters: const RestaurantWorkspacePanelFilters(
            menu: RestaurantMenuFilter.risk,
            activity: RestaurantActivityFilter.menu,
            menuSort: RestaurantMenuSort.risk,
          ),
          focus: _focusFor(
            signal,
            RestaurantWorkspacePanelFocusKind.menuSignal,
          ),
        ),
      RestaurantAttentionSignalKind.menuCatalog =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.menu,
          filters: const RestaurantWorkspacePanelFilters(
            activity: RestaurantActivityFilter.menu,
          ),
          focus: _focusFor(
            signal,
            RestaurantWorkspacePanelFocusKind.menuCatalogItem,
          ),
        ),
      RestaurantAttentionSignalKind.shiftTask =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.pulse,
          filters: const RestaurantWorkspacePanelFilters(
            task: RestaurantTaskFilter.attention,
            activity: RestaurantActivityFilter.tasks,
          ),
          focus: _focusFor(signal, RestaurantWorkspacePanelFocusKind.shiftTask),
        ),
      RestaurantAttentionSignalKind.serviceAlert ||
      RestaurantAttentionSignalKind.custom =>
        RestaurantWorkspaceNavigationTarget(
          view: RestaurantWorkspaceView.pulse,
          focus: _focusFor(signal, _fallbackFocusKind(signal)),
        ),
    };
  }

  bool canOpen(
    RestaurantAttentionSignal signal,
    RestaurantWorkspaceViewAvailability viewAvailability,
  ) {
    return viewAvailability.contains(resolve(signal).view);
  }

  RestaurantAttentionSignal? selectedSignalFor({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters selectedFilters,
    required Iterable<RestaurantAttentionSignal> signals,
    RestaurantWorkspaceViewAvailability? viewAvailability,
    RestaurantWorkspacePanelFocus? selectedFocus,
  }) {
    if (selectedFocus != null) {
      for (final signal in signals) {
        if (viewAvailability != null && !canOpen(signal, viewAvailability)) {
          continue;
        }
        if (resolve(signal).focus == selectedFocus) return signal;
      }
    }

    for (final signal in signals) {
      final target = resolve(signal);
      if (viewAvailability != null && !canOpen(signal, viewAvailability)) {
        continue;
      }
      if (target.matches(
        selectedView: selectedView,
        selectedFilters: selectedFilters,
      )) {
        return signal;
      }
    }
    return null;
  }

  RestaurantWorkspacePanelFocus? _focusFor(
    RestaurantAttentionSignal signal,
    RestaurantWorkspacePanelFocusKind kind,
  ) {
    final targetId = signal.targetId ?? signal.sourceId;
    if (targetId == null || targetId.isEmpty) return null;

    return RestaurantWorkspacePanelFocus(
      kind: kind,
      targetId: targetId,
      sourceId: signal.id,
    );
  }

  RestaurantWorkspacePanelFocusKind _kitchenFocusKind(
    RestaurantAttentionSignal signal,
  ) {
    return signal.kind == RestaurantAttentionSignalKind.recipeProduction
        ? RestaurantWorkspacePanelFocusKind.recipeProduction
        : RestaurantWorkspacePanelFocusKind.kitchenStation;
  }

  RestaurantWorkspacePanelFocusKind _fallbackFocusKind(
    RestaurantAttentionSignal signal,
  ) {
    return signal.kind == RestaurantAttentionSignalKind.serviceAlert
        ? RestaurantWorkspacePanelFocusKind.serviceAlert
        : RestaurantWorkspacePanelFocusKind.custom;
  }

  RestaurantReservationFilter _reservationFilterFor(
    RestaurantAttentionSignal signal,
  ) {
    if (signal.status == RestaurantServiceStatus.critical) {
      return RestaurantReservationFilter.late;
    }
    if (signal.tags.contains('VIP')) {
      return RestaurantReservationFilter.vip;
    }
    return RestaurantReservationFilter.upcoming;
  }
}
