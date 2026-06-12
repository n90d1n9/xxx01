import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_link.dart';
import 'package:kaysir/features/finance/billing/models/billing_route_link_navigation_model.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_drawer.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  testWidgets('BillingNavigationDrawer exposes all billing destinations', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            tenantName: 'Acme Corp',
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Kaysir Billing'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Cart & checkout'), findsOneWidget);
    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Create invoice'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Reports & insights'),
      120,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Reports & insights'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Issue outbox'),
      120,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Issue outbox'), findsOneWidget);

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(
      selectedDestination,
      BillingNavigationDestinationId.productWorkspace,
    );
  });

  testWidgets('BillingNavigationDrawer disables tenant-scoped destinations', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.tenants,
            hasTenant: false,
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Cart & checkout'), findsOneWidget);
    expect(find.text('Select a tenant first'), findsWidgets);

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(selectedDestination, isNull);
  });

  testWidgets('BillingNavigationDrawer can render filtered destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            destinations: [
              billingNavigationDestinationFor(
                BillingNavigationDestinationId.dashboard,
              ),
              billingNavigationDestinationFor(
                BillingNavigationDestinationId.invoices,
              ),
              billingNavigationDestinationFor(
                BillingNavigationDestinationId.tenants,
              ),
            ],
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);
    expect(find.text('Cart & checkout'), findsNothing);
  });

  testWidgets('BillingNavigationDrawer defaults to module destinations', (
    tester,
  ) async {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            navigationSet: navigationSet,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);
    expect(find.text('Cart & checkout'), findsNothing);
  });

  testWidgets('BillingNavigationDrawer disables unsupported module screens', (
    tester,
  ) async {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            navigationSet: navigationSet,
            destinations: [
              billingNavigationDestinationFor(
                BillingNavigationDestinationId.cartCheckout,
              ),
            ],
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Cart & checkout'), findsOneWidget);
    expect(
      find.text('This destination is not available for this billing domain.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cart & checkout'));
    await tester.pump();

    expect(selectedDestination, isNull);
  });

  testWidgets('BillingNavigationDrawer accepts precomputed snapshots', (
    tester,
  ) async {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).snapshotFor(const [BillingNavigationDestinationId.tenants]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            destinations: [
              billingNavigationDestinationFor(
                BillingNavigationDestinationId.dashboard,
              ),
            ],
            launchSnapshot: launchSnapshot,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('BillingNavigationDrawer accepts precomputed route links', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            routeLinks: [
              billingRouteLinkForDestination(
                BillingNavigationDestinationId.tenants,
              )!,
            ],
            launchSnapshot: const BillingNavigationLaunchPlanner(
              hasTenant: true,
            ).snapshotFor(const [BillingNavigationDestinationId.dashboard]),
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);

    await tester.tap(find.text('Tenants'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });

  testWidgets('BillingNavigationDrawer accepts route-link navigation models', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;
    final routeLinkNavigationModel = BillingRouteLinkNavigationModel(
      routeLinks: [
        billingRouteLinkForDestination(BillingNavigationDestinationId.tenants)!,
      ],
      selectedDestinationId: BillingNavigationDestinationId.dashboard,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            routeLinkNavigationModel: routeLinkNavigationModel,
            routeLinks: [
              billingRouteLinkForDestination(
                BillingNavigationDestinationId.invoices,
              )!,
            ],
            launchSnapshot: const BillingNavigationLaunchPlanner(
              hasTenant: true,
            ).snapshotFor(const [BillingNavigationDestinationId.dashboard]),
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Invoices'), findsNothing);

    await tester.tap(find.text('Tenants'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });

  testWidgets('BillingNavigationDrawer disables unavailable route links', (
    tester,
  ) async {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: false,
    ).snapshotFor(const [BillingNavigationDestinationId.productWorkspace]);
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.tenants,
            routeLinks: [
              billingRouteLinkForDestination(
                BillingNavigationDestinationId.productWorkspace,
                launchSnapshot: launchSnapshot,
              )!,
            ],
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Select a tenant first'), findsOneWidget);

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(selectedDestination, isNull);
  });

  testWidgets('BillingNavigationDrawer accepts dispatch snapshots', (
    tester,
  ) async {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).snapshotFor(const [BillingNavigationDestinationId.dashboard]);
    final dispatchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).destinationDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
      destinations: [
        billingNavigationDestinationFor(BillingNavigationDestinationId.tenants),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            launchSnapshot: launchSnapshot,
            dispatchSnapshot: dispatchSnapshot,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('BillingNavigationDrawer disables unavailable dispatch plans', (
    tester,
  ) async {
    final dispatchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: false,
    ).destinationDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
      destinations: [
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.productWorkspace,
        ),
        billingNavigationDestinationFor(BillingNavigationDestinationId.tenants),
      ],
    );
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            dispatchSnapshot: dispatchSnapshot,
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
          ),
        ),
      ),
    );

    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Select a tenant first'), findsOneWidget);

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();
    expect(selectedDestination, isNull);

    await tester.tap(find.text('Tenants'));
    await tester.pump();
    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });

  testWidgets('BillingNavigationDrawer renders navigation coverage summary', (
    tester,
  ) async {
    final coverageSummary =
        BillingNavigationCoverageReport.forModule(
          commerceBillingDomainModule(),
          hasTenant: false,
        ).summary;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingNavigationDrawer(
            selectedDestination: BillingNavigationDestinationId.tenants,
            hasTenant: false,
            coverageSummary: coverageSummary,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.byTooltip(coverageSummary.summaryLabel), findsOneWidget);
  });
}
