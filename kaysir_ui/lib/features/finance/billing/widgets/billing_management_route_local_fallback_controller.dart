import 'billing_management_local_target_controller.dart';
import 'billing_navigation_local_target.dart';
import 'billing_navigation_route_target.dart';

class BillingManagementRouteLocalFallbackResult {
  final BillingNavigationRouteTarget routeTarget;
  final BillingNavigationLocalTarget localTarget;
  final bool handled;

  const BillingManagementRouteLocalFallbackResult({
    required this.routeTarget,
    required this.localTarget,
    required this.handled,
  });

  bool get hasLocalTarget => !localTarget.isNone;

  bool get wasUnhandled => hasLocalTarget && !handled;
}

class BillingManagementRouteLocalFallbackController {
  final String? fallbackScreenKey;
  final BillingManagementLocalTargetHandler onLocalNavigation;

  const BillingManagementRouteLocalFallbackController({
    this.fallbackScreenKey,
    required this.onLocalNavigation,
  });

  BillingManagementRouteLocalFallbackResult handle(
    BillingNavigationRouteTarget routeTarget,
  ) {
    final localTarget = billingLocalTargetForRouteTarget(
      routeTarget,
      fallbackScreenKey: fallbackScreenKey,
    );
    if (localTarget.isNone) {
      return BillingManagementRouteLocalFallbackResult(
        routeTarget: routeTarget,
        localTarget: localTarget,
        handled: false,
      );
    }

    return BillingManagementRouteLocalFallbackResult(
      routeTarget: routeTarget,
      localTarget: localTarget,
      handled: onLocalNavigation(localTarget),
    );
  }
}
