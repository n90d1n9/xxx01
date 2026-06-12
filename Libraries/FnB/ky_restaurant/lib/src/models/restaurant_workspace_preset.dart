import 'package:flutter/material.dart';

import 'restaurant_activity_filter.dart';
import 'restaurant_floor_filter.dart';
import 'restaurant_kitchen_filter.dart';
import 'restaurant_menu_filter.dart';
import 'restaurant_menu_sort.dart';
import 'restaurant_task_filter.dart';
import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_view.dart';

enum RestaurantWorkspacePreset {
  servicePulse,
  rushWatch,
  floorRecovery,
  menuRisk,
  marginFocus,
  kitchenLoad;

  String get id => switch (this) {
    RestaurantWorkspacePreset.servicePulse => 'service-pulse',
    RestaurantWorkspacePreset.rushWatch => 'rush-watch',
    RestaurantWorkspacePreset.floorRecovery => 'floor-recovery',
    RestaurantWorkspacePreset.menuRisk => 'menu-risk',
    RestaurantWorkspacePreset.marginFocus => 'margin-focus',
    RestaurantWorkspacePreset.kitchenLoad => 'kitchen-load',
  };

  String get label => switch (this) {
    RestaurantWorkspacePreset.servicePulse => 'Service pulse',
    RestaurantWorkspacePreset.rushWatch => 'Rush watch',
    RestaurantWorkspacePreset.floorRecovery => 'Floor recovery',
    RestaurantWorkspacePreset.menuRisk => 'Menu risk',
    RestaurantWorkspacePreset.marginFocus => 'Margin focus',
    RestaurantWorkspacePreset.kitchenLoad => 'Kitchen load',
  };

  String get description => switch (this) {
    RestaurantWorkspacePreset.servicePulse => 'Default cross-team overview',
    RestaurantWorkspacePreset.rushWatch =>
      'Attention across floor, kitchen, menu, and tasks',
    RestaurantWorkspacePreset.floorRecovery =>
      'Waitlist, floor activity, and urgent follow-up',
    RestaurantWorkspacePreset.menuRisk => 'Sell-out risk sorted by urgency',
    RestaurantWorkspacePreset.marginFocus =>
      'High-margin menu movers sorted first',
    RestaurantWorkspacePreset.kitchenLoad =>
      'Delayed stations, open work, and quick prep wins',
  };

  IconData get icon => switch (this) {
    RestaurantWorkspacePreset.servicePulse => Icons.monitor_heart_outlined,
    RestaurantWorkspacePreset.rushWatch => Icons.bolt_outlined,
    RestaurantWorkspacePreset.floorRecovery => Icons.table_restaurant_outlined,
    RestaurantWorkspacePreset.menuRisk => Icons.warning_amber_rounded,
    RestaurantWorkspacePreset.marginFocus => Icons.trending_up_rounded,
    RestaurantWorkspacePreset.kitchenLoad => Icons.soup_kitchen_outlined,
  };

  RestaurantWorkspaceView get view => switch (this) {
    RestaurantWorkspacePreset.servicePulse => RestaurantWorkspaceView.pulse,
    RestaurantWorkspacePreset.rushWatch => RestaurantWorkspaceView.pulse,
    RestaurantWorkspacePreset.floorRecovery => RestaurantWorkspaceView.floor,
    RestaurantWorkspacePreset.menuRisk => RestaurantWorkspaceView.menu,
    RestaurantWorkspacePreset.marginFocus => RestaurantWorkspaceView.menu,
    RestaurantWorkspacePreset.kitchenLoad => RestaurantWorkspaceView.kitchen,
  };

  RestaurantWorkspacePanelFilters get filters => switch (this) {
    RestaurantWorkspacePreset.servicePulse =>
      const RestaurantWorkspacePanelFilters(),
    RestaurantWorkspacePreset.rushWatch =>
      const RestaurantWorkspacePanelFilters(
        floor: RestaurantFloorFilter.attention,
        kitchen: RestaurantKitchenFilter.pressure,
        menu: RestaurantMenuFilter.risk,
        task: RestaurantTaskFilter.attention,
        menuSort: RestaurantMenuSort.risk,
      ),
    RestaurantWorkspacePreset.floorRecovery =>
      const RestaurantWorkspacePanelFilters(
        floor: RestaurantFloorFilter.waitlist,
        task: RestaurantTaskFilter.attention,
        activity: RestaurantActivityFilter.floor,
      ),
    RestaurantWorkspacePreset.menuRisk => const RestaurantWorkspacePanelFilters(
      menu: RestaurantMenuFilter.risk,
      activity: RestaurantActivityFilter.menu,
      menuSort: RestaurantMenuSort.risk,
    ),
    RestaurantWorkspacePreset.marginFocus =>
      const RestaurantWorkspacePanelFilters(
        menu: RestaurantMenuFilter.margin,
        menuSort: RestaurantMenuSort.margin,
      ),
    RestaurantWorkspacePreset.kitchenLoad =>
      const RestaurantWorkspacePanelFilters(
        kitchen: RestaurantKitchenFilter.delayed,
        menu: RestaurantMenuFilter.quick,
        task: RestaurantTaskFilter.open,
        activity: RestaurantActivityFilter.kitchen,
        menuSort: RestaurantMenuSort.prep,
      ),
  };

  bool matches({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
  }) {
    return selectedView == view && filters == this.filters;
  }

  static RestaurantWorkspacePreset? selectedFor({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
    Iterable<RestaurantWorkspacePreset> presets =
        RestaurantWorkspacePreset.values,
  }) {
    for (final preset in presets) {
      if (preset.matches(selectedView: selectedView, filters: filters)) {
        return preset;
      }
    }
    return null;
  }
}
