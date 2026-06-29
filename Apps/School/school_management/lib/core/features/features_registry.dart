import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'feature_routes.dart';
import '../../routes/register_features.dart';
import '../../routes/register_routes_screen.dart';
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
          if (featureItems.screenType != ScreenType.singlePage) {
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
                /* StatefulShellBranch(
                  navigatorKey: GlobalKey<NavigatorState>(),
                  initialLocation: featureItems.initialLocation,
                  routes: [
                    GoRoute(
                      name: featureItems.name,
                      path: featureItems.path!,
                      builder: featureItems.builder,
                    ),
                  ],
                ), */
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
          if (featureItems.screenType != ScreenType.branch) {
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
}
