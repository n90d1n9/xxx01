import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_release_channel_launch_dispatch_status.dart';

void main() {
  test('release dispatch status resolves route readiness states', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final routePlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final localPlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(BillingNavigationDestinationId.invoices),
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: false,
        navigationPlan: routePlan,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.route,
    );
    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: false,
        navigationPlan: localPlan,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.local,
    );
    expect(
      BillingProductReleaseChannelLaunchDispatchStatus.route.isActionable,
      isTrue,
    );
    expect(
      BillingProductReleaseChannelLaunchDispatchStatus.local.label,
      'Local',
    );
  });

  test('release dispatch status resolves blocked and missing routes', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: false,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final unavailablePlan = resolveBillingNavigationDispatchPlan(
      launchState: planner.stateFor(
        BillingNavigationDestinationId.productWorkspace,
      ),
      currentSurface: BillingNavigationSurface.dashboard,
    );
    final ignoredPlan = BillingNavigationDispatchPlan.ignored(
      routeIntent: unavailablePlan.routeIntent,
    );

    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: true,
        navigationPlan: unavailablePlan,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease,
    );
    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: false,
        navigationPlan: null,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.notExposed,
    );
    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: false,
        navigationPlan: unavailablePlan,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.unavailable,
    );
    expect(
      billingProductReleaseChannelLaunchDispatchStatusFor(
        isBlockedByRelease: false,
        navigationPlan: ignoredPlan,
      ),
      BillingProductReleaseChannelLaunchDispatchStatus.ignored,
    );
    expect(
      BillingProductReleaseChannelLaunchDispatchStatus
          .notExposed
          .needsRoutingWork,
      isTrue,
    );
    expect(
      BillingProductReleaseChannelLaunchDispatchStatus
          .blockedByRelease
          .needsRoutingWork,
      isFalse,
    );
  });
}
