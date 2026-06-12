import 'package:flutter/material.dart';

import 'restaurant_models.dart';
import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_view.dart';

enum RestaurantOperationalInsightKind {
  menuRisk,
  reservationRisk,
  marginLeader,
  quickPrep,
  kitchenBottleneck;

  String get label => switch (this) {
    RestaurantOperationalInsightKind.menuRisk => 'Menu risk',
    RestaurantOperationalInsightKind.reservationRisk => 'Reservation risk',
    RestaurantOperationalInsightKind.marginLeader => 'Margin leader',
    RestaurantOperationalInsightKind.quickPrep => 'Quick prep',
    RestaurantOperationalInsightKind.kitchenBottleneck => 'Kitchen load',
  };

  IconData get icon => switch (this) {
    RestaurantOperationalInsightKind.menuRisk => Icons.warning_amber_rounded,
    RestaurantOperationalInsightKind.reservationRisk =>
      Icons.event_busy_outlined,
    RestaurantOperationalInsightKind.marginLeader => Icons.trending_up_rounded,
    RestaurantOperationalInsightKind.quickPrep => Icons.speed_rounded,
    RestaurantOperationalInsightKind.kitchenBottleneck =>
      Icons.soup_kitchen_outlined,
  };
}

class RestaurantOperationalInsight {
  const RestaurantOperationalInsight({
    required this.id,
    required this.kind,
    required this.title,
    required this.valueLabel,
    required this.detail,
    required this.status,
    required this.targetView,
    this.targetFilters = const RestaurantWorkspacePanelFilters(),
  });

  final String id;
  final RestaurantOperationalInsightKind kind;
  final String title;
  final String valueLabel;
  final String detail;
  final RestaurantServiceStatus status;
  final RestaurantWorkspaceView targetView;
  final RestaurantWorkspacePanelFilters targetFilters;

  bool matches({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
  }) {
    return selectedView == targetView && filters == targetFilters;
  }

  static RestaurantOperationalInsight? selectedFor({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters filters,
    required Iterable<RestaurantOperationalInsight> insights,
  }) {
    for (final insight in insights) {
      if (insight.matches(selectedView: selectedView, filters: filters)) {
        return insight;
      }
    }
    return null;
  }
}
