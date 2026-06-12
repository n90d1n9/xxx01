import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_plan.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_dispatch_snapshot.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  test('dispatch snapshot maps a surface-ready destination plan list', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final snapshot = planner.destinationDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(snapshot.currentSurface, BillingNavigationSurface.dashboard);
    expect(
      snapshot.defaultDestinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(snapshot.unavailablePlans, isEmpty);
    expect(
      snapshot.localPlans.map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.dashboard,
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.issueOutbox,
        BillingNavigationDestinationId.policyCenter,
      ]),
    );
    expect(
      snapshot.routePlans.map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      snapshot.planForScreenKey('commerce.cart_checkout')?.destinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
  });

  test('dispatch snapshot reconciles selected destinations', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: false,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );

    final snapshot = planner.destinationDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(
      snapshot
          .planFor(BillingNavigationDestinationId.productWorkspace)
          ?.isUnavailable,
      isTrue,
    );
    expect(
      snapshot.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      snapshot.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
        fallbackDestinationIds: const [BillingNavigationDestinationId.tenants],
      ),
      BillingNavigationDestinationId.tenants,
    );
  });

  test('quick action dispatch snapshot supports product workspace routing', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        constructionBillingDomainModule(),
      ),
    );

    final snapshot = planner.quickActionDispatchSnapshot(
      currentSurface: BillingNavigationSurface.productWorkspace,
    );

    expect(
      snapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      snapshot
          .plansForTargetSurface(BillingNavigationSurface.dashboard)
          .map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.issueOutbox,
      ]),
    );
    expect(
      snapshot.routePlans.map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      snapshot
          .plansForKind(BillingNavigationDispatchKind.local)
          .map((plan) => plan.destinationId),
      containsAll([
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.issueOutbox,
      ]),
    );
  });

  test('dispatch snapshot summarizes route handling outcomes', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        constructionBillingDomainModule(),
      ),
    );

    final snapshot = planner.quickActionDispatchSnapshot(
      currentSurface: BillingNavigationSurface.productWorkspace,
    );
    final summary = snapshot.summary;

    expect(summary.totalCount, snapshot.plans.length);
    expect(summary.localCount, snapshot.localPlans.length);
    expect(summary.routeCount, snapshot.routePlans.length);
    expect(summary.unavailableCount, snapshot.unavailablePlans.length);
    expect(summary.ignoredCount, snapshot.ignoredPlans.length);
    expect(summary.actionableCount, summary.localCount + summary.routeCount);
    expect(
      summary.blockedCount,
      summary.unavailableCount + summary.ignoredCount,
    );
    expect(summary.hasActionableRoutes, isTrue);
    expect(summary.hasBlockedRoutes, isFalse);
    expect(summary.isFullyActionable, isTrue);
  });

  test('dispatch snapshot can be built from an existing launch snapshot', () {
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: billingDomainNavigationSetForModule(
        commerceBillingDomainModule(),
      ),
    );
    final launchSnapshot = planner.quickActionSnapshot(
      destinationIds: const [
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.cartCheckout,
      ],
    );

    final snapshot = BillingNavigationDispatchSnapshot.fromLaunchSnapshot(
      launchSnapshot: launchSnapshot,
      currentSurface: BillingNavigationSurface.dashboard,
    );

    expect(snapshot.destinationIds, [
      BillingNavigationDestinationId.createInvoice,
      BillingNavigationDestinationId.cartCheckout,
    ]);
    expect(
      snapshot.localPlans.single.destinationId,
      [BillingNavigationDestinationId.createInvoice].single,
    );
    expect(
      snapshot.routePlans.single.destinationId,
      [BillingNavigationDestinationId.cartCheckout].single,
    );
  });

  test('dispatch snapshot summarizes empty plans safely', () {
    final snapshot = BillingNavigationDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
      defaultDestinationId: BillingNavigationDestinationId.dashboard,
      plans: const [],
    );
    final summary = snapshot.summary;

    expect(summary.isEmpty, isTrue);
    expect(summary.totalCount, 0);
    expect(summary.actionableCount, 0);
    expect(summary.blockedCount, 0);
    expect(summary.hasActionableRoutes, isFalse);
    expect(summary.hasBlockedRoutes, isFalse);
    expect(summary.isFullyActionable, isFalse);
  });
}
