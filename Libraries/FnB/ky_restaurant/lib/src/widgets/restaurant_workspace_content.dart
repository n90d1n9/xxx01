import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_operation_activity.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_panel_focus.dart';
import '../models/restaurant_workspace_panel_plan.dart';
import '../models/restaurant_workspace_view.dart';
import 'workspace_panel_deck.dart';

/// Selects and wires the operating panels shown for the active workspace view.
class RestaurantWorkspaceContent extends StatelessWidget {
  const RestaurantWorkspaceContent({
    super.key,
    required this.snapshot,
    required this.selectedView,
    this.activities = const [],
    this.filters = const RestaurantWorkspacePanelFilters(),
    this.panelFocus,
    this.panelActions = const RestaurantWorkspacePanelActions(),
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantWorkspaceView selectedView;
  final List<RestaurantOperationActivity> activities;
  final RestaurantWorkspacePanelFilters filters;
  final RestaurantWorkspacePanelFocus? panelFocus;
  final RestaurantWorkspacePanelActions panelActions;

  @override
  Widget build(BuildContext context) {
    return RestaurantWorkspacePanelDeck(
      plan: RestaurantWorkspacePanelPlan.forView(selectedView),
      snapshot: snapshot,
      activities: activities,
      filters: filters,
      panelFocus: panelFocus,
      actions: panelActions,
    );
  }
}
