import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/admin/services/admin_route_search_index.dart';
import 'package:kaysir/features/finance/billing/billing_features.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_page_builder_registry.dart';
import 'package:kaysir/widgets/side_menu/side_menu.dart';

void main() {
  test('billing feature exposes management screens in the sidebar', () {
    final billing = BillingFeatures().registerScreens().single;
    final routeContract = BillingRouteContractReport.forFeatureRoute(
      rootRoute: billing,
    );

    expect(billing.name, BillingRoutes.managementRouteName);
    expect(billing.title, BillingRoutes.managementTitle);
    expect(billing.goRouteName, BillingRoutes.managementRouteName);
    expect(billing.path, BillingRoutes.managementPath);
    expect(billing.pageBuilder, isNotNull);
    expect(billing.position, contains(MenuPosition.sidebar));
    expect(
      routeContract.isComplete,
      isTrue,
      reason: routeContract.summaryLabel,
    );
    expect(routeContract.actualSidebarPaths, [
      BillingRoutes.workspacesPath,
      BillingRoutes.workCenterPath,
      BillingRoutes.invoicesPath,
      BillingRoutes.createInvoicePath,
      BillingRoutes.insightsPath,
      BillingRoutes.issueOutboxPath,
      BillingRoutes.policyPath,
      BillingRoutes.productsPath,
      BillingRoutes.checkoutPath,
      BillingRoutes.diagnosticsPath,
    ]);
  });

  test(
    'billing routes are discoverable through admin route search metadata',
    () {
      final entries = buildAdminRouteSearchEntries(
        BillingFeatures().registerScreens(),
      );

      expect(
        filterAdminRouteSearchEntries(
          entries,
          'domain packs',
        ).map((entry) => entry.path),
        contains(BillingRoutes.diagnosticsPath),
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          'tenant-scoped',
        ).map((entry) => entry.path),
        contains(BillingRoutes.workspacesPath),
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          'retry readiness',
        ).map((entry) => entry.path),
        contains(BillingRoutes.issueOutboxPath),
      );
      expect(
        filterAdminRouteSearchEntries(
          entries,
          'digital subscription',
        ).map((entry) => entry.path),
        contains(BillingRoutes.managementPath),
      );
    },
  );

  test('billing feature registers extension routes with fallback builders', () {
    final registry = BillingRouteDefinitionRegistry(
      extensionDefinitions: const [_entitlementsRoute],
    );
    final root =
        BillingFeatures(
          routeDefinitionRegistry: registry,
        ).registerScreens().single;
    final entitlementsRoute = root.items.singleWhere(
      (route) => route.routeName == _entitlementsRoute.routeName,
    );
    final routeContract = BillingRouteContractReport.forFeatureRoute(
      rootRoute: root,
      routeDefinitions: registry.routeDefinitions,
    );

    expect(entitlementsRoute.path, _entitlementsRoute.path);
    expect(entitlementsRoute.pageBuilder, isNotNull);
    expect(
      routeContract.isComplete,
      isTrue,
      reason: routeContract.summaryLabel,
    );
  });

  test('billing feature accepts extension page builders by route identity', () {
    final root =
        BillingFeatures(
          routeDefinitionRegistry: BillingRouteDefinitionRegistry(
            extensionDefinitions: const [_entitlementsRoute],
          ),
          pageBuilderRegistry: BillingRoutePageBuilderRegistry.standard(
            extensionBuildersByRouteIdentityKey: {
              'billingEntitlements': _entitlementsPageBuilder,
            },
          ),
        ).registerScreens().single;
    final entitlementsRoute = root.items.singleWhere(
      (route) => route.routeName == _entitlementsRoute.routeName,
    );

    expect(entitlementsRoute.pageBuilder, same(_entitlementsPageBuilder));
  });

  test('billing feature accepts executable route extension manifests', () {
    final root =
        BillingFeatures(
          extensionManifests: [
            BillingRouteExtensionManifest(
              id: 'billing.entitlements',
              routeDefinitions: const [_entitlementsRoute],
              pageBuildersByRouteIdentityKey: {
                'billingEntitlements': _entitlementsPageBuilder,
              },
            ),
          ],
        ).registerScreens().single;
    final entitlementsRoute = root.items.singleWhere(
      (route) => route.routeName == _entitlementsRoute.routeName,
    );
    final routeContract = BillingRouteContractReport.forFeatureRoute(
      rootRoute: root,
      routeDefinitions: [...BillingRoutes.sidebarRoutes, _entitlementsRoute],
    );

    expect(entitlementsRoute.path, _entitlementsRoute.path);
    expect(entitlementsRoute.pageBuilder, same(_entitlementsPageBuilder));
    expect(
      routeContract.isComplete,
      isTrue,
      reason: routeContract.summaryLabel,
    );
  });

  testWidgets('billing sidebar menu expands to management routes', (
    tester,
  ) async {
    FeatureRoutes? selected;
    final root = BillingFeatures().registerScreens().single;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 780,
            child: SideMenu(
              menuItems: [root],
              onMenuClick: (menu) => selected = menu,
              title: const Text('Kaysir'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Billing Management'), findsOneWidget);
    expect(find.text('Billing Invoices'), findsNothing);

    await tester.tap(find.text('Billing Management'));
    await tester.pumpAndSettle();

    expect(selected?.path, BillingRoutes.managementPath);
    expect(find.text('Billing Workspaces'), findsOneWidget);
    expect(find.text('Work Center'), findsOneWidget);
    expect(find.text('Billing Invoices'), findsOneWidget);
    expect(find.text('Create Invoice'), findsOneWidget);
    expect(find.text('Billing Insights'), findsOneWidget);
    expect(find.text('Issue Outbox'), findsOneWidget);
    expect(find.text('Policy Center'), findsOneWidget);
    expect(find.text('Products & Checkout'), findsOneWidget);
    expect(find.text('Cart Checkout'), findsOneWidget);
    expect(find.text('Billing Diagnostics'), findsOneWidget);

    await tester.ensureVisible(find.text('Billing Diagnostics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Billing Diagnostics'));
    await tester.pump();

    expect(selected?.path, BillingRoutes.diagnosticsPath);
  });
}

Page<dynamic> _entitlementsPageBuilder(
  BuildContext context,
  GoRouterState state,
) {
  return const MaterialPage(child: SizedBox.shrink());
}

const _entitlementsRoute = BillingManagementRouteDefinition(
  name: 'Billing Entitlements',
  routeName: 'billingEntitlements',
  title: 'Entitlements',
  subtitle: 'Access billing',
  description:
      'Review entitlement billing policies for the selected workspace.',
  icon: 'billing-entitlements',
  path: '${BillingRoutes.managementPath}/entitlements',
  destinationId: BillingNavigationDestinationId.diagnostics,
  routeIdentityKey: 'billingEntitlements',
  surface: BillingManagementRouteSurface.dashboard,
);
