import 'package:flutter/widgets.dart';

import '../utils/billing_route_context.dart';
import 'billing_app_route_navigator.dart';
import 'billing_management_route_fallback_controller.dart';
import 'billing_navigation_route_target.dart';

typedef BillingManagementRouteOpeningHandler =
    void Function(BillingNavigationRouteTarget routeTarget);

class BillingManagementRouteOpenResult {
  final BillingManagementRouteFallbackResultKind kind;
  final BillingNavigationRouteTarget routeTarget;
  final bool didOpen;

  const BillingManagementRouteOpenResult({
    required this.kind,
    required this.routeTarget,
    required this.didOpen,
  });
}

class BillingManagementRouteOpenController {
  final BuildContext context;
  final BillingRouteContext routeContext;
  final String? tenantId;
  final String? businessDomain;
  final BillingManagementRouteOpeningHandler? onDashboardRouteOpening;
  final BillingManagementRouteOpeningHandler? onProductWorkspaceRouteOpening;
  final BillingManagementRouteOpeningHandler? onTenantSelectionRouteOpening;

  const BillingManagementRouteOpenController({
    required this.context,
    this.routeContext = BillingRouteContext.empty,
    this.tenantId,
    this.businessDomain,
    this.onDashboardRouteOpening,
    this.onProductWorkspaceRouteOpening,
    this.onTenantSelectionRouteOpening,
  });

  bool open(BillingNavigationRouteTarget routeTarget) {
    return openResult(routeTarget).didOpen;
  }

  BillingManagementRouteOpenResult openResult(
    BillingNavigationRouteTarget routeTarget,
  ) {
    final kind = _prepareRouteOpening(routeTarget);
    if (!routeTarget.opensRoute) {
      return BillingManagementRouteOpenResult(
        kind: kind,
        routeTarget: routeTarget,
        didOpen: false,
      );
    }

    return BillingManagementRouteOpenResult(
      kind: kind,
      routeTarget: routeTarget,
      didOpen: openBillingAppRouteTarget(
        context,
        routeTarget,
        tenantId: tenantId,
        businessDomain: businessDomain,
        routeContext: routeContext,
      ),
    );
  }

  BillingManagementRouteFallbackResultKind _prepareRouteOpening(
    BillingNavigationRouteTarget routeTarget,
  ) {
    switch (routeTarget.kind) {
      case BillingNavigationRouteTargetKind.dashboard:
        onDashboardRouteOpening?.call(routeTarget);
        return BillingManagementRouteFallbackResultKind.dashboard;
      case BillingNavigationRouteTargetKind.productWorkspace:
        onProductWorkspaceRouteOpening?.call(routeTarget);
        return BillingManagementRouteFallbackResultKind.productWorkspace;
      case BillingNavigationRouteTargetKind.tenantSelection:
        onTenantSelectionRouteOpening?.call(routeTarget);
        return BillingManagementRouteFallbackResultKind.tenantSelection;
      case BillingNavigationRouteTargetKind.none:
        return BillingManagementRouteFallbackResultKind.none;
    }
  }
}
