import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';

/// Composes core and extension billing routes into one reusable registry.
class BillingRouteDefinitionRegistry {
  final List<BillingManagementRouteDefinition> baseDefinitions;
  final List<BillingManagementRouteDefinition> extensionDefinitions;
  final List<BillingManagementRouteDefinition> routeDefinitions;

  BillingRouteDefinitionRegistry({
    Iterable<BillingManagementRouteDefinition> baseDefinitions =
        BillingRoutes.sidebarRoutes,
    Iterable<BillingManagementRouteDefinition> extensionDefinitions = const [],
  }) : baseDefinitions = List.unmodifiable(baseDefinitions),
       extensionDefinitions = List.unmodifiable(extensionDefinitions),
       routeDefinitions = List.unmodifiable([
         ...baseDefinitions,
         ...extensionDefinitions,
       ]);

  /// Builds the standard billing route registry with no extensions.
  factory BillingRouteDefinitionRegistry.standard() {
    return BillingRouteDefinitionRegistry();
  }

  bool get hasExtensions => extensionDefinitions.isNotEmpty;

  int get routeCount => routeDefinitions.length;

  List<String> get routeIdentityKeys {
    return List.unmodifiable(
      routeDefinitions.map((route) => route.resolvedRouteIdentityKey),
    );
  }

  List<String> get routeNames {
    return List.unmodifiable(routeDefinitions.map((route) => route.routeName));
  }

  List<String> get paths {
    return List.unmodifiable(routeDefinitions.map((route) => route.path));
  }

  BillingManagementRouteDefinition? definitionForRouteIdentityKey(
    String routeIdentityKey,
  ) {
    final normalizedKey = routeIdentityKey.trim();
    if (normalizedKey.isEmpty) return null;

    for (final route in routeDefinitions) {
      if (route.resolvedRouteIdentityKey == normalizedKey) return route;
    }

    return null;
  }

  BillingManagementRouteDefinition? definitionForRouteName(String routeName) {
    final normalizedName = routeName.trim();
    if (normalizedName.isEmpty) return null;

    for (final route in routeDefinitions) {
      if (route.routeName == normalizedName) return route;
    }

    return null;
  }

  BillingManagementRouteDefinition? definitionForPath(String path) {
    final normalizedPath = path.trim();
    if (normalizedPath.isEmpty) return null;

    for (final route in routeDefinitions) {
      if (route.path == normalizedPath) return route;
    }

    return null;
  }

  List<BillingManagementRouteDefinition> definitionsForDestination(
    BillingNavigationDestinationId destinationId,
  ) {
    return List.unmodifiable(
      routeDefinitions.where((route) => route.destinationId == destinationId),
    );
  }

  bool containsRouteIdentityKey(String routeIdentityKey) {
    return definitionForRouteIdentityKey(routeIdentityKey) != null;
  }
}
