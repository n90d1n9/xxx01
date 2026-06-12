import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_preset.dart';
import '../models/restaurant_workspace_view.dart';
import 'restaurant_workspace_command_bar.dart';
import 'restaurant_workspace_header.dart';
import 'restaurant_workspace_preset_bar.dart';
import 'restaurant_workspace_state_views.dart';
import 'restaurant_workspace_toolbar.dart';

/// Composes the loaded workspace controls for switching views and lenses.
class RestaurantWorkspaceControlsSection extends StatelessWidget {
  const RestaurantWorkspaceControlsSection({
    super.key,
    required this.snapshot,
    required this.selectedView,
    required this.filters,
    required this.availableViews,
    required this.availablePresets,
    required this.onRefresh,
    required this.onViewChanged,
    required this.onPresetSelected,
    this.updatedAt,
    this.isRefreshing = false,
    this.selectedPreset,
    this.onReset,
    this.onClearLens,
    this.onLensSelected,
    this.onClearMenuSearch,
    this.onClearReservationSearch,
  });

  final RestaurantOperatingSnapshot snapshot;
  final RestaurantWorkspaceView selectedView;
  final RestaurantWorkspacePanelFilters filters;
  final List<RestaurantWorkspaceView> availableViews;
  final List<RestaurantWorkspacePreset> availablePresets;
  final VoidCallback onRefresh;
  final ValueChanged<RestaurantWorkspaceView> onViewChanged;
  final ValueChanged<RestaurantWorkspacePreset> onPresetSelected;
  final DateTime? updatedAt;
  final bool isRefreshing;
  final RestaurantWorkspacePreset? selectedPreset;
  final VoidCallback? onReset;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onClearLens;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onLensSelected;
  final VoidCallback? onClearMenuSearch;
  final VoidCallback? onClearReservationSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RestaurantWorkspaceHeader(snapshot: snapshot),
        const SizedBox(height: 16),
        RestaurantWorkspaceToolbar(
          selectedView: selectedView,
          availableViews: availableViews,
          isRefreshing: isRefreshing,
          onViewChanged: onViewChanged,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 12),
        RestaurantWorkspaceFreshnessNotice(
          updatedAt: updatedAt,
          isRefreshing: isRefreshing,
        ),
        const SizedBox(height: 12),
        RestaurantWorkspaceCommandBar(
          selectedView: selectedView,
          filters: filters,
          isRefreshing: isRefreshing,
          reservationZoneLabels: snapshot.reservations.map(
            (reservation) => reservation.zoneLabel,
          ),
          availableViews: availableViews,
          onReset: onReset,
          onClearLens: onClearLens,
          onLensSelected: onLensSelected,
          onClearMenuSearch: onClearMenuSearch,
          onClearReservationSearch: onClearReservationSearch,
        ),
        if (availablePresets.isNotEmpty) ...[
          const SizedBox(height: 12),
          RestaurantWorkspacePresetBar(
            presets: availablePresets,
            selectedPreset: selectedPreset,
            onPresetSelected: onPresetSelected,
          ),
        ],
      ],
    );
  }
}
