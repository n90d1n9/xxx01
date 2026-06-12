import 'restaurant_workspace_view.dart';

class RestaurantWorkspaceViewAvailability {
  factory RestaurantWorkspaceViewAvailability.fromViews(
    Iterable<RestaurantWorkspaceView> views, {
    bool useAllWhenEmpty = false,
  }) {
    final source = views.isEmpty && useAllWhenEmpty
        ? RestaurantWorkspaceView.values
        : views;
    final seen = <RestaurantWorkspaceView>{};

    return RestaurantWorkspaceViewAvailability._(
      List.unmodifiable([
        for (final view in source)
          if (seen.add(view)) view,
      ]),
    );
  }

  const RestaurantWorkspaceViewAvailability._(this.views);

  final List<RestaurantWorkspaceView> views;

  bool get isEmpty => views.isEmpty;

  bool contains(RestaurantWorkspaceView view) => views.contains(view);

  RestaurantWorkspaceView? fallback({RestaurantWorkspaceView? preferred}) {
    if (views.isEmpty) return null;
    if (preferred != null && contains(preferred)) return preferred;
    return views.first;
  }

  RestaurantWorkspaceView? selectedOrFallback(
    RestaurantWorkspaceView selectedView, {
    RestaurantWorkspaceView? preferredFallback,
  }) {
    if (contains(selectedView)) return selectedView;
    return fallback(preferred: preferredFallback);
  }
}
