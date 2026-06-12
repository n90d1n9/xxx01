import 'package:flutter/material.dart';

import '../models/workspace_ready_view_data.dart';
import 'restaurant_workspace_content.dart';
import 'workspace_panel_deck.dart';
import 'workspace_overview_section.dart';
import 'workspace_controls_section.dart';
import 'workspace_ready_view_callbacks.dart';

/// Displays the fully loaded restaurant workspace with controls and panels.
class RestaurantWorkspaceReadyView extends StatelessWidget {
  const RestaurantWorkspaceReadyView({
    super.key,
    required this.data,
    required this.controls,
    this.overviewCallbacks = const RestaurantWorkspaceOverviewCallbacks(),
    this.panelActions = const RestaurantWorkspacePanelActions(),
  });

  final RestaurantWorkspaceReadyViewData data;
  final RestaurantWorkspaceControlCallbacks controls;
  final RestaurantWorkspaceOverviewCallbacks overviewCallbacks;
  final RestaurantWorkspacePanelActions panelActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantWorkspaceControlsSection(
          snapshot: data.snapshot,
          updatedAt: data.updatedAt,
          isRefreshing: data.isRefreshing,
          selectedView: data.selectedView,
          filters: data.filters,
          availableViews: data.availableViews,
          availablePresets: data.availablePresets,
          selectedPreset: data.selectedPreset,
          onRefresh: controls.onRefresh,
          onViewChanged: controls.onViewChanged,
          onPresetSelected: controls.onPresetSelected,
          onReset: controls.onReset,
          onClearLens: controls.onClearLens,
          onLensSelected: controls.onLensSelected,
          onClearMenuSearch: controls.onClearMenuSearch,
          onClearReservationSearch: controls.onClearReservationSearch,
        ),
        const SizedBox(height: 12),
        RestaurantWorkspaceOverviewSection(
          snapshot: data.snapshot,
          attentionQueue: data.attentionQueue,
          insights: data.insights,
          selectedInsight: data.selectedInsight,
          selectedAttentionSignal: data.selectedAttentionSignal,
          onBriefingItemSelected: overviewCallbacks.onBriefingItemSelected,
          onInsightSelected: overviewCallbacks.onInsightSelected,
          onAttentionSignalSelected:
              overviewCallbacks.onAttentionSignalSelected,
        ),
        const SizedBox(height: 16),
        RestaurantWorkspaceContent(
          snapshot: data.snapshot,
          selectedView: data.selectedView,
          activities: data.activities,
          filters: data.filters,
          panelFocus: data.panelFocus,
          panelActions: panelActions,
        ),
      ],
    );
  }
}
