import 'package:flutter/material.dart';

import '../models/restaurant_activity_filter.dart';
import '../models/restaurant_floor_filter.dart';
import '../models/restaurant_kitchen_filter.dart';
import '../models/restaurant_menu_filter.dart';
import '../models/restaurant_menu_sort.dart';
import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_reservation.dart';
import '../models/restaurant_reservation_filter.dart';
import '../models/restaurant_task_filter.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_panel_plan.dart';
import 'restaurant_activity_panel.dart';
import 'restaurant_briefing_panel.dart';
import 'restaurant_floor_panel.dart';
import 'restaurant_kitchen_panel.dart';
import 'restaurant_menu_panel.dart';
import 'restaurant_reservation_panel.dart';
import 'restaurant_service_panel.dart';
import 'restaurant_task_panel.dart';
import 'reservation_qr_panel_binding.dart';
import 'workspace_panel_layout.dart';

/// Groups interaction handlers used by workspace operating panels.
@immutable
class RestaurantWorkspacePanelActions {
  const RestaurantWorkspacePanelActions({
    this.onBriefingActionSelected,
    this.onCompleteTask,
    this.onResolveMenuRisk,
    this.onReviewCatalogItem,
    this.onReviewRecipeProduction,
    this.onStationStatusChanged,
    this.onZoneStatusChanged,
    this.onReservationStatusChanged,
    this.onFloorFilterChanged,
    this.onKitchenFilterChanged,
    this.onReservationFilterChanged,
    this.onMenuFilterChanged,
    this.onMenuSearchQueryChanged,
    this.onReservationSearchQueryChanged,
    this.onMenuSortChanged,
    this.onTaskFilterChanged,
    this.onActivityFilterChanged,
    this.reservationQrPanelBinding,
  });

  final ValueChanged<RestaurantBriefingAction>? onBriefingActionSelected;
  final ValueChanged<String>? onCompleteTask;
  final ValueChanged<String>? onResolveMenuRisk;
  final ValueChanged<String>? onReviewCatalogItem;
  final ValueChanged<String>? onReviewRecipeProduction;
  final void Function(String stationId, RestaurantServiceStatus status)?
  onStationStatusChanged;
  final void Function(String zoneId, RestaurantServiceStatus status)?
  onZoneStatusChanged;
  final void Function(String reservationId, RestaurantReservationStatus status)?
  onReservationStatusChanged;
  final ValueChanged<RestaurantFloorFilter>? onFloorFilterChanged;
  final ValueChanged<RestaurantKitchenFilter>? onKitchenFilterChanged;
  final ValueChanged<RestaurantReservationFilter>? onReservationFilterChanged;
  final ValueChanged<RestaurantMenuFilter>? onMenuFilterChanged;
  final ValueChanged<String>? onMenuSearchQueryChanged;
  final ValueChanged<String>? onReservationSearchQueryChanged;
  final ValueChanged<RestaurantMenuSort>? onMenuSortChanged;
  final ValueChanged<RestaurantTaskFilter>? onTaskFilterChanged;
  final ValueChanged<RestaurantActivityFilter>? onActivityFilterChanged;
  final RestaurantReservationQrPanelBinding? reservationQrPanelBinding;
}

/// Renders the operating panel widgets declared by a workspace panel plan.
class RestaurantWorkspacePanelDeck extends StatelessWidget {
  const RestaurantWorkspacePanelDeck({
    super.key,
    required this.plan,
    required this.snapshot,
    this.activities = const [],
    this.filters = const RestaurantWorkspacePanelFilters(),
    this.panelFocus,
    this.actions = const RestaurantWorkspacePanelActions(),
  });

  final RestaurantWorkspacePanelPlan plan;
  final RestaurantOperatingSnapshot snapshot;
  final List<RestaurantOperationActivity> activities;
  final RestaurantWorkspacePanelFilters filters;
  final RestaurantWorkspacePanelFocus? panelFocus;
  final RestaurantWorkspacePanelActions actions;

  @override
  Widget build(BuildContext context) {
    return RestaurantWorkspacePanelLayout(
      panels: [for (final slot in plan.slots) _panelForSlot(slot)],
    );
  }

  Widget _panelForSlot(RestaurantWorkspacePanelSlot slot) {
    return switch (slot) {
      RestaurantWorkspacePanelSlot.service => RestaurantServicePanel(
        snapshot: snapshot,
      ),
      RestaurantWorkspacePanelSlot.briefing => RestaurantBriefingPanel(
        snapshot: snapshot,
        onActionSelected: actions.onBriefingActionSelected,
      ),
      RestaurantWorkspacePanelSlot.floor => RestaurantFloorPanel(
        zones: snapshot.zones,
        onZoneStatusChanged: actions.onZoneStatusChanged,
        selectedFilter: filters.floor,
        onFilterChanged: actions.onFloorFilterChanged,
        focusedZoneId: _focusedId(RestaurantWorkspacePanelFocusKind.floorZone),
      ),
      RestaurantWorkspacePanelSlot.reservations => RestaurantReservationPanel(
        reservations: snapshot.reservations,
        onStatusChanged: actions.onReservationStatusChanged,
        selectedFilter: filters.reservations,
        onFilterChanged: actions.onReservationFilterChanged,
        searchQuery: filters.reservationSearchQuery,
        onSearchQueryChanged: actions.onReservationSearchQueryChanged,
        qrPanelBinding: actions.reservationQrPanelBinding,
        focusedReservationId: _focusedId(
          RestaurantWorkspacePanelFocusKind.reservation,
        ),
      ),
      RestaurantWorkspacePanelSlot.kitchen => RestaurantKitchenPanel(
        stations: snapshot.stations,
        menu: snapshot.menu,
        recipes: snapshot.recipes,
        onStationStatusChanged: actions.onStationStatusChanged,
        onReviewRecipeProduction: actions.onReviewRecipeProduction,
        selectedFilter: filters.kitchen,
        onFilterChanged: actions.onKitchenFilterChanged,
        focusedStationId: _focusedId(
          RestaurantWorkspacePanelFocusKind.kitchenStation,
        ),
        focusedRecipeProductionId: _focusedId(
          RestaurantWorkspacePanelFocusKind.recipeProduction,
        ),
      ),
      RestaurantWorkspacePanelSlot.task => RestaurantTaskPanel(
        tasks: snapshot.tasks,
        onCompleteTask: actions.onCompleteTask,
        selectedFilter: filters.task,
        onFilterChanged: actions.onTaskFilterChanged,
        focusedTaskId: _focusedId(RestaurantWorkspacePanelFocusKind.shiftTask),
      ),
      RestaurantWorkspacePanelSlot.menu => RestaurantMenuPanel(
        signals: snapshot.menuSignals,
        menu: snapshot.menu,
        recipes: snapshot.recipes,
        stations: snapshot.stations,
        onResolveMenuRisk: actions.onResolveMenuRisk,
        onReviewCatalogItem: actions.onReviewCatalogItem,
        selectedFilter: filters.menu,
        onFilterChanged: actions.onMenuFilterChanged,
        searchQuery: filters.menuSearchQuery,
        onSearchQueryChanged: actions.onMenuSearchQueryChanged,
        selectedSort: filters.menuSort,
        onSortChanged: actions.onMenuSortChanged,
        focusedSignalId: _focusedId(
          RestaurantWorkspacePanelFocusKind.menuSignal,
        ),
        focusedCatalogItemId: _focusedId(
          RestaurantWorkspacePanelFocusKind.menuCatalogItem,
        ),
      ),
      RestaurantWorkspacePanelSlot.activity => RestaurantActivityPanel(
        activities: activities,
        selectedFilter: filters.activity,
        onFilterChanged: actions.onActivityFilterChanged,
      ),
    };
  }

  String? _focusedId(RestaurantWorkspacePanelFocusKind kind) {
    final focus = panelFocus;
    if (focus == null || focus.kind != kind) return null;
    return focus.targetId;
  }
}
