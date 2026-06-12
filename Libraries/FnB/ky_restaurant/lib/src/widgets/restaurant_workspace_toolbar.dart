import 'package:flutter/material.dart';

import '../models/restaurant_workspace_view.dart';
import 'restaurant_view_switcher.dart';
import 'restaurant_workspace_state_views.dart';

class RestaurantWorkspaceToolbar extends StatelessWidget {
  const RestaurantWorkspaceToolbar({
    super.key,
    required this.selectedView,
    required this.availableViews,
    required this.isRefreshing,
    required this.onViewChanged,
    required this.onRefresh,
  });

  static const compactBreakpoint = 420.0;

  final RestaurantWorkspaceView selectedView;
  final List<RestaurantWorkspaceView> availableViews;
  final bool isRefreshing;
  final ValueChanged<RestaurantWorkspaceView> onViewChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final viewSwitcher = RestaurantViewSwitcher(
      selectedView: selectedView,
      views: availableViews,
      onChanged: onViewChanged,
    );
    final refreshButton = RestaurantWorkspaceRefreshButton(
      onRefresh: onRefresh,
      isRefreshing: isRefreshing,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < compactBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [viewSwitcher, const SizedBox(height: 8), refreshButton],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: viewSwitcher),
            const SizedBox(width: 12),
            refreshButton,
          ],
        );
      },
    );
  }
}
