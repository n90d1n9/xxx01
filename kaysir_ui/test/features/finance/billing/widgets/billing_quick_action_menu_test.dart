import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_modules.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_domain_navigation_policy.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_launch_planner.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_quick_action_menu.dart';

void main() {
  testWidgets('BillingQuickActionMenu emits selected destinations', (
    tester,
  ) async {
    BillingNavigationDestinationId? selectedDestination;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: true,
                onDestinationSelected: (destination) {
                  selectedDestination = destination;
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Create invoice'), findsOneWidget);
    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Cart & checkout'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('billing-quick-action-createInvoice')),
    );
    await tester.pumpAndSettle();

    expect(selectedDestination, BillingNavigationDestinationId.createInvoice);
  });

  testWidgets('BillingQuickActionMenu disables tenant-scoped actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: false,
                onDestinationSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    final createInvoiceAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-createInvoice')),
        );
    final tenantAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-tenants')),
        );
    final productWorkspaceAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-productWorkspace')),
        );
    final cartCheckoutAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-cartCheckout')),
        );

    expect(createInvoiceAction.enabled, isFalse);
    expect(productWorkspaceAction.enabled, isFalse);
    expect(cartCheckoutAction.enabled, isFalse);
    expect(tenantAction.enabled, isTrue);
    expect(find.text('Select a tenant first'), findsWidgets);
  });

  testWidgets('BillingQuickActionMenu defaults to module quick actions', (
    tester,
  ) async {
    final navigationSet = billingDomainNavigationSetForModule(
      constructionBillingDomainModule(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: true,
                navigationSet: navigationSet,
                onDestinationSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Create invoice'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);
    expect(find.text('Cart & checkout'), findsNothing);
  });

  testWidgets('BillingQuickActionMenu accepts precomputed snapshots', (
    tester,
  ) async {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).quickActionSnapshot(
      destinationIds: const [BillingNavigationDestinationId.tenants],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: true,
                destinations: const [
                  BillingNavigationDestinationId.createInvoice,
                ],
                launchSnapshot: launchSnapshot,
                onDestinationSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Create invoice'), findsNothing);
  });

  testWidgets('BillingQuickActionMenu accepts dispatch snapshots', (
    tester,
  ) async {
    final launchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).quickActionSnapshot(
      destinationIds: const [BillingNavigationDestinationId.createInvoice],
    );
    final dispatchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: true,
    ).quickActionDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
      destinationIds: const [BillingNavigationDestinationId.tenants],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: true,
                launchSnapshot: launchSnapshot,
                dispatchSnapshot: dispatchSnapshot,
                onDestinationSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Tenants'), findsOneWidget);
    expect(find.text('Create invoice'), findsNothing);
  });

  testWidgets('BillingQuickActionMenu disables unavailable dispatch plans', (
    tester,
  ) async {
    final dispatchSnapshot = const BillingNavigationLaunchPlanner(
      hasTenant: false,
    ).quickActionDispatchSnapshot(
      currentSurface: BillingNavigationSurface.dashboard,
      destinationIds: const [
        BillingNavigationDestinationId.createInvoice,
        BillingNavigationDestinationId.tenants,
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              BillingQuickActionMenu(
                hasTenant: false,
                dispatchSnapshot: dispatchSnapshot,
                onDestinationSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    final createInvoiceAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-createInvoice')),
        );
    final tenantAction = tester
        .widget<PopupMenuItem<BillingNavigationDestinationId>>(
          find.byKey(const ValueKey('billing-quick-action-tenants')),
        );

    expect(createInvoiceAction.enabled, isFalse);
    expect(tenantAction.enabled, isTrue);
    expect(find.text('Select a tenant first'), findsOneWidget);
  });
}
