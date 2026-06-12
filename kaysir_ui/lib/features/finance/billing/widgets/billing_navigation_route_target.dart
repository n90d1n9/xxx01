import 'billing_navigation_action_resolver.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_route_intent.dart';

enum BillingNavigationRouteTargetKind {
  none,
  dashboard,
  productWorkspace,
  tenantSelection,
}

class BillingNavigationRouteTarget {
  final BillingNavigationRouteTargetKind kind;
  final BillingNavigationDestinationId? initialDestinationId;
  final String? screenKey;

  const BillingNavigationRouteTarget._({
    required this.kind,
    this.initialDestinationId,
    this.screenKey,
  });

  const BillingNavigationRouteTarget.none()
    : this._(kind: BillingNavigationRouteTargetKind.none);

  const BillingNavigationRouteTarget.dashboard({
    required BillingNavigationDestinationId initialDestinationId,
    required String screenKey,
  }) : this._(
         kind: BillingNavigationRouteTargetKind.dashboard,
         initialDestinationId: initialDestinationId,
         screenKey: screenKey,
       );

  const BillingNavigationRouteTarget.productWorkspace({
    required BillingNavigationDestinationId initialDestinationId,
    required String screenKey,
  }) : this._(
         kind: BillingNavigationRouteTargetKind.productWorkspace,
         initialDestinationId: initialDestinationId,
         screenKey: screenKey,
       );

  const BillingNavigationRouteTarget.tenantSelection({
    required String screenKey,
  }) : this._(
         kind: BillingNavigationRouteTargetKind.tenantSelection,
         screenKey: screenKey,
       );

  bool get opensRoute => kind != BillingNavigationRouteTargetKind.none;
}

BillingNavigationRouteTarget resolveBillingNavigationRouteTarget(
  BillingNavigationRouteIntent routeIntent,
) {
  if (routeIntent.kind != BillingNavigationRouteIntentKind.route) {
    return const BillingNavigationRouteTarget.none();
  }

  switch (routeIntent.action.kind) {
    case BillingNavigationActionKind.dashboard:
      final action = routeIntent.dashboardAction;
      if (action == null) return const BillingNavigationRouteTarget.none();

      return BillingNavigationRouteTarget.dashboard(
        initialDestinationId: billingDestinationForDashboardNavigationAction(
          action,
        ),
        screenKey: routeIntent.screenKey,
      );
    case BillingNavigationActionKind.productWorkspace:
      return BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: routeIntent.destinationId,
        screenKey: routeIntent.screenKey,
      );
    case BillingNavigationActionKind.tenantSelection:
      return BillingNavigationRouteTarget.tenantSelection(
        screenKey: routeIntent.screenKey,
      );
    case BillingNavigationActionKind.unavailable:
    case BillingNavigationActionKind.ignored:
      return const BillingNavigationRouteTarget.none();
  }
}
