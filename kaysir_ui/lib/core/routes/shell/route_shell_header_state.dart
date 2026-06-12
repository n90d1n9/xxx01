import 'package:flutter/widgets.dart';
import 'package:kaysir/core/features/feature_routes.dart';

import 'route_shell_metadata.dart';

/// Presentation state for the route shell header title area.
class RouteShellHeaderState {
  const RouteShellHeaderState({
    required this.title,
    required this.subtitle,
    required this.hasRouteContext,
    this.breadcrumbItems = const [],
  });

  static const fallbackTitle = 'Workspace';
  static const fallbackSubtitle = 'Kaysir operations';

  final String title;
  final String subtitle;
  final bool hasRouteContext;

  /// Compact route ancestry, ordered from root to leaf.
  final List<RouteShellBreadcrumbItem> breadcrumbItems;

  /// Compact labels for the active route ancestry, ordered from root to leaf.
  List<String> get breadcrumbs {
    return List.unmodifiable(breadcrumbItems.map((item) => item.label));
  }

  /// Builds header copy from registered routes and the active router location.
  factory RouteShellHeaderState.fromRoutes({
    required List<FeatureRoutes> routes,
    required BuildContext context,
  }) {
    return RouteShellHeaderState.fromCurrentPath(
      routes: routes,
      currentPath: routeShellCurrentLocation(context),
    );
  }

  /// Builds header copy from registered routes and a concrete path.
  factory RouteShellHeaderState.fromCurrentPath({
    required List<FeatureRoutes> routes,
    required String currentPath,
  }) {
    return RouteShellHeaderState.fromRouteTrail(
      routeShellRouteTrailForPath(routes, currentPath),
    );
  }

  /// Builds header copy from a selected route trail.
  factory RouteShellHeaderState.fromRouteTrail(List<FeatureRoutes> routeTrail) {
    if (routeTrail.isEmpty) {
      return const RouteShellHeaderState(
        title: fallbackTitle,
        subtitle: fallbackSubtitle,
        hasRouteContext: false,
      );
    }

    final selectedRoute = routeTrail.last;
    final selectedLabel = routeShellLabel(selectedRoute).trim();
    final routeSubtitle = selectedRoute.subtitle?.trim();
    final parentLabels = routeTrail
        .take(routeTrail.length - 1)
        .map(routeShellLabel)
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);
    final fallbackDetail =
        parentLabels.isEmpty
            ? selectedRoute.path ?? fallbackSubtitle
            : selectedLabel;
    final subtitleSegments = [
      ...parentLabels,
      if (routeSubtitle != null && routeSubtitle.isNotEmpty)
        routeSubtitle
      else
        fallbackDetail,
    ];

    final breadcrumbItems = <RouteShellBreadcrumbItem>[];
    for (var index = 0; index < routeTrail.length; index += 1) {
      final route = routeTrail[index];
      final label = routeShellLabel(route).trim();
      if (label.isEmpty) continue;

      final location = route.path?.trim();
      final isCurrent = index == routeTrail.length - 1;
      breadcrumbItems.add(
        RouteShellBreadcrumbItem(
          label: label,
          location: location == null || location.isEmpty ? null : location,
          isCurrent: isCurrent,
          canOpen:
              !isCurrent && routeShellIsVisible(route) && routeShellCanOpen(route),
        ),
      );
    }

    return RouteShellHeaderState(
      title: selectedLabel.isEmpty ? fallbackTitle : selectedLabel,
      subtitle: subtitleSegments.join(' / '),
      hasRouteContext: true,
      breadcrumbItems: List.unmodifiable(breadcrumbItems),
    );
  }
}

/// One breadcrumb item in the route shell header trail.
class RouteShellBreadcrumbItem {
  const RouteShellBreadcrumbItem({
    required this.label,
    this.location,
    this.isCurrent = false,
    this.canOpen = false,
  });

  final String label;
  final String? location;
  final bool isCurrent;
  final bool canOpen;
}
