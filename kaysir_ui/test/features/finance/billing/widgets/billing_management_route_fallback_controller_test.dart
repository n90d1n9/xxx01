import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('dispatches dashboard route fallback to dashboard handler', () {
    final routeTarget = BillingNavigationRouteTarget.dashboard(
      initialDestinationId: BillingNavigationDestinationId.invoices,
      screenKey: 'test.dashboard.invoices',
    );
    BillingNavigationRouteTarget? handledTarget;

    final result = BillingManagementRouteFallbackController(
      onDashboardRoute: (target) {
        handledTarget = target;
        return true;
      },
    ).handle(routeTarget);

    expect(result.kind, BillingManagementRouteFallbackResultKind.dashboard);
    expect(result.handled, isTrue);
    expect(result.wasUnhandled, isFalse);
    expect(handledTarget, routeTarget);
  });

  test('dispatches product workspace route fallback to product handler', () {
    final routeTarget = BillingNavigationRouteTarget.productWorkspace(
      initialDestinationId: BillingNavigationDestinationId.cartCheckout,
      screenKey: 'test.product.cart_checkout',
    );
    BillingNavigationRouteTarget? handledTarget;

    final result = BillingManagementRouteFallbackController(
      onProductWorkspaceRoute: (target) {
        handledTarget = target;
        return true;
      },
    ).handle(routeTarget);

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.handled, isTrue);
    expect(handledTarget, routeTarget);
  });

  test('dispatches tenant selection route fallback to tenant handler', () {
    final routeTarget = BillingNavigationRouteTarget.tenantSelection(
      screenKey: 'test.tenants',
    );
    BillingNavigationRouteTarget? handledTarget;

    final result = BillingManagementRouteFallbackController(
      onTenantSelectionRoute: (target) {
        handledTarget = target;
        return true;
      },
    ).handle(routeTarget);

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.tenantSelection,
    );
    expect(result.handled, isTrue);
    expect(handledTarget, routeTarget);
  });

  test('reports unhandled route targets when no handler is registered', () {
    final routeTarget = BillingNavigationRouteTarget.productWorkspace(
      initialDestinationId: BillingNavigationDestinationId.productWorkspace,
      screenKey: 'test.product.catalog',
    );

    final result = const BillingManagementRouteFallbackController().handle(
      routeTarget,
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isTrue);
  });

  test('keeps none targets as non-actionable', () {
    final result = const BillingManagementRouteFallbackController().handle(
      const BillingNavigationRouteTarget.none(),
    );

    expect(result.kind, BillingManagementRouteFallbackResultKind.none);
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isFalse);
  });
}
