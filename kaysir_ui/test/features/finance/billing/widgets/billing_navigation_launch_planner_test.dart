import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  test('planner defaults to legacy destinations without a module set', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: false);

    expect(planner.destinations, BillingNavigationDestination.all);
    expect(planner.quickActionIds, BillingNavigationDestination.quickActionIds);
    expect(
      planner.defaultDestinationId,
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      planner
          .stateFor(BillingNavigationDestinationId.productWorkspace)
          .isEnabled,
      isFalse,
    );
  });

  test('planner follows module destinations and quick actions', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: navigationSet,
    );

    expect(
      planner.destinations.map((destination) => destination.id),
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      planner.quickActionIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
    expect(
      planner.destinationStates().map((state) => state.destinationId),
      contains(BillingNavigationDestinationId.invoices),
    );
  });

  test('planner can evaluate injected destinations against module rules', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: navigationSet,
    );

    final states = planner.destinationStates(
      destinations: [
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.cartCheckout,
        ),
      ],
    );

    expect(
      states.single.destinationId,
      BillingNavigationDestinationId.cartCheckout,
    );
    expect(states.single.isEnabled, isFalse);
    expect(
      states.single.disabledReason,
      'This destination is not available for this billing domain.',
    );
  });

  test('planner resolves the first enabled destination', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: false);

    final state = planner.firstEnabledState(
      destinationIds: const [
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.tenants,
      ],
    );

    expect(state?.destinationId, BillingNavigationDestinationId.tenants);
  });

  test('planner builds reusable destination snapshots', () {
    const planner = BillingNavigationLaunchPlanner(hasTenant: false);

    final snapshot = planner.destinationSnapshot();

    expect(snapshot.states.length, BillingNavigationDestination.all.length);
    expect(snapshot.enabledStates.map((state) => state.destinationId), [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.tenants,
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ]);
    expect(
      snapshot.disabledStates.map((state) => state.destinationId),
      containsAll([
        BillingNavigationDestinationId.workCenter,
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
        BillingNavigationDestinationId.createInvoice,
      ]),
    );
    expect(
      snapshot
          .statesForSurface(BillingNavigationSurface.productWorkspace)
          .map((state) => state.destinationId),
      [
        BillingNavigationDestinationId.productWorkspace,
        BillingNavigationDestinationId.cartCheckout,
      ],
    );
    expect(snapshot.sections.map((section) => section.label), [
      'Workspace',
      'Billing operations',
      'System',
    ]);
    expect(snapshot.sections.first.destinationIds, [
      BillingNavigationDestinationId.dashboard,
      BillingNavigationDestinationId.workCenter,
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.cartCheckout,
      BillingNavigationDestinationId.tenants,
    ]);
    expect(snapshot.sections.last.destinationIds, [
      BillingNavigationDestinationId.policyCenter,
      BillingNavigationDestinationId.diagnostics,
    ]);
  });

  test('planner builds reusable quick action snapshots', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: navigationSet,
    );

    final snapshot = planner.quickActionSnapshot();

    expect(
      snapshot.destinationIds,
      containsAll([
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.invoices,
        BillingNavigationDestinationId.reports,
        BillingNavigationDestinationId.issueOutbox,
        BillingNavigationDestinationId.tenants,
      ]),
    );
    expect(
      snapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.productWorkspace)),
    );
    expect(
      snapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(snapshot.disabledStates, isEmpty);
    expect(snapshot.sections.first.label, isNull);
    expect(snapshot.sections.last.label, 'Billing operations');
  });

  test('planner reconciles unavailable selected destinations', () {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );
    final planner = BillingNavigationLaunchPlanner(
      hasTenant: true,
      navigationSet: navigationSet,
    );

    expect(
      planner.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
    expect(
      planner.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
        fallbackDestinationIds: const [
          BillingNavigationDestinationId.invoices,
          BillingNavigationDestinationId.tenants,
        ],
      ),
      BillingNavigationDestinationId.invoices,
    );
  });
}
