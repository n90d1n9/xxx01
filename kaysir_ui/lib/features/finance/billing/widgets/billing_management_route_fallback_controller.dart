import 'billing_navigation_route_target.dart';

typedef BillingManagementRouteFallbackHandler =
    bool Function(BillingNavigationRouteTarget routeTarget);

enum BillingManagementRouteFallbackResultKind {
  dashboard,
  productWorkspace,
  tenantSelection,
  none,
}

class BillingManagementRouteFallbackResult {
  final BillingManagementRouteFallbackResultKind kind;
  final BillingNavigationRouteTarget routeTarget;
  final bool handled;

  const BillingManagementRouteFallbackResult({
    required this.kind,
    required this.routeTarget,
    required this.handled,
  });

  bool get wasUnhandled =>
      !handled && kind != BillingManagementRouteFallbackResultKind.none;
}

class BillingManagementRouteFallbackController {
  final BillingManagementRouteFallbackHandler? onDashboardRoute;
  final BillingManagementRouteFallbackHandler? onProductWorkspaceRoute;
  final BillingManagementRouteFallbackHandler? onTenantSelectionRoute;

  const BillingManagementRouteFallbackController({
    this.onDashboardRoute,
    this.onProductWorkspaceRoute,
    this.onTenantSelectionRoute,
  });

  BillingManagementRouteFallbackResult handle(
    BillingNavigationRouteTarget routeTarget,
  ) {
    switch (routeTarget.kind) {
      case BillingNavigationRouteTargetKind.dashboard:
        return BillingManagementRouteFallbackResult(
          kind: BillingManagementRouteFallbackResultKind.dashboard,
          routeTarget: routeTarget,
          handled: onDashboardRoute?.call(routeTarget) ?? false,
        );
      case BillingNavigationRouteTargetKind.productWorkspace:
        return BillingManagementRouteFallbackResult(
          kind: BillingManagementRouteFallbackResultKind.productWorkspace,
          routeTarget: routeTarget,
          handled: onProductWorkspaceRoute?.call(routeTarget) ?? false,
        );
      case BillingNavigationRouteTargetKind.tenantSelection:
        return BillingManagementRouteFallbackResult(
          kind: BillingManagementRouteFallbackResultKind.tenantSelection,
          routeTarget: routeTarget,
          handled: onTenantSelectionRoute?.call(routeTarget) ?? false,
        );
      case BillingNavigationRouteTargetKind.none:
        return BillingManagementRouteFallbackResult(
          kind: BillingManagementRouteFallbackResultKind.none,
          routeTarget: routeTarget,
          handled: false,
        );
    }
  }
}
