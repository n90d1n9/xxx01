import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/register_features.dart';
import '../../config/routes/register_routes_screen.dart';
import '../../features/auth_states/auth_notifier.dart';
import 'feature_routes.dart';

import '../routes/routes.dart';

class FeaturesRegistry {
  // singleton object
  static final FeaturesRegistry _singleton = FeaturesRegistry._();

  // factory method to return the same object each time its needed
  factory FeaturesRegistry() => _singleton;

  FeaturesRegistry._();
  static List<FeatureRoutes> features = [];

  static init() {
    registerFeatures().forEach((m) {
      features.addAll(m.registerScreens());
    });

    features.addAll(registerScreens());

    for (var feature in features) {
      // Register all parent features route
      if (feature.screenType == ScreenType.branch) {
        Routes.addBranches([
          if (feature.path != null && feature.pageBuilder != null)
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  name: feature.name,
                  path: feature.path!,
                  builder: feature.builder,
                  pageBuilder: feature.pageBuilder,
                  redirect: (context, state) {
                    final ref = ProviderScope.containerOf(context);
                    /* final user = ref.read(authProvider);

                    // If roles required and user is not in them
                     if (feature.allowedRoles.isNotEmpty) {
                      final userRole = user.role;
                      if (userRole == null ||
                          !feature.allowedRoles.contains(userRole)) {
                        return feature.redirectToIfDenied ?? PathAuth.forbidden;
                      }
                    } */

                    return null;
                  },
                ),
              ],
            ),
        ]);
      } else {
        Routes.addRoutes([
          GoRoute(
            name: feature.name,
            path: feature.path!,
            pageBuilder: feature.pageBuilder,
          ),
        ]);
      }

      // Register All items children
      if (feature.items.isNotEmpty) {
        for (var featureItems in feature.items) {
          if (featureItems.screenType == ScreenType.branch) {
            // Add as branches
            Routes.addBranches([
              if (featureItems.path != null && featureItems.pageBuilder != null)
                StatefulShellBranch(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  routes: [
                    GoRoute(
                      name: featureItems.name,
                      path: featureItems.path!,
                      pageBuilder: featureItems.pageBuilder,
                    ),
                  ],
                ),
            ]);

            // Builder with parameter
            if (featureItems.path != null &&
                featureItems.pageBuilder != null &&
                featureItems.builder != null) {
              Routes.addBranches([
                StatefulShellBranch(
                  initialLocation: featureItems.initialLocation,
                  routes: [
                    GoRoute(
                      path: featureItems.path!,
                      pageBuilder: featureItems.pageBuilder,
                      routes: [
                        GoRoute(
                          path: featureItems.pathBuilder!,
                          builder: featureItems.builder,
                        ),
                      ],
                    ),
                  ],
                ),
              ]);
            }
          }

          // Add as single pages
          if (featureItems.screenType == ScreenType.singlePage) {
            Routes.addRoutes([
              if (featureItems.path != null && featureItems.pageBuilder != null)
                GoRoute(
                  name: featureItems.name,
                  path: featureItems.path!,
                  pageBuilder: featureItems.pageBuilder,
                ),
            ]);
          }
        }
      }
    }
  }

  static List<FeatureRoutes> getFeatures() {
    return features;
  }

  String? guardRoute({
    required List<String> allowedRoles,
    required WidgetRef ref,
    required String? fallback,
  }) {
    final role = ref.read(authProvider).role;
    if (allowedRoles.isEmpty) return null;
    if (role == null || !allowedRoles.contains(role)) {
      return fallback ?? '/forbidden';
    }
    return null;
  }
}
