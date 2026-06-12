import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_local_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('handles dashboard route targets through local navigation', () {
    final routeTarget = BillingNavigationRouteTarget.dashboard(
      initialDestinationId: BillingNavigationDestinationId.reports,
      screenKey: 'route.dashboard.reports',
    );
    BillingNavigationLocalTarget? handledTarget;

    final result = BillingManagementRouteLocalFallbackController(
      onLocalNavigation: (localTarget) {
        handledTarget = localTarget;
        return true;
      },
    ).handle(routeTarget);

    expect(result.routeTarget, routeTarget);
    expect(result.hasLocalTarget, isTrue);
    expect(result.handled, isTrue);
    expect(result.wasUnhandled, isFalse);
    expect(
      result.localTarget.kind,
      BillingNavigationLocalTargetKind.dashboardReports,
    );
    expect(
      result.localTarget.intentKind,
      BillingNavigationRouteIntentKind.route,
    );
    expect(handledTarget, result.localTarget);
  });

  test('applies fallback screen keys for local product workspace routes', () {
    BillingNavigationLocalTarget? handledTarget;

    final result = BillingManagementRouteLocalFallbackController(
      fallbackScreenKey: 'fallback.product.cart_checkout',
      onLocalNavigation: (localTarget) {
        handledTarget = localTarget;
        return true;
      },
    ).handle(
      const BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: BillingNavigationDestinationId.cartCheckout,
        screenKey: '',
      ),
    );

    expect(result.handled, isTrue);
    expect(
      result.localTarget.kind,
      BillingNavigationLocalTargetKind.cartCheckout,
    );
    expect(result.localTarget.screenKey, 'fallback.product.cart_checkout');
    expect(handledTarget, result.localTarget);
  });

  test(
    'reports unsupported route targets without calling local navigation',
    () {
      var handlerCalls = 0;

      final result = BillingManagementRouteLocalFallbackController(
        onLocalNavigation: (_) {
          handlerCalls += 1;
          return true;
        },
      ).handle(
        const BillingNavigationRouteTarget.tenantSelection(
          screenKey: 'route.tenants',
        ),
      );

      expect(result.hasLocalTarget, isFalse);
      expect(result.handled, isFalse);
      expect(result.wasUnhandled, isFalse);
      expect(handlerCalls, 0);
    },
  );

  test('reports unhandled local route fallbacks when handler declines', () {
    final result = BillingManagementRouteLocalFallbackController(
      onLocalNavigation: (_) => false,
    ).handle(
      BillingNavigationRouteTarget.dashboard(
        initialDestinationId: BillingNavigationDestinationId.invoices,
        screenKey: 'route.dashboard.invoices',
      ),
    );

    expect(result.hasLocalTarget, isTrue);
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isTrue);
  });
}
