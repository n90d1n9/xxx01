import 'package:flutter/material.dart';

import '../models/restaurant_workspace_view.dart';
import '../models/restaurant_workspace_view_availability.dart';

class RestaurantViewSwitcher extends StatelessWidget {
  const RestaurantViewSwitcher({
    super.key,
    required this.selectedView,
    required this.onChanged,
    this.views = RestaurantWorkspaceView.values,
  });

  final RestaurantWorkspaceView selectedView;
  final ValueChanged<RestaurantWorkspaceView> onChanged;
  final List<RestaurantWorkspaceView> views;

  @override
  Widget build(BuildContext context) {
    final availability = RestaurantWorkspaceViewAvailability.fromViews(views);
    if (availability.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveSelectedView = availability.selectedOrFallback(
      selectedView,
    )!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<RestaurantWorkspaceView>(
        showSelectedIcon: false,
        segments: availability.views
            .map(
              (view) => ButtonSegment(
                value: view,
                icon: Icon(view.icon, size: 18),
                label: Text(view.title),
                tooltip: view.subtitle,
              ),
            )
            .toList(growable: false),
        selected: {effectiveSelectedView},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}
