import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_action_resolver.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';

void main() {
  test('route intent preserves disabled launch states', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: false,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final intent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(intent.kind, BillingNavigationRouteIntentKind.unavailable);
    expect(
      intent.destinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(intent.disabledReason, 'Select a tenant first');
    expect(intent.screenKey, 'commerce.product_workspace');
  });

  test('dashboard surface keeps embedded destinations local', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final invoicesIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final createInvoiceIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.createInvoice,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(invoicesIntent.kind, BillingNavigationRouteIntentKind.embedded);
    expect(
      invoicesIntent.dashboardAction,
      BillingDashboardNavigationAction.invoices,
    );
    expect(createInvoiceIntent.kind, BillingNavigationRouteIntentKind.sheet);
    expect(createInvoiceIntent.screenKey, 'core.create_invoice');
  });

  test('dashboard surface routes product workspace workflows', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final productIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final checkoutIntent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(productIntent.kind, BillingNavigationRouteIntentKind.route);
    expect(productIntent.isCrossSurface, isTrue);
    expect(
      productIntent.productWorkspaceAction,
      BillingProductWorkspaceNavigationAction.catalog,
    );
    expect(checkoutIntent.kind, BillingNavigationRouteIntentKind.route);
    expect(checkoutIntent.screenKey, 'commerce.cart_checkout');
  });

  test('product workspace surface keeps catalog and checkout local', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final productIntent = resolveBillingNavigationRouteIntent(
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

    expect(productIntent.kind, BillingNavigationRouteIntentKind.embedded);
    expect(productIntent.isCrossSurface, isFalse);
    expect(checkoutIntent.kind, BillingNavigationRouteIntentKind.workflow);
    expect(
      checkoutIntent.productWorkspaceAction,
      BillingProductWorkspaceNavigationAction.cartCheckout,
    );
  });

  test(
    'product workspace surface routes dashboard sections but keeps sheets',
    () {
      final planner = BillingNavigationLaunchPlanner(
        hasTenant: true,
        navigationSet: billingDomainNavigationSetForModule(
          commerceBillingDomainModule(),
        ),
      );

      final invoicesIntent = resolveBillingNavigationRouteIntent(
        launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
        currentSurface: BillingNavigationSurface.productWorkspace,
      );
      final issueOutboxIntent = resolveBillingNavigationRouteIntent(
        launchState: planner.stateFor(
          BillingNavigationDestinationId.issueOutbox,
        ),
        currentSurface: BillingNavigationSurface.productWorkspace,
      );

      expect(invoicesIntent.kind, BillingNavigationRouteIntentKind.route);
      expect(invoicesIntent.isCrossSurface, isTrue);
      expect(issueOutboxIntent.kind, BillingNavigationRouteIntentKind.sheet);
      expect(issueOutboxIntent.isCrossSurface, isTrue);
    },
  );
}
