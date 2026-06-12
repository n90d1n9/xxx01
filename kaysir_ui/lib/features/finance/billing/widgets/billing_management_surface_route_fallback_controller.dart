import 'billing_management_local_target_controller.dart';
import 'billing_management_route_fallback_controller.dart';
import 'billing_management_route_local_fallback_controller.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_route_target.dart';

typedef BillingManagementDestinationRouteHandler =
    bool Function(
      BillingNavigationDestinationId destinationId,
      BillingNavigationRouteTarget routeTarget,
    );

class BillingManagementSurfaceRouteFallbackController {
  final BillingNavigationSurface currentSurface;
  final String dashboardFallbackScreenKey;
  final String productWorkspaceFallbackScreenKey;
  final BillingManagementLocalTargetHandler? onDashboardLocalNavigation;
  final BillingManagementLocalTargetHandler? onProductWorkspaceLocalNavigation;
  final BillingManagementDestinationRouteHandler? onDashboardRouteDestination;
  final BillingManagementDestinationRouteHandler?
  onProductWorkspaceRouteDestination;
  final BillingManagementRouteFallbackHandler? onTenantSelectionRoute;

  const BillingManagementSurfaceRouteFallbackController({
    required this.currentSurface,
    this.dashboardFallbackScreenKey = 'route.dashboard',
    this.productWorkspaceFallbackScreenKey = 'route.product_workspace',
    this.onDashboardLocalNavigation,
    this.onProductWorkspaceLocalNavigation,
    this.onDashboardRouteDestination,
    this.onProductWorkspaceRouteDestination,
    this.onTenantSelectionRoute,
  });

  BillingManagementRouteFallbackResult handle(
    BillingNavigationRouteTarget routeTarget,
  ) {
    return BillingManagementRouteFallbackController(
      onDashboardRoute: _handleDashboardRoute,
      onProductWorkspaceRoute: _handleProductWorkspaceRoute,
      onTenantSelectionRoute: onTenantSelectionRoute,
    ).handle(routeTarget);
  }

  bool _handleDashboardRoute(BillingNavigationRouteTarget routeTarget) {
    if (currentSurface == BillingNavigationSurface.dashboard) {
      return _handleLocalRoute(
        routeTarget: routeTarget,
        fallbackScreenKey: dashboardFallbackScreenKey,
        onLocalNavigation: onDashboardLocalNavigation,
      );
    }

    return _handleDestinationRoute(routeTarget, onDashboardRouteDestination);
  }

  bool _handleProductWorkspaceRoute(BillingNavigationRouteTarget routeTarget) {
    if (currentSurface == BillingNavigationSurface.productWorkspace) {
      return _handleLocalRoute(
        routeTarget: routeTarget,
        fallbackScreenKey: productWorkspaceFallbackScreenKey,
        onLocalNavigation: onProductWorkspaceLocalNavigation,
      );
    }

    return _handleDestinationRoute(
      routeTarget,
      onProductWorkspaceRouteDestination,
    );
  }

  bool _handleLocalRoute({
    required BillingNavigationRouteTarget routeTarget,
    required String fallbackScreenKey,
    required BillingManagementLocalTargetHandler? onLocalNavigation,
  }) {
    if (onLocalNavigation == null) return false;

    return BillingManagementRouteLocalFallbackController(
      fallbackScreenKey: fallbackScreenKey,
      onLocalNavigation: onLocalNavigation,
    ).handle(routeTarget).handled;
  }

  bool _handleDestinationRoute(
    BillingNavigationRouteTarget routeTarget,
    BillingManagementDestinationRouteHandler? onDestinationRoute,
  ) {
    final destinationId = routeTarget.initialDestinationId;
    if (destinationId == null || onDestinationRoute == null) return false;

    return onDestinationRoute(destinationId, routeTarget);
  }
}
