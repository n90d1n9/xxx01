import 'package:flutter/material.dart';

import '../models/restaurant_workspace_command_summary.dart';
import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_view.dart';
import 'command_center_header.dart';
import 'restaurant_workspace_active_lens_strip.dart';
import 'restaurant_workspace_command_chips.dart';

/// Shows workspace command state, active lenses, and reset controls.
class RestaurantWorkspaceCommandBar extends StatelessWidget {
  const RestaurantWorkspaceCommandBar({
    super.key,
    required this.selectedView,
    required this.filters,
    this.isRefreshing = false,
    this.onReset,
    this.onClearLens,
    this.onLensSelected,
    this.onClearMenuSearch,
    this.onClearReservationSearch,
    this.reservationZoneLabels = const [],
    this.availableViews = const [],
  });

  final RestaurantWorkspaceView selectedView;
  final RestaurantWorkspacePanelFilters filters;
  final bool isRefreshing;
  final Iterable<String> reservationZoneLabels;
  final VoidCallback? onReset;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onClearLens;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onLensSelected;
  final VoidCallback? onClearMenuSearch;
  final VoidCallback? onClearReservationSearch;
  final Iterable<RestaurantWorkspaceView> availableViews;

  @override
  Widget build(BuildContext context) {
    final summary = RestaurantWorkspaceCommandSummary.fromWorkspace(
      selectedView: selectedView,
      filters: filters,
      isRefreshing: isRefreshing,
      reservationZoneLabels: reservationZoneLabels,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final canReset = summary.hasActiveState && onReset != null;

    return Semantics(
      container: true,
      label: _commandCenterSemanticsLabel(summary),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colors.primary.withValues(alpha: .035),
            colors.surface,
          ),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: .7),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tune_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RestaurantWorkspaceCommandCenterHeader(
                      activeStateLabel: summary.activeStateLabel,
                      canReset: canReset,
                      onReset: onReset,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final signal in summary.signals)
                          RestaurantWorkspaceCommandSignalChip(
                            signal: signal,
                            clearTooltip: _clearSignalTooltip(signal.kind),
                            onClear: _clearSignalAction(signal.kind),
                          ),
                      ],
                    ),
                    if (summary.activeLenses.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      RestaurantWorkspaceActiveLensStrip(
                        lenses: summary.activeLenses,
                        selectedView: selectedView,
                        availableViews: availableViews,
                        onClear: onClearLens,
                        onSelected: onLensSelected,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _clearSignalAction(RestaurantWorkspaceCommandSignalKind kind) {
    return switch (kind) {
      RestaurantWorkspaceCommandSignalKind.menuSearch => onClearMenuSearch,
      RestaurantWorkspaceCommandSignalKind.reservationSearch =>
        onClearReservationSearch,
      _ => null,
    };
  }

  String _clearSignalTooltip(RestaurantWorkspaceCommandSignalKind kind) {
    return switch (kind) {
      RestaurantWorkspaceCommandSignalKind.menuSearch => 'Clear menu search',
      RestaurantWorkspaceCommandSignalKind.reservationSearch =>
        'Clear reservation search',
      _ => 'Clear signal',
    };
  }
}

String _commandCenterSemanticsLabel(RestaurantWorkspaceCommandSummary summary) {
  final signals = summary.signals
      .map((signal) => '${signal.label} ${signal.value}')
      .join(', ');
  return 'Command center. ${summary.activeStateLabel}. $signals. ${summary.activeLensDetailLabel}.';
}
