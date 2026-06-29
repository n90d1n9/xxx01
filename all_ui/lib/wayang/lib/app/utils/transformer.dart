import '../../core/features/feature_routes.dart';

List<FeatureRoutes> getMenusFromFeatures(List<FeatureRoutes> features) {
  return features
      .map((feature) => FeatureRoutes(
            id: feature.id,
            title: feature.name,
            // icon: feature.icon,
            // iconWidget: Icon,
            basePath: feature.path,
            path: feature.path,
            //roles: feature.roles,
            enabled: feature.enabled,
            screenType: feature.screenType,
            /* items: feature.items
              .map((e) => Menu(
                    id: e.id,
                    title: e.title,
                    icon: e.icon,
                    iconWidget: e.iconWidget,
                  ))
              .toList()) */
          ))
      .toList();
}
