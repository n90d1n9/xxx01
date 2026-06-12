import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_fallback_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_management_route_open_controller.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_route_target.dart';

void main() {
  testWidgets('prepares dashboard route opening before app route lookup', (
    tester,
  ) async {
    final routeTarget = BillingNavigationRouteTarget.dashboard(
      initialDestinationId: BillingNavigationDestinationId.invoices,
      screenKey: 'test.dashboard.invoices',
    );
    BillingNavigationRouteTarget? preparedTarget;

    final result = await _openRouteInMaterialApp(
      tester,
      routeTarget: routeTarget,
      onDashboardRouteOpening: (target) {
        preparedTarget = target;
      },
    );

    expect(result.kind, BillingManagementRouteFallbackResultKind.dashboard);
    expect(result.didOpen, isFalse);
    expect(preparedTarget, routeTarget);
  });

  testWidgets('prepares product workspace route opening', (tester) async {
    final routeTarget = BillingNavigationRouteTarget.productWorkspace(
      initialDestinationId: BillingNavigationDestinationId.cartCheckout,
      screenKey: 'test.product.cart_checkout',
    );
    BillingNavigationRouteTarget? preparedTarget;

    final result = await _openRouteInMaterialApp(
      tester,
      routeTarget: routeTarget,
      onProductWorkspaceRouteOpening: (target) {
        preparedTarget = target;
      },
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.productWorkspace,
    );
    expect(result.didOpen, isFalse);
    expect(preparedTarget, routeTarget);
  });

  testWidgets('prepares tenant selection route opening', (tester) async {
    final routeTarget = BillingNavigationRouteTarget.tenantSelection(
      screenKey: 'test.tenants',
    );
    BillingNavigationRouteTarget? preparedTarget;

    final result = await _openRouteInMaterialApp(
      tester,
      routeTarget: routeTarget,
      onTenantSelectionRouteOpening: (target) {
        preparedTarget = target;
      },
    );

    expect(
      result.kind,
      BillingManagementRouteFallbackResultKind.tenantSelection,
    );
    expect(result.didOpen, isFalse);
    expect(preparedTarget, routeTarget);
  });

  testWidgets('does not prepare none route targets', (tester) async {
    var prepareCount = 0;

    final result = await _openRouteInMaterialApp(
      tester,
      routeTarget: const BillingNavigationRouteTarget.none(),
      onDashboardRouteOpening: (_) {
        prepareCount += 1;
      },
      onProductWorkspaceRouteOpening: (_) {
        prepareCount += 1;
      },
      onTenantSelectionRouteOpening: (_) {
        prepareCount += 1;
      },
    );

    expect(result.kind, BillingManagementRouteFallbackResultKind.none);
    expect(result.didOpen, isFalse);
    expect(prepareCount, 0);
  });
}

Future<BillingManagementRouteOpenResult> _openRouteInMaterialApp(
  WidgetTester tester, {
  required BillingNavigationRouteTarget routeTarget,
  BillingManagementRouteOpeningHandler? onDashboardRouteOpening,
  BillingManagementRouteOpeningHandler? onProductWorkspaceRouteOpening,
  BillingManagementRouteOpeningHandler? onTenantSelectionRouteOpening,
}) async {
  late BillingManagementRouteOpenResult result;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                result = BillingManagementRouteOpenController(
                  context: context,
                  onDashboardRouteOpening: onDashboardRouteOpening,
                  onProductWorkspaceRouteOpening:
                      onProductWorkspaceRouteOpening,
                  onTenantSelectionRouteOpening: onTenantSelectionRouteOpening,
                ).openResult(routeTarget);
              },
              child: const Text('Open route'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open route'));
  await tester.pump();

  return result;
}
