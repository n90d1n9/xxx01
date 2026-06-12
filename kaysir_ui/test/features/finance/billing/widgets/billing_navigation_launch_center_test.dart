import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_center.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';

void main() {
  testWidgets('BillingNavigationLaunchCenter renders and opens routes', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await _pumpLaunchCenter(
      tester,
      destinations: [
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.dashboard,
        ),
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.invoices,
        ),
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.diagnostics,
        ),
      ],
      onDestinationSelected: (destination) {
        selectedDestination = destination;
      },
    );

    expect(find.text('Route launch center'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.text('Local'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('billing-launch-center-open-invoices')),
    );
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.invoices);
  });

  testWidgets('BillingNavigationLaunchCenter filters registered routes', (
    tester,
  ) async {
    await _pumpLaunchCenter(tester);

    await tester.enterText(
      find.byKey(const ValueKey('billing-launch-center-search')),
      'outbox',
    );
    await tester.pump();

    expect(find.text('Issue outbox'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('billing-launch-center-open-dashboard')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const ValueKey('billing-launch-center-search')),
      'missing-route',
    );
    await tester.pump();

    expect(
      find.text('No registered billing routes match the current search.'),
      findsOneWidget,
    );
  });

  testWidgets('BillingNavigationLaunchCenter blocks tenant gated routes', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await _pumpLaunchCenter(
      tester,
      hasTenant: false,
      destinations: [
        billingNavigationDestinationFor(
          BillingNavigationDestinationId.productWorkspace,
        ),
        billingNavigationDestinationFor(BillingNavigationDestinationId.tenants),
      ],
      onDestinationSelected: (destination) {
        selectedDestination = destination;
      },
    );

    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Select a tenant first'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);

    await tester.tap(
      find.byKey(const ValueKey('billing-launch-center-open-productWorkspace')),
    );
    await tester.pump();
    expect(selectedDestination, isNull);

    await tester.tap(
      find.byKey(const ValueKey('billing-launch-center-open-tenants')),
    );
    await tester.pump();
    expect(selectedDestination, BillingNavigationDestinationId.tenants);
  });
}

Future<void> _pumpLaunchCenter(
  WidgetTester tester, {
  bool hasTenant = true,
  List<BillingNavigationDestination>? destinations,
  ValueChanged<BillingNavigationDestinationId>? onDestinationSelected,
}) async {
  final planner = BillingNavigationLaunchPlanner(hasTenant: hasTenant);
  final launchSnapshot = planner.destinationSnapshot(
    destinations: destinations,
  );
  final dispatchSnapshot = planner.destinationDispatchSnapshot(
    currentSurface: BillingNavigationSurface.dashboard,
    destinations: destinations,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: BillingNavigationLaunchCenter(
              launchSnapshot: launchSnapshot,
              dispatchSnapshot: dispatchSnapshot,
              selectedDestination: BillingNavigationDestinationId.dashboard,
              onDestinationSelected: onDestinationSelected,
            ),
          ),
        ),
      ),
    ),
  );
}
