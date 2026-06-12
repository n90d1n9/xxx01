import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';
import '../widgets/billing_navigation_launch_snapshot.dart';
import '../widgets/billing_navigation_launch_state.dart';
import 'billing_route_context.dart';
import 'billing_route_locations.dart';

/// Presentation-ready billing route link with context and launch state.
class BillingRouteLink {
  final BillingNavigationDestinationId destinationId;
  final BillingManagementRouteSurface surface;
  final String routeIdentityKey;
  final String routeName;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String location;
  final BillingRouteContext routeContext;
  final bool isEnabled;
  final String? disabledReason;
  final String availabilityDescription;
  final bool requiresTenant;
  final bool isExposed;
  final bool hasRegisteredScreen;
  final String? screenKey;

  const BillingRouteLink({
    required this.destinationId,
    required this.surface,
    required this.routeIdentityKey,
    required this.routeName,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.location,
    required this.availabilityDescription,
    this.routeContext = BillingRouteContext.empty,
    this.isEnabled = true,
    this.disabledReason,
    this.requiresTenant = false,
    this.isExposed = true,
    this.hasRegisteredScreen = true,
    this.screenKey,
  });

  bool get carriesTenantContext => routeContext.tenantId != null;

  bool get carriesBusinessDomainContext => routeContext.businessDomain != null;

  bool get isDisabled => !isEnabled;
}

List<BillingRouteLink> billingManagementRouteLinks({
  BillingRouteContext routeContext = BillingRouteContext.empty,
  Iterable<BillingManagementRouteDefinition> routes =
      BillingRoutes.sidebarRoutes,
}) {
  return List.unmodifiable(
    routes.map(
      (route) =>
          billingRouteLinkForDefinition(route, routeContext: routeContext),
    ),
  );
}

List<BillingRouteLink> billingManagementRouteLinksForLaunchSnapshot({
  required BillingNavigationLaunchSnapshot launchSnapshot,
  BillingRouteContext routeContext = BillingRouteContext.empty,
  Iterable<BillingManagementRouteDefinition> routes =
      BillingRoutes.sidebarRoutes,
}) {
  return List.unmodifiable(
    routes.map(
      (route) => billingRouteLinkForDefinition(
        route,
        routeContext: routeContext,
        launchState: launchSnapshot.stateFor(route.destinationId),
      ),
    ),
  );
}

BillingRouteLink? billingRouteLinkForDestination(
  BillingNavigationDestinationId destinationId, {
  BillingRouteContext routeContext = BillingRouteContext.empty,
  Iterable<BillingManagementRouteDefinition> routes =
      BillingRoutes.sidebarRoutes,
  BillingNavigationLaunchSnapshot? launchSnapshot,
}) {
  for (final route in routes) {
    if (route.destinationId == destinationId) {
      return billingRouteLinkForDefinition(
        route,
        routeContext: routeContext,
        launchState: launchSnapshot?.stateFor(route.destinationId),
      );
    }
  }

  return null;
}

BillingRouteLink billingRouteLinkForDefinition(
  BillingManagementRouteDefinition route, {
  BillingRouteContext routeContext = BillingRouteContext.empty,
  BillingNavigationLaunchState? launchState,
}) {
  return BillingRouteLink(
    destinationId: route.destinationId,
    surface: route.surface,
    routeIdentityKey: route.resolvedRouteIdentityKey,
    routeName: route.routeName,
    title: route.title,
    subtitle: route.subtitle,
    description: route.description,
    icon: route.icon,
    location: billingRouteLocation(route.path, routeContext: routeContext),
    routeContext: routeContext,
    isEnabled: launchState?.isEnabled ?? true,
    disabledReason: launchState?.disabledReason,
    availabilityDescription: launchState?.description ?? route.description,
    requiresTenant: launchState?.requiresTenant ?? false,
    isExposed: launchState?.isExposed ?? true,
    hasRegisteredScreen: launchState?.hasRegisteredScreen ?? true,
    screenKey: launchState?.screenKey,
  );
}
