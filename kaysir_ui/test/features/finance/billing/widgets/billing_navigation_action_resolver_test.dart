import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_action_resolver.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  test('resolver blocks disabled launch states', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: false);

    final action = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.productWorkspace),
    );

    expect(action.kind, BillingNavigationActionKind.unavailable);
    expect(
      action.destinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(action.disabledReason, 'Select a tenant first');
  });

  test('resolver maps dashboard launch states to dashboard actions', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: true);

    final invoiceAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.invoices),
    );
    final issueOutboxAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.issueOutbox),
    );
    final diagnosticsAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.diagnostics),
    );
    final policyAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.policyCenter),
    );

    expect(invoiceAction.kind, BillingNavigationActionKind.dashboard);
    expect(
      invoiceAction.dashboardAction,
      BillingDashboardNavigationAction.invoices,
    );
    expect(
      issueOutboxAction.dashboardAction,
      BillingDashboardNavigationAction.issueOutbox,
    );
    expect(
      diagnosticsAction.dashboardAction,
      BillingDashboardNavigationAction.diagnostics,
    );
    expect(
      policyAction.dashboardAction,
      BillingDashboardNavigationAction.policyCenter,
    );
    expect(
      billingDestinationForDashboardNavigationAction(
        BillingDashboardNavigationAction.reports,
      ),
      BillingNavigationDestinationId.reports,
    );
    expect(
      billingDestinationForDashboardNavigationAction(
        BillingDashboardNavigationAction.policyCenter,
      ),
      BillingNavigationDestinationId.policyCenter,
    );
    expect(
      billingDestinationForDashboardNavigationAction(
        BillingDashboardNavigationAction.diagnostics,
      ),
      BillingNavigationDestinationId.diagnostics,
    );
  });

  test('resolver maps product workspace states to product actions', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: true);

    final catalogAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.productWorkspace),
    );
    final cartAction = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.cartCheckout),
    );

    expect(catalogAction.kind, BillingNavigationActionKind.productWorkspace);
    expect(
      catalogAction.productWorkspaceAction,
      BillingProductWorkspaceNavigationAction.catalog,
    );
    expect(
      cartAction.productWorkspaceAction,
      BillingProductWorkspaceNavigationAction.cartCheckout,
    );
  });

  test('resolver maps tenant selection states', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: false);

    final action = resolveBillingNavigationAction(
      planner.stateFor(BillingNavigationDestinationId.tenants),
    );

    expect(action.kind, BillingNavigationActionKind.tenantSelection);
    expect(action.destinationId, BillingNavigationDestinationId.tenants);
  });

  test('resolver helpers ignore destinations outside their surface', () {
    expect(
      billingDashboardNavigationActionFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      isNull,
    );
    expect(
      billingProductWorkspaceNavigationActionFor(
        BillingNavigationDestinationId.reports,
      ),
      isNull,
    );
  });
}
