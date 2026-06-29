import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth_states/auth_notifier.dart';
import 'feature_routes.dart';

import 'features_base.dart';
import 'features_provider.dart';

class FeaturesRegistry {
  FeaturesRegistry._();

  static List<FeatureRoutes> _registeredScreens = [];
  static List<FeaturesBase> _registeredFeatures = [];

  static void register({
    List<FeatureRoutes> screens = const [],
    List<FeaturesBase> features = const [],
  }) {
    _registeredScreens = screens;
    _registeredFeatures = features;
  }

  static List<FeatureRoutes> getScreens() => _registeredScreens;
  static List<FeaturesBase> getFeatures() => _registeredFeatures;

  static String? guardRoute({
    required List<String> allowedRoles,

    required String? fallback,
  }) {
    final role = ProviderContainer().read(authProvider).role;
    if (allowedRoles.isEmpty) return null;
    if (role == null || !allowedRoles.contains(role)) {
      return fallback ?? '/forbidden';
    }
    return null;
  }
}
