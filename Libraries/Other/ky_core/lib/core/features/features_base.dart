import 'feature_routes.dart';

/// Contract for packages that contribute feature routes to the Kaysir shell.
abstract class FeaturesBase {
  /// Returns the feature route tree exposed by this package.
  List<FeatureRoutes> registerScreens();
}
