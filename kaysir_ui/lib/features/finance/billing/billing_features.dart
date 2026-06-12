import 'package:ky_core/core/features/feature_routes.dart';
import 'package:ky_core/core/features/features_base.dart';
import 'billing_routes.dart';
import 'utils/billing_route_definition_registry.dart';
import 'utils/billing_route_extension_manifest.dart';
import 'utils/billing_route_page_builder_registry.dart';

/// Registers billing management routes and their executable page builders.
class BillingFeatures extends FeaturesBase {
  final BillingRouteDefinitionRegistry routeDefinitionRegistry;
  final BillingRoutePageBuilderRegistry pageBuilderRegistry;

  BillingFeatures({
    BillingRouteDefinitionRegistry? routeDefinitionRegistry,
    BillingRoutePageBuilderRegistry? pageBuilderRegistry,
    Iterable<BillingRouteExtensionManifest> extensionManifests = const [],
  }) : routeDefinitionRegistry =
           routeDefinitionRegistry ??
           BillingRouteDefinitionRegistry(
             extensionDefinitions: billingRouteDefinitionsForManifests(
               extensionManifests,
             ),
           ),
       pageBuilderRegistry =
           pageBuilderRegistry ??
           BillingRoutePageBuilderRegistry.standard(
             extensionBuildersByRouteIdentityKey:
                 billingRoutePageBuildersForManifests(extensionManifests),
           );

  @override
  List<FeatureRoutes> registerScreens() => [
    FeatureRoutes(
      name: BillingRoutes.managementRouteName,
      title: BillingRoutes.managementTitle,
      subtitle: BillingRoutes.managementSubtitle,
      description: BillingRoutes.managementDescription,
      icon: 'billing',
      path: BillingRoutes.managementPath,
      pageBuilder: pageBuilderRegistry.pageBuilderFor(
        routeDefinitionRegistry.definitionForPath(
              BillingRoutes.managementPath,
            ) ??
            BillingRoutes.sidebarRoutes.first,
      ),
      items: routeDefinitionRegistry.routeDefinitions
          .where((route) => route.path != BillingRoutes.managementPath)
          .map(_featureRouteForBillingDestination)
          .toList(growable: false),
    ),
  ];

  FeatureRoutes _featureRouteForBillingDestination(
    BillingManagementRouteDefinition destination,
  ) {
    return FeatureRoutes(
      name: destination.routeName,
      title: destination.title,
      subtitle: destination.subtitle,
      description: destination.description,
      icon: destination.icon,
      path: destination.path,
      pageBuilder: pageBuilderRegistry.pageBuilderFor(destination),
    );
  }
}
