import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ky_core/core/features/feature_routes.dart';

import 'models/experience_profile.dart';
import 'models/product_module_destination.dart';
import 'models/product_route_state.dart';
import 'product_module_route_builder_registry.dart';
import 'product_routes.dart';
import 'screens/product_workspace_screen.dart';
import 'widgets/experience_profile_scope.dart';

/// Builds product module routes from an experience profile and destination registry.
class ProductFeatureRouteRegistry {
  const ProductFeatureRouteRegistry({
    this.experienceProfile = productFullSuiteExperienceProfile,
    this.experienceProfileRegistry = defaultProductExperienceProfileRegistry,
    this.destinationRegistry = defaultProductModuleDestinationRegistry,
    this.moduleRouteBuilderRegistry = defaultProductModuleRouteBuilderRegistry,
  });

  final ProductExperienceProfile experienceProfile;
  final ProductExperienceProfileRegistry experienceProfileRegistry;
  final ProductModuleDestinationRegistry destinationRegistry;
  final ProductModuleRouteBuilderRegistry moduleRouteBuilderRegistry;

  FeatureRoutes workspaceRoute({ProductExperienceProfile? experienceProfile}) {
    final resolvedProfile = experienceProfile ?? this.experienceProfile;
    final destinations = resolvedProfile.destinationsIn(destinationRegistry);
    final fallbackRoutes = moduleRouteBuilderRegistry
        .fallbackRoutesForDestinations(destinations);

    return FeatureRoutes(
      name: ProductRoutes.workspaceRouteName,
      title: resolvedProfile.workspaceTitle,
      subtitle: resolvedProfile.workspaceSubtitle,
      description: resolvedProfile.workspaceDescription,
      icon: 'inventory',
      path: ProductRoutes.workspacePath,
      pageBuilder: _workspacePageBuilderForProfile(
        resolvedProfile,
        experienceProfileRegistry: experienceProfileRegistry,
      ),
      items: [
        for (final destination in destinations)
          moduleRouteBuilderRegistry.routeForDestination(
            destination,
            experienceProfile: resolvedProfile,
            childRoutes: moduleRouteBuilderRegistry.childRoutesForDestination(
              destination,
            ),
          ),
        ...fallbackRoutes,
      ],
    );
  }
}

const defaultProductFeatureRouteRegistry = ProductFeatureRouteRegistry();

Page<dynamic> Function(BuildContext context, GoRouterState state)
_workspacePageBuilderForProfile(
  ProductExperienceProfile experienceProfile, {
  required ProductExperienceProfileRegistry experienceProfileRegistry,
}) {
  return (BuildContext context, GoRouterState state) {
    final requestedExperience =
        ProductRoutes.productExperienceProfileValueFromQuery(
          state.uri.queryParameters[ProductRoutes.workspaceExperienceQueryKey],
        );
    final resolvedProfile =
        requestedExperience == null
            ? experienceProfile
            : experienceProfileRegistry.profileForValue(requestedExperience) ??
                experienceProfile;
    final routeState = ProductWorkspaceRouteState.fromQueryParameters(
      state.uri.queryParameters,
      fallbackPackId: resolvedProfile.defaultPackId,
      fallbackChannelProfileId: resolvedProfile.defaultChannelProfileId,
    );
    return MaterialPage(
      child: ProductExperienceProfileScope(
        profile: resolvedProfile,
        child: ProductWorkspaceScreen(
          initialPackId: routeState.packId,
          initialChannelProfileId: routeState.channelProfileId,
          initialSetupTargetId: routeState.setupTargetId,
        ),
      ),
    );
  };
}
