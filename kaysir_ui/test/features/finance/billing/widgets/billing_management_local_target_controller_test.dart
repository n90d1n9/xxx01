import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_local_target_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_action_resolver.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';

void main() {
  test('dispatches dashboard local targets to dashboard handlers', () {
    final target = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.invoices,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'test.dashboard.invoices',
    );
    BillingNavigationLocalTarget? handledTarget;

    final result = BillingManagementLocalTargetController(
      onDashboardInvoices: (target) {
        handledTarget = target;
        return true;
      },
    ).handle(target);

    expect(result.kind, BillingNavigationLocalTargetKind.dashboardInvoices);
    expect(result.handled, isTrue);
    expect(result.wasUnhandled, isFalse);
    expect(handledTarget, target);
  });

  test('dispatches product local targets to product handlers', () {
    final target = billingProductWorkspaceLocalTargetFor(
      BillingProductWorkspaceNavigationAction.cartCheckout,
      intentKind: BillingNavigationRouteIntentKind.workflow,
      screenKey: 'test.product.cart_checkout',
    );
    BillingNavigationLocalTarget? handledTarget;

    final result = BillingManagementLocalTargetController(
      onCartCheckout: (target) {
        handledTarget = target;
        return true;
      },
    ).handle(target);

    expect(result.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(result.handled, isTrue);
    expect(handledTarget, target);
  });

  test('reports unhandled local targets when no handler is registered', () {
    final target = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.reports,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'test.dashboard.reports',
    );

    final result = const BillingManagementLocalTargetController().handle(
      target,
    );

    expect(result.kind, BillingNavigationLocalTargetKind.dashboardReports);
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isTrue);
  });

  test('keeps none targets non-actionable', () {
    final result = const BillingManagementLocalTargetController().handle(
      const BillingNavigationLocalTarget.none(),
    );

    expect(result.kind, BillingNavigationLocalTargetKind.none);
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isFalse);
  });

  test('keeps destination metadata on result target', () {
    final target = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.createInvoice,
      intentKind: BillingNavigationRouteIntentKind.sheet,
      screenKey: 'test.dashboard.create_invoice',
    );

    final result = BillingManagementLocalTargetController(
      onDashboardCreateInvoice: (_) => true,
    ).handle(target);

    expect(
      result.localTarget.destinationId,
      BillingNavigationDestinationId.createInvoice,
    );
    expect(result.localTarget.screenKey, 'test.dashboard.create_invoice');
  });
}
