import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_local_target_action_set.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_action_resolver.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';

void main() {
  test('dashboard action set exposes and dispatches dashboard handlers', () {
    final handledKinds = <BillingNavigationLocalTargetKind>[];
    final actionSet = BillingManagementLocalTargetActionSet.dashboard(
      onDashboardInvoices: (target) {
        handledKinds.add(target.kind);
        return true;
      },
      onDashboardReports: (target) {
        handledKinds.add(target.kind);
        return true;
      },
      onDashboardPolicyCenter: (target) {
        handledKinds.add(target.kind);
        return true;
      },
    );

    final invoicesTarget = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.invoices,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'test.dashboard.invoices',
    );
    final policyTarget = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.policyCenter,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'test.dashboard.policy',
    );

    expect(actionSet.surface, BillingNavigationSurface.dashboard);
    expect(actionSet.hasHandlers, isTrue);
    expect(actionSet.supports(invoicesTarget), isTrue);
    expect(
      actionSet.supportedTargetKinds,
      containsAll([
        BillingNavigationLocalTargetKind.dashboardInvoices,
        BillingNavigationLocalTargetKind.dashboardReports,
        BillingNavigationLocalTargetKind.dashboardPolicyCenter,
      ]),
    );

    expect(actionSet.handleTarget(invoicesTarget), isTrue);
    expect(actionSet.handleTarget(policyTarget), isTrue);
    expect(handledKinds, [
      BillingNavigationLocalTargetKind.dashboardInvoices,
      BillingNavigationLocalTargetKind.dashboardPolicyCenter,
    ]);
  });

  test('product workspace action set can expose shared sheet actions', () {
    final handledKinds = <BillingNavigationLocalTargetKind>[];
    final actionSet = BillingManagementLocalTargetActionSet.productWorkspace(
      onDashboardIssueOutbox: (target) {
        handledKinds.add(target.kind);
        return true;
      },
      onCartCheckout: (target) {
        handledKinds.add(target.kind);
        return true;
      },
    );

    final issueOutboxTarget = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.issueOutbox,
      intentKind: BillingNavigationRouteIntentKind.sheet,
      screenKey: 'test.product.issue_outbox',
    );
    final checkoutTarget = billingProductWorkspaceLocalTargetFor(
      BillingProductWorkspaceNavigationAction.cartCheckout,
      intentKind: BillingNavigationRouteIntentKind.workflow,
      screenKey: 'test.product.cart_checkout',
    );

    expect(actionSet.surface, BillingNavigationSurface.productWorkspace);
    expect(actionSet.supports(issueOutboxTarget), isTrue);
    expect(actionSet.supports(checkoutTarget), isTrue);

    expect(actionSet.handleTarget(issueOutboxTarget), isTrue);
    expect(actionSet.handleTarget(checkoutTarget), isTrue);
    expect(handledKinds, [
      BillingNavigationLocalTargetKind.dashboardIssueOutbox,
      BillingNavigationLocalTargetKind.cartCheckout,
    ]);
  });

  test('action set keeps unregistered local targets unhandled', () {
    final actionSet = BillingManagementLocalTargetActionSet.dashboard(
      onDashboardOverview: (_) => true,
    );
    final reportsTarget = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.reports,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'test.dashboard.reports',
    );

    final result = actionSet.handle(reportsTarget);

    expect(actionSet.supports(reportsTarget), isFalse);
    expect(result.handled, isFalse);
    expect(result.wasUnhandled, isTrue);
  });
}
