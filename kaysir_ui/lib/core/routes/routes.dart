import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/feature_routes.dart';
import '../features/features_registry.dart';
import 'app_route_shell.dart';
import '../../routes/redirect_config.dart' as app_redirect;

class Routes {
  const Routes._();

  static List<RouteBase> get routes {
    FeaturesRegistry.init();
    final featureRoutes = _goRoutesFor(FeaturesRegistry.routes);
    final loginRoutes = <RouteBase>[];
    final shellRoutes = <RouteBase>[];

    for (final route in featureRoutes) {
      if (route case GoRoute(path: app_redirect.loginRoute)) {
        loginRoutes.add(route);
      } else {
        shellRoutes.add(route);
      }
    }

    return [
      ...loginRoutes,
      ShellRoute(
        builder:
            (BuildContext context, GoRouterState state, Widget child) =>
                AppRouteShell(
                  currentLocation: state.uri.toString(),
                  child: child,
                ),
        routes: shellRoutes,
      ),
    ];
  }

  static List<StatefulShellBranch> get branches => const [];

  static GoRouter config({required WidgetRef ref}) {
    FeaturesRegistry.init();

    return GoRouter(
      initialLocation: app_redirect.dashboardRoute,
      routes: routes,
      redirect:
          (BuildContext context, GoRouterState state) =>
              app_redirect.redirect(context, state, ref),
    );
  }

  static StatefulShellBranch shellBranch(
    String name,
    String path,
    Widget child, [
    List<RouteBase> routes = const [],
  ]) {
    return StatefulShellBranch(
      initialLocation: path,
      routes: [
        GoRoute(
          path: path,
          name: _shellRouteName(name, path),
          builder: (context, state) => child,
          routes: routes,
        ),
      ],
    );
  }
}

List<RouteBase> _goRoutesFor(List<FeatureRoutes> featureRoutes) {
  final routesByPath = <String, GoRoute>{};

  void visit(FeatureRoutes route) {
    final routePath = _goRoutePathForLocation(route.path);
    if (routePath != null && !routesByPath.containsKey(routePath)) {
      final goRoute = _goRouteFor(route, routePath);
      if (goRoute != null) routesByPath[routePath] = goRoute;
    }

    for (final child in route.items) {
      visit(child);
    }
  }

  for (final route in featureRoutes) {
    visit(route);
  }

  return routesByPath.values.toList(growable: false);
}

String? _goRoutePathForLocation(String? location) {
  final value = location?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  final path = uri?.path ?? value;
  final normalized = path.trim();
  return normalized.isEmpty ? null : normalized;
}

GoRoute? _goRouteFor(FeatureRoutes route, String path) {
  final pageBuilder = route.pageBuilder;
  final builder = route.builder;
  final child = route.child;
  final childRoutes = _pathBuilderRoutesFor(route);

  if (pageBuilder != null) {
    return GoRoute(
      path: path,
      name: route.goRouteName,
      pageBuilder: pageBuilder,
      routes: childRoutes,
    );
  }

  if (builder != null) {
    return GoRoute(
      path: path,
      name: route.goRouteName,
      builder: builder,
      routes: childRoutes,
    );
  }

  if (child != null) {
    return GoRoute(
      path: path,
      name: route.goRouteName,
      builder: (context, state) => child,
      routes: childRoutes,
    );
  }

  return null;
}

List<RouteBase> _pathBuilderRoutesFor(FeatureRoutes route) {
  final childPath = _goRouteChildPathForLocation(route.pathBuilder);
  if (childPath == null) return const [];

  final builder = route.builder;
  if (builder != null) {
    return [GoRoute(path: childPath, builder: builder)];
  }

  final child = route.child;
  if (child != null) {
    return [GoRoute(path: childPath, builder: (context, state) => child)];
  }

  return const [];
}

String? _goRouteChildPathForLocation(String? location) {
  final routePath = _goRoutePathForLocation(location);
  if (routePath == null) return null;

  final normalized =
      routePath.startsWith('/')
          ? routePath.replaceFirst(RegExp(r'^/+'), '')
          : routePath;
  return normalized.isEmpty ? null : normalized;
}

String _shellRouteName(String name, String path) {
  final normalized = name.trim();
  if (RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(normalized)) {
    return normalized;
  }

  return 'shell${path.hashCode.abs()}';
}
