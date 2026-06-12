import 'feature_routes.dart';

import '../../routes/register_features.dart';
import '../../routes/register_routes_screen.dart';

class FeaturesRegistry {
  static final List<FeatureRoutes> _routes = [];
  static bool _initialized = false;

  const FeaturesRegistry._();

  static List<FeatureRoutes> get routes => List.unmodifiable(_routes);

  static List<FeatureRoutes> getFeatures() {
    init();
    return routes;
  }

  static void init() {
    if (_initialized) return;

    _routes
      ..clear()
      ..addAll([
        for (final feature in registerFeatures()) ...feature.registerScreens(),
        ...registerScreens(),
      ]);
    _initialized = true;
  }

  static void reset() {
    _routes.clear();
    _initialized = false;
  }
}
