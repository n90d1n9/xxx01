import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';

import '../../../utils/helper.dart';

/// Returns a stable, human readable label for a feature route.
String routeShellLabel(FeatureRoutes route) {
  return route.title ?? route.name ?? route.path ?? 'Untitled';
}

/// Resolves a feature route icon into Material icon data with a safe fallback.
IconData routeShellIconData(FeatureRoutes route) {
  final icon = route.icon;
  return icon == null ? Icons.circle_outlined : getIconData(icon);
}

/// Whether a feature route should be shown in shell navigation.
bool routeShellIsVisible(FeatureRoutes route) {
  return route.enabled != false &&
      route.position.contains(MenuPosition.sidebar);
}

/// Whether a feature route has a usable path for navigation.
bool routeShellIsNavigable(FeatureRoutes route) {
  final path = route.path?.trim();
  return path != null && path.isNotEmpty;
}

/// Whether a feature route can be opened from shell navigation.
bool routeShellCanOpen(FeatureRoutes route) {
  if (!routeShellIsNavigable(route)) return false;
  if (route.hasRouteTarget) return true;

  final basePath = route.basePath?.trim();
  return basePath != null && basePath.isNotEmpty;
}

/// Whether this route or any visible descendant can be opened.
bool routeShellHasOpenRoute(FeatureRoutes route) {
  if (routeShellCanOpen(route)) return true;
  return route.items.any(
    (child) => routeShellIsVisible(child) && routeShellHasOpenRoute(child),
  );
}

/// Visible child routes for a feature route.
List<FeatureRoutes> routeShellVisibleChildren(FeatureRoutes route) {
  return route.items.where(routeShellIsVisible).toList(growable: false);
}

/// Flattens visible, navigable routes in the same order used by compact navigation.
List<FeatureRoutes> routeShellVisibleNavigableRoutes(
  List<FeatureRoutes> routes,
) {
  final flattened = <FeatureRoutes>[];

  void visit(FeatureRoutes route) {
    if (!routeShellIsVisible(route)) return;
    if (routeShellCanOpen(route)) flattened.add(route);

    for (final child in route.items) {
      visit(child);
    }
  }

  for (final route in routes) {
    visit(route);
  }

  return List.unmodifiable(flattened);
}

/// Finds the route that best matches the current router location.
FeatureRoutes? routeShellSelectedRoute(
  List<FeatureRoutes> routes,
  BuildContext context,
) {
  final routeTrail = routeShellSelectedRouteTrail(routes, context);
  return routeTrail.isEmpty ? null : routeTrail.last;
}

/// Finds the selected route and its ancestors for the current router location.
List<FeatureRoutes> routeShellSelectedRouteTrail(
  List<FeatureRoutes> routes,
  BuildContext context,
) {
  return routeShellRouteTrailForPath(
    routes,
    routeShellCurrentLocation(context),
  );
}

/// Finds the nearest visible navigable route for the current router location.
FeatureRoutes? routeShellSelectedVisibleRoute(
  List<FeatureRoutes> routes,
  BuildContext context,
) {
  return routeShellSelectedVisibleRouteForPath(
    routes,
    routeShellCurrentLocation(context),
  );
}

/// Finds the nearest visible navigable route for a concrete path.
FeatureRoutes? routeShellSelectedVisibleRouteForPath(
  List<FeatureRoutes> routes,
  String currentPath,
) {
  return routeShellVisibleRouteForTrail(
    routeShellRouteTrailForPath(routes, currentPath),
  );
}

/// Finds the selected route and its ancestors for a concrete path.
List<FeatureRoutes> routeShellRouteTrailForPath(
  List<FeatureRoutes> routes,
  String currentPath,
) {
  var hasMatch = false;
  List<FeatureRoutes> bestTrail = const [];
  var bestScore = -1;

  void visit(Iterable<FeatureRoutes> items, List<FeatureRoutes> ancestors) {
    for (final route in items) {
      final trail = [...ancestors, route];
      final score = _routeMatchScore(currentPath, route.path);
      if (score > bestScore) {
        bestScore = score;
        hasMatch = true;
        bestTrail = trail;
      }

      visit(route.items, trail);
    }
  }

  visit(routes, const []);
  return hasMatch ? List.unmodifiable(bestTrail) : const [];
}

/// Finds the nearest visible navigable route in a selected route trail.
FeatureRoutes? routeShellVisibleRouteForTrail(List<FeatureRoutes> routeTrail) {
  for (final route in routeTrail.reversed) {
    if (routeShellIsVisible(route) && routeShellCanOpen(route)) {
      return route;
    }
  }

  return null;
}

/// Whether the provided route directly matches the current router location.
bool routeShellIsSelectedRoute(BuildContext context, FeatureRoutes route) {
  return _routeMatchScore(routeShellCurrentLocation(context), route.path) >= 0;
}

/// Whether the provided route exactly matches the current router location.
bool routeShellIsExactlySelectedRoute(
  BuildContext context,
  FeatureRoutes route,
) {
  final path = route.path?.trim();
  return path != null &&
      path.isNotEmpty &&
      routeShellPathMatchesExactly(routeShellCurrentLocation(context), path);
}

/// Whether a concrete path exactly matches a route path, including path params.
bool routeShellPathMatchesExactly(String currentPath, String routePath) {
  final normalizedRouteLocation = routePath.trim();
  if (normalizedRouteLocation.isEmpty) return false;
  final currentUri = _uriFromLocation(currentPath);
  final routeUri = _uriFromLocation(normalizedRouteLocation);
  if (!_routeQueryMatches(currentUri, routeUri)) return false;

  final currentSegments = _pathSegmentsForUri(currentUri);
  final routeSegments = _pathSegmentsForUri(routeUri);
  if (currentSegments.length != routeSegments.length) return false;
  return _routeSegmentsMatchPrefix(currentSegments, routeSegments);
}

/// Whether the route or any visible descendant matches the current location.
bool routeShellIsSelectedBranch(BuildContext context, FeatureRoutes route) {
  return routeShellIsSelectedBranchForPath(
    route,
    routeShellCurrentLocation(context),
  );
}

/// Whether the route or any descendant matches a concrete location.
bool routeShellIsSelectedBranchForPath(
  FeatureRoutes route,
  String currentPath,
) {
  if (_routeMatchScore(currentPath, route.path) >= 0) return true;
  return route.items.any(
    (child) => routeShellIsSelectedBranchForPath(child, currentPath),
  );
}

/// Current path from GoRouter, or an empty string outside a router context.
String routeShellCurrentPath(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path;
  } catch (_) {}

  try {
    return GoRouter.of(context).routeInformationProvider.value.uri.path;
  } catch (_) {
    return '';
  }
}

/// Current full location from GoRouter, or an empty string outside a router context.
String routeShellCurrentLocation(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.toString();
  } catch (_) {}

  try {
    return GoRouter.of(context).routeInformationProvider.value.uri.toString();
  } catch (_) {
    return '';
  }
}

int _routeMatchScore(String currentPath, String? routePath) {
  final path = routePath?.trim();
  if (path == null || path.isEmpty) return -1;
  final currentUri = _uriFromLocation(currentPath);
  final routeUri = _uriFromLocation(path);
  if (!_routeQueryMatches(currentUri, routeUri)) return -1;

  final currentSegments = _pathSegmentsForUri(currentUri);
  final routeSegments = _pathSegmentsForUri(routeUri);
  if (!_routeSegmentsMatchPrefix(currentSegments, routeSegments)) return -1;

  final score = _routeSpecificityScore(path, routeSegments, routeUri);
  if (currentSegments.length == routeSegments.length) return score * 2;
  return score;
}

List<String> _pathSegmentsForUri(Uri uri) {
  return uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
}

bool _routeSegmentsMatchPrefix(
  List<String> currentSegments,
  List<String> routeSegments,
) {
  if (routeSegments.length > currentSegments.length) return false;
  for (var index = 0; index < routeSegments.length; index += 1) {
    final routeSegment = routeSegments[index];
    if (routeSegment.startsWith(':')) continue;
    if (routeSegment != currentSegments[index]) return false;
  }

  return true;
}

bool _routeQueryMatches(Uri currentUri, Uri routeUri) {
  if (routeUri.queryParameters.isEmpty) return true;

  for (final entry in routeUri.queryParameters.entries) {
    if (currentUri.queryParameters[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

int _routeSpecificityScore(
  String path,
  List<String> routeSegments,
  Uri routeUri,
) {
  final staticSegmentCount =
      routeSegments.where((segment) => !segment.startsWith(':')).length;
  final queryScore = routeUri.queryParameters.length * 5000;
  return (routeSegments.length * 1000) +
      (staticSegmentCount * 100) +
      queryScore +
      path.length;
}

Uri _uriFromLocation(String location) {
  final trimmed = location.trim();
  return Uri.tryParse(trimmed) ?? Uri(path: trimmed);
}
