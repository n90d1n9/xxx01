import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'feature_routes.dart';
import 'features_base.dart';
import 'features_registry.dart';

final featuresProvider =
    NotifierProvider<FeaturesNotifier, List<FeatureRoutes>>(() {
      return FeaturesNotifier();
    });

class FeaturesNotifier extends Notifier<List<FeatureRoutes>> {
  @override
  List<FeatureRoutes> build() {
    final screens = FeaturesRegistry.getScreens();
    final features = FeaturesRegistry.getFeatures();
    debugPrint(
      'DEBUG: FeaturesNotifier.build: ${screens.length} screens, ${features.length} features',
    );

    final List<FeatureRoutes> initial = [...screens];
    for (var feature in features) {
      initial.addAll(feature.registerScreens());
    }
    debugPrint(
      'DEBUG: FeaturesNotifier initial state length: ${initial.length}',
    );
    return initial;
  }

  void register({
    List<FeatureRoutes> screens = const [],
    List<FeaturesBase> features = const [],
  }) {
    final List<FeatureRoutes> newFeatures = [...state];

    for (var feature in features) {
      newFeatures.addAll(feature.registerScreens());
    }

    newFeatures.addAll(screens);

    state = newFeatures;
  }

  void clear() {
    state = [];
  }
}

final featureRoutesProvider = Provider<List<RouteBase>>((ref) {
  final features = ref.watch(featuresProvider);
  final List<RouteBase> routes = [];

  for (var feature in features) {
    if (feature.screenType != ScreenType.branch) {
      routes.add(
        GoRoute(
          name: feature.name,
          path: feature.path!,
          pageBuilder: feature.pageBuilder,
        ),
      );
    }

    for (var item in feature.items) {
      if (item.screenType == ScreenType.singlePage) {
        if (item.path != null && item.pageBuilder != null) {
          routes.add(
            GoRoute(
              name: item.name,
              path: item.path!,
              pageBuilder: item.pageBuilder,
            ),
          );
        }
      }
    }
  }

  return routes;
});

final featureBranchesProvider = Provider<List<StatefulShellBranch>>((ref) {
  final features = ref.watch(featuresProvider);
  final List<StatefulShellBranch> branches = [];

  for (var feature in features) {
    if (feature.screenType == ScreenType.branch) {
      if (feature.path != null && feature.pageBuilder != null) {
        branches.add(
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
        );
      }
    }

    for (var item in feature.items) {
      if (item.screenType == ScreenType.branch) {
        if (item.path != null && item.pageBuilder != null) {
          branches.add(
            StatefulShellBranch(
              navigatorKey: GlobalKey<NavigatorState>(),
              routes: [
                GoRoute(
                  name: item.name,
                  path: item.path!,
                  pageBuilder: item.pageBuilder,
                  builder: item.builder,
                ),
              ],
            ),
          );

          if (item.pathBuilder != null && item.builder != null) {
            branches.add(
              StatefulShellBranch(
                initialLocation: item.initialLocation,
                routes: [
                  GoRoute(
                    path: item.path!,
                    pageBuilder: item.pageBuilder,
                    routes: [
                      GoRoute(path: item.pathBuilder!, builder: item.builder),
                    ],
                  ),
                ],
              ),
            );
          }
        }
      }
    }
  }

  return branches;
});
