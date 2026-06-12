import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';
import 'package:ky_restaurant/ky_restaurant.dart';

import 'repositories/restaurant_workspace_preferences_repository.dart';
import 'widgets/restaurant_workspace_route_screen.dart';

class RestaurantFeatures extends FeaturesBase {
  RestaurantFeatures({
    RestaurantWorkspacePreferencesRepository? preferencesRepository,
  }) : _preferencesRepository = preferencesRepository;

  final RestaurantWorkspacePreferencesRepository? _preferencesRepository;

  @override
  List<FeatureRoutes> registerScreens() {
    final workspace = restaurantRouteDefinitions.first;

    return [
      FeatureRoutes(
        name: workspace.routeName,
        title: workspace.title,
        subtitle: workspace.subtitle,
        description: workspace.description,
        icon: workspace.icon,
        path: workspace.path,
        pageBuilder: _pageBuilderFor(workspace),
        items: restaurantRouteDefinitions
            .skip(1)
            .map(_routeForDefinition)
            .toList(growable: false),
      ),
    ];
  }

  FeatureRoutes _routeForDefinition(RestaurantRouteDefinition definition) {
    return FeatureRoutes(
      name: definition.routeName,
      title: definition.title,
      subtitle: definition.subtitle,
      description: definition.description,
      icon: definition.icon,
      path: definition.path,
      pageBuilder: _pageBuilderFor(definition),
    );
  }

  Page<dynamic> Function(BuildContext, GoRouterState) _pageBuilderFor(
    RestaurantRouteDefinition definition,
  ) {
    return (BuildContext context, GoRouterState state) {
      return MaterialPage(
        child: RestaurantWorkspaceRouteScreen(
          initialView: definition.view,
          restoreSavedView: definition.path == RestaurantRoutes.workspacePath,
          preferencesRepository: _preferencesRepository,
          onViewChanged: (nextView) {
            context.go(RestaurantRoutes.pathForView(nextView));
          },
        ),
      );
    };
  }
}
