import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_action_resolver.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_local_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('local target ignores route and unavailable intents', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final routeIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final unavailableIntent = resolveBillingNavigationRouteIntent(
      launchState: BillingNavigationLaunchPlanner(
        hasTenant: false,
        navigationSet: billingDomainNavigationSetForModule(
          commerceBillingDomainModule(),
        ),
      ).stateFor(BillingNavigationDestinationId.productWorkspace),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(
      resolveBillingNavigationLocalTarget(routeIntent).kind,
      BillingNavigationLocalTargetKind.none,
    );
    expect(
      resolveBillingNavigationLocalTarget(unavailableIntent).kind,
      BillingNavigationLocalTargetKind.none,
    );
  });

  test('local target maps dashboard embedded and sheet actions', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final invoiceIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final createInvoiceIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.createInvoice,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final diagnosticsIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.diagnostics),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final policyIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.policyCenter,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final invoiceTarget = resolveBillingNavigationLocalTarget(invoiceIntent);
    final createInvoiceTarget = resolveBillingNavigationLocalTarget(
      createInvoiceIntent,
    );
    final diagnosticsTarget = resolveBillingNavigationLocalTarget(
      diagnosticsIntent,
    );
    final policyTarget = resolveBillingNavigationLocalTarget(policyIntent);

    expect(
      invoiceTarget.kind,
      BillingNavigationLocalTargetKind.dashboardInvoices,
    );
    expect(
      invoiceTarget.destinationId,
      BillingNavigationDestinationId.invoices,
    );
    expect(invoiceTarget.opensSheet, isFalse);
    expect(
      createInvoiceTarget.kind,
      BillingNavigationLocalTargetKind.dashboardCreateInvoice,
    );
    expect(createInvoiceTarget.opensSheet, isTrue);
    expect(createInvoiceTarget.screenKey, 'core.create_invoice');
    expect(
      diagnosticsTarget.kind,
      BillingNavigationLocalTargetKind.dashboardDiagnostics,
    );
    expect(diagnosticsTarget.opensSheet, isFalse);
    expect(diagnosticsTarget.screenKey, 'core.diagnostics');
    expect(
      policyTarget.kind,
      BillingNavigationLocalTargetKind.dashboardPolicyCenter,
    );
    expect(policyTarget.opensSheet, isFalse);
    expect(policyTarget.screenKey, 'core.policy_center');
  });

  test('local target maps product embedded and workflow actions', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final catalogIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );
    final checkoutIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    final catalogTarget = resolveBillingNavigationLocalTarget(catalogIntent);
    final checkoutTarget = resolveBillingNavigationLocalTarget(checkoutIntent);

    expect(catalogTarget.kind, BillingNavigationLocalTargetKind.productCatalog);
    expect(catalogTarget.opensWorkflow, isFalse);
    expect(checkoutTarget.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(
      checkoutTarget.destinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(checkoutTarget.opensWorkflow, isTrue);
  });

  test('local target keeps billing sheets local across surfaces', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final issueOutboxIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.issueOutbox),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    final target = resolveBillingNavigationLocalTarget(issueOutboxIntent);

    expect(target.kind, BillingNavigationLocalTargetKind.dashboardIssueOutbox);
    expect(target.intentKind, BillingNavigationRouteIntentKind.sheet);
    expect(target.opensSheet, isTrue);
  });

  test('local target helper maps actions directly', () {
    final dashboardTarget = billingDashboardLocalTargetFor(
      BillingDashboardNavigationAction.reports,
      intentKind: BillingNavigationRouteIntentKind.embedded,
      screenKey: 'core.reports',
    );
    final productTarget = billingProductWorkspaceLocalTargetFor(
      BillingProductWorkspaceNavigationAction.cartCheckout,
      intentKind: BillingNavigationRouteIntentKind.workflow,
      screenKey: 'commerce.cart_checkout',
    );

    expect(
      dashboardTarget.kind,
      BillingNavigationLocalTargetKind.dashboardReports,
    );
    expect(
      dashboardTarget.destinationId,
      BillingNavigationDestinationId.reports,
    );
    expect(productTarget.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(productTarget.screenKey, 'commerce.cart_checkout');
  });

  test('local target helper maps dashboard route targets', () {
    final target = billingLocalTargetForRouteTarget(
      BillingNavigationRouteTarget.dashboard(
        initialDestinationId: BillingNavigationDestinationId.reports,
        screenKey: 'core.reports',
      ),
    );

    expect(target.kind, BillingNavigationLocalTargetKind.dashboardReports);
    expect(target.destinationId, BillingNavigationDestinationId.reports);
    expect(target.intentKind, BillingNavigationRouteIntentKind.route);
    expect(target.screenKey, 'core.reports');
  });

  test('local target helper maps product route targets with fallback keys', () {
    final target = billingLocalTargetForRouteTarget(
      const BillingNavigationRouteTarget.productWorkspace(
        initialDestinationId: BillingNavigationDestinationId.cartCheckout,
        screenKey: '',
      ),
      fallbackScreenKey: 'fallback.product.cart_checkout',
    );

    expect(target.kind, BillingNavigationLocalTargetKind.cartCheckout);
    expect(target.destinationId, BillingNavigationDestinationId.cartCheckout);
    expect(target.intentKind, BillingNavigationRouteIntentKind.route);
    expect(target.screenKey, 'fallback.product.cart_checkout');
  });

  test('local target helper ignores unsupported route targets', () {
    final tenantTarget = billingLocalTargetForRouteTarget(
      const BillingNavigationRouteTarget.tenantSelection(
        screenKey: 'core.tenants',
      ),
    );
    final invalidDashboardTarget = billingLocalTargetForRouteTarget(
      BillingNavigationRouteTarget.dashboard(
        initialDestinationId: BillingNavigationDestinationId.cartCheckout,
        screenKey: 'invalid.dashboard.cart_checkout',
      ),
    );
    final noneTarget = billingLocalTargetForRouteTarget(
      const BillingNavigationRouteTarget.none(),
    );

    expect(tenantTarget.isNone, isTrue);
    expect(invalidDashboardTarget.isNone, isTrue);
    expect(noneTarget.isNone, isTrue);
  });
}
