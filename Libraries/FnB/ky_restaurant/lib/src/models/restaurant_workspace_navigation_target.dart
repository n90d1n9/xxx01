import 'restaurant_operational_briefing.dart';
import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_panel_focus.dart';
import 'restaurant_workspace_view.dart';

/// Describes the workspace view and lens state opened by a navigation action.
class RestaurantWorkspaceNavigationTarget {
  const RestaurantWorkspaceNavigationTarget({
    required this.view,
    this.filters = const RestaurantWorkspacePanelFilters(),
    this.focus,
  });

  final RestaurantWorkspaceView view;
  final RestaurantWorkspacePanelFilters filters;
  final RestaurantWorkspacePanelFocus? focus;

  bool matches({
    required RestaurantWorkspaceView selectedView,
    required RestaurantWorkspacePanelFilters selectedFilters,
  }) {
    return view == selectedView && filters == selectedFilters;
  }

  static RestaurantWorkspaceNavigationTarget forBriefingItem(
    RestaurantBriefingItem item,
  ) {
    return forBriefingCategory(item.category);
  }

  static RestaurantWorkspaceNavigationTarget forBriefingCategory(
    RestaurantBriefingCategory category,
  ) {
    return RestaurantWorkspaceNavigationTarget(
      view: switch (category) {
        RestaurantBriefingCategory.floor => RestaurantWorkspaceView.floor,
        RestaurantBriefingCategory.reservations =>
          RestaurantWorkspaceView.reservations,
        RestaurantBriefingCategory.kitchen => RestaurantWorkspaceView.kitchen,
        RestaurantBriefingCategory.menu => RestaurantWorkspaceView.menu,
        RestaurantBriefingCategory.overview ||
        RestaurantBriefingCategory.task => RestaurantWorkspaceView.pulse,
      },
    );
  }

  static RestaurantWorkspaceNavigationTarget forActiveLens(
    RestaurantWorkspaceActiveLens lens,
  ) {
    return RestaurantWorkspaceNavigationTarget(view: lens.targetView);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RestaurantWorkspaceNavigationTarget &&
            other.view == view &&
            other.filters == filters &&
            other.focus == focus;
  }

  @override
  int get hashCode => Object.hash(view, filters, focus);
}
