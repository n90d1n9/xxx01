import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_link.dart';
import 'package:kaysir/features/finance/billing/models/billing_route_link_navigation_model.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_drawer.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_scaffold.dart';

void main() {
  testWidgets(
    'BillingNavigationScaffold keeps navigation persistent when wide',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      BillingNavigationDestinationId? selectedDestination;

      await tester.pumpWidget(
        MaterialApp(
          home: BillingNavigationScaffold(
            selectedDestination: BillingNavigationDestinationId.dashboard,
            tenantName: 'Acme Corp',
            onDestinationSelected: (destination) {
              selectedDestination = destination;
            },
            appBar: AppBar(title: const Text('Billing')),
            body: const Center(child: Text('Dashboard body')),
          ),
        ),
      );

      expect(find.text('Kaysir Billing'), findsOneWidget);
      expect(find.byTooltip('Open navigation menu'), findsNothing);

      await tester.tap(find.text('Products & checkout'));
      await tester.pump();

      expect(
        selectedDestination,
        BillingNavigationDestinationId.productWorkspace,
      );
    },
  );

  testWidgets('BillingNavigationScaffold uses a drawer when compact', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(700, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.dashboard,
          tenantName: 'Acme Corp',
          onDestinationSelected: (_) {},
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Dashboard body')),
        ),
      ),
    );

    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Products & checkout'), findsOneWidget);
  });

  testWidgets('BillingNavigationScaffold disables tenant routes when empty', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.tenants,
          hasTenant: false,
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Tenant body')),
        ),
      ),
    );

    expect(find.text('Select a tenant first'), findsWidgets);

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(selectedDestination, isNull);
  });

  testWidgets('BillingNavigationScaffold forwards dispatch snapshots', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.dashboard,
          dispatchSnapshot: dispatchSnapshot,
          onDestinationSelected: (_) {},
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Dashboard body')),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('BillingNavigationScaffold forwards route links', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.dashboard,
          routeLinks: [
            billingRouteLinkForDestination(
              BillingNavigationDestinationId.tenants,
            )!,
          ],
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Dashboard body')),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);

    await tester.tap(find.text('Tenants'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });

  testWidgets('BillingNavigationScaffold forwards route-link models', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    BillingNavigationDestinationId? selectedDestination;
    final routeLinkNavigationModel = BillingRouteLinkNavigationModel(
      routeLinks: [
        billingRouteLinkForDestination(BillingNavigationDestinationId.tenants)!,
      ],
      selectedDestinationId: BillingNavigationDestinationId.dashboard,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.dashboard,
          routeLinkNavigationModel: routeLinkNavigationModel,
          routeLinks: [
            billingRouteLinkForDestination(
              BillingNavigationDestinationId.invoices,
            )!,
          ],
          onDestinationSelected: (destination) {
            selectedDestination = destination;
          },
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Dashboard body')),
        ),
      ),
    );

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Invoices'), findsNothing);

    await tester.tap(find.text('Tenants'));
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });

  testWidgets('BillingNavigationScaffold forwards coverage summaries', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final coverageSummary =
        BillingNavigationCoverageReport.forModule(
          commerceBillingDomainModule(),
        ).summary;

    await tester.pumpWidget(
      MaterialApp(
        home: BillingNavigationScaffold(
          selectedDestination: BillingNavigationDestinationId.dashboard,
          coverageSummary: coverageSummary,
          onDestinationSelected: (_) {},
          appBar: AppBar(title: const Text('Billing')),
          body: const Center(child: Text('Dashboard body')),
        ),
      ),
    );

    expect(find.text('Ready'), findsOneWidget);
    expect(find.byTooltip(coverageSummary.summaryLabel), findsOneWidget);
  });
}
