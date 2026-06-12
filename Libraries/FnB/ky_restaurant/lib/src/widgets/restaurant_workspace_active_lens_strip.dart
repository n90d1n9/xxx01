import 'package:flutter/material.dart';

import '../models/restaurant_workspace_panel_filters.dart';
import '../models/restaurant_workspace_view.dart';
import 'restaurant_workspace_command_chips.dart';

class RestaurantWorkspaceActiveLensStrip extends StatelessWidget {
  const RestaurantWorkspaceActiveLensStrip({
    super.key,
    required this.lenses,
    required this.selectedView,
    this.availableViews = const [],
    this.onClear,
    this.onSelected,
  });

  final Iterable<RestaurantWorkspaceActiveLens> lenses;
  final RestaurantWorkspaceView selectedView;
  final Iterable<RestaurantWorkspaceView> availableViews;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onClear;
  final ValueChanged<RestaurantWorkspaceActiveLens>? onSelected;

  @override
  Widget build(BuildContext context) {
    final items = lenses.toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();

    final availableViewSet = availableViews.toSet();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final lens in items)
          RestaurantWorkspaceActiveLensChip(
            lens: lens,
            onClear: onClear,
            onSelected: _lensSelectionAction(lens, availableViewSet),
            openTooltip: _lensOpenTooltip(lens, availableViewSet),
          ),
      ],
    );
  }

  ValueChanged<RestaurantWorkspaceActiveLens>? _lensSelectionAction(
    RestaurantWorkspaceActiveLens lens,
    Set<RestaurantWorkspaceView> availableViewSet,
  ) {
    if (onSelected == null) return null;
    if (!_canOpenLens(lens, availableViewSet)) return null;
    return onSelected;
  }

  bool _canOpenLens(
    RestaurantWorkspaceActiveLens lens,
    Set<RestaurantWorkspaceView> availableViewSet,
  ) {
    final targetView = lens.targetView;
    if (targetView == selectedView) return false;
    return availableViewSet.isEmpty || availableViewSet.contains(targetView);
  }

  String _lensOpenTooltip(
    RestaurantWorkspaceActiveLens lens,
    Set<RestaurantWorkspaceView> availableViewSet,
  ) {
    final targetView = lens.targetView;
    if (availableViewSet.isNotEmpty && !availableViewSet.contains(targetView)) {
      return '${targetView.title} unavailable';
    }
    if (targetView == selectedView) {
      return 'Already viewing ${targetView.title}';
    }
    return 'Open ${targetView.title}';
  }
}
