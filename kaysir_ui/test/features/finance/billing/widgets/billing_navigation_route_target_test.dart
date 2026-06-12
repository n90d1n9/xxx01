import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_intent.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  test('route target ignores local embedded intents', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final intent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final target = resolveBillingNavigationRouteTarget(intent);

    expect(target.kind, BillingNavigationRouteTargetKind.none);
    expect(target.opensRoute, isFalse);
  });

  test('route target maps dashboard routes with initial destinations', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final intent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.reports),
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    final target = resolveBillingNavigationRouteTarget(intent);

    expect(target.kind, BillingNavigationRouteTargetKind.dashboard);
    expect(target.opensRoute, isTrue);
    expect(target.initialDestinationId, BillingNavigationDestinationId.reports);
    expect(target.screenKey, 'core.reports');
  });

  test('route target maps product workspace routes', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final intent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final target = resolveBillingNavigationRouteTarget(intent);

    expect(target.kind, BillingNavigationRouteTargetKind.productWorkspace);
    expect(
      target.initialDestinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(target.screenKey, 'commerce.cart_checkout');
  });

  test('route target maps tenant selection routes', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final intent = resolveBillingNavigationRouteIntent(
      launchState: planner.stateFor(BillingNavigationDestinationId.tenants),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    final target = resolveBillingNavigationRouteTarget(intent);

    expect(target.kind, BillingNavigationRouteTargetKind.tenantSelection);
    expect(target.initialDestinationId, isNull);
    expect(target.screenKey, 'core.tenant_selection');
  });

  test('route target ignores unavailable routes', () {
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

    final target = resolveBillingNavigationRouteTarget(intent);

    expect(target.kind, BillingNavigationRouteTargetKind.none);
  });
}
