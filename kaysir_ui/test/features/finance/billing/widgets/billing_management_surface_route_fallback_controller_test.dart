import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_surface_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('keeps dashboard route targets local on dashboard surface', () {
    BillingNavigationLocalTarget? localTarget;
    BillingNavigationDestinationId? destinationId;

    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.dashboard,
      onDashboardLocalNavigation: (target) {
        localTarget = target;
        return true;
      },
      onDashboardRouteDestination: (destination, _) {
        destinationId = destination;
        return true;
      },
    ).handle(
      BillingNavigationRouteTarget.dashboard(
        initialDestinationId: BillingNavigationDestinationId.reports,
        screenKey: 'route.dashboard.reports',
      ),
    );

    expect(result.kind, BillingManagementRouteFallbackResultKind.dashboard);
    expect(result.handled, isTrue);
    expect(
      localTarget?.kind,
      BillingNavigationLocalTargetKind.dashboardReports,
    );
    expect(destinationId, isNull);
  });

  test('opens dashboard route targets from product workspace surface', () {
    BillingNavigationDestinationId? openedDestination;
    BillingNavigationRouteTarget? openedRouteTarget;

    final routeTarget = BillingNavigationRouteTarget.dashboard(
      initialDestinationId: BillingNavigationDestinationId.invoices,
      screenKey: 'route.dashboard.invoices',
    );

    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.productWorkspace,
      onDashboardRouteDestination: (destination, target) {
        openedDestination = destination;
        openedRouteTarget = target;
        return true;
      },
    ).handle(routeTarget);

    expect(result.kind, BillingManagementRouteFallbackResultKind.dashboard);
    expect(result.handled, isTrue);
    expect(openedDestination, BillingNavigationDestinationId.invoices);
    expect(openedRouteTarget, routeTarget);
  });

  test('keeps product workspace route targets local on product surface', () {
    BillingNavigationLocalTarget? localTarget;

    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.productWorkspace,
      onProductWorkspaceLocalNavigation: (target) {
        localTarget = target;
        return true;
      },
    ).handle(
      const BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: BillingNavigationDestinationId.cartCheckout,
        screenKey: '',
      ),
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.handled, isTrue);
    expect(localTarget?.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(localTarget?.screenKey, 'route.product_workspace');
  });

  test('opens product workspace route targets from dashboard surface', () {
    BillingNavigationDestinationId? openedDestination;

    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.dashboard,
      onProductWorkspaceRouteDestination: (destination, _) {
        openedDestination = destination;
        return true;
      },
    ).handle(
      BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: BillingNavigationDestinationId.productWorkspace,
        screenKey: 'route.product.catalog',
      ),
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.handled, isTrue);
    expect(openedDestination, BillingNavigationDestinationId.productWorkspace);
  });

  test('opens dashboard route targets from tenant selection surface', () {
    BillingNavigationDestinationId? openedDestination;

    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.tenantSelection,
      onDashboardRouteDestination: (destination, _) {
        openedDestination = destination;
        return true;
      },
    ).handle(
      BillingNavigationRouteTarget.dashboard(
        initialDestinationId: BillingNavigationDestinationId.dashboard,
        screenKey: 'route.dashboard',
      ),
    );

    expect(result.handled, isTrue);
    expect(openedDestination, BillingNavigationDestinationId.dashboard);
  });

  test('reports unhandled cross-surface route targets without a handler', () {
    final result = BillingManagementSurfaceRouteFallbackController(
      currentSurface: BillingNavigationSurface.dashboard,
    ).handle(
      BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: BillingNavigationDestinationId.cartCheckout,
        screenKey: 'route.product.cart_checkout',
      ),
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isTrue);
  });
}
