import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('dispatch plan reports unavailable launch states', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: false,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final plan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(plan.kind, BillingNavigationDispatchKind.unavailable);
    expect(plan.isUnavailable, isTrue);
    expect(plan.destinationId, BillingNavigationDestinationId.productWorkspace);
    expect(plan.disabledReason, 'Select a tenant first');
    expect(plan.screenKey, 'commerce.product_workspace');
  });

  test('dispatch plan maps dashboard local destinations', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final invoicesPlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final createInvoicePlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.createInvoice,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(invoicesPlan.kind, BillingNavigationDispatchKind.local);
    expect(invoicesPlan.isLocal, isTrue);
    expect(
      invoicesPlan.localTarget.kind,
      BillingNavigationLocalTargetKind.dashboardInvoices,
    );
    expect(createInvoicePlan.kind, BillingNavigationDispatchKind.local);
    expect(createInvoicePlan.localTarget.opensSheet, isTrue);
  });

  test('dispatch plan maps cross-surface routes', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final checkoutPlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final reportsPlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(BillingNavigationDestinationId.reports),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    expect(checkoutPlan.kind, BillingNavigationDispatchKind.route);
    expect(checkoutPlan.opensRoute, isTrue);
    expect(
      checkoutPlan.routeTarget.kind,
      BillingNavigationRouteTargetKind.productWorkspace,
    );
    expect(
      checkoutPlan.routeTarget.initialDestinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(reportsPlan.kind, BillingNavigationDispatchKind.route);
    expect(
      reportsPlan.routeTarget.kind,
      BillingNavigationRouteTargetKind.dashboard,
    );
  });

  test('dispatch plan keeps product workflows local on product surface', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final checkoutPlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    expect(checkoutPlan.kind, BillingNavigationDispatchKind.local);
    expect(
      checkoutPlan.localTarget.kind,
      BillingNavigationLocalTargetKind.cartCheckout,
    );
    expect(checkoutPlan.localTarget.opensWorkflow, isTrue);
  });

  test('dispatch plan ignores hidden module destinations', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        constructionBillingDomainModule(),
      ),
    );

    final plan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(plan.kind, BillingNavigationDispatchKind.unavailable);
    expect(
      plan.disabledReason,
      'This destination is not available for this billing domain.',
    );
  });
}
