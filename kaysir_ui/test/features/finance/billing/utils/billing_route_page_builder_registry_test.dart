import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_page_builder_registry.dart';

void main() {
  test('standard page builder registry covers core billing routes', () {
    final registry = BillingRoutePageBuilderRegistry.standard();

    for (final route in BillingRoutes.sidebarRoutes) {
      expect(
        registry.hasPageBuilderFor(route),
        isTrue,
        reason: route.routeName,
      );
      expect(registry.explicitPageBuilderFor(route), isNotNull);
      expect(registry.pageBuilderFor(route), isNotNull);
    }
  });

  test('page builder registry accepts extension builders by identity', () {
    final registry = BillingRoutePageBuilderRegistry.standard(
      extensionBuildersByRouteIdentityKey: {
        ' billingEntitlements ': _entitlementsPageBuilder,
      },
    );

    expect(registry.hasPageBuilderFor(_entitlementsRoute), isTrue);
    expect(
      registry.explicitPageBuilderFor(_entitlementsRoute),
      same(_entitlementsPageBuilder),
    );
    expect(
      registry.pageBuilderFor(_entitlementsRoute),
      same(_entitlementsPageBuilder),
    );
  });

  test('page builder registry falls back for unregistered extensions', () {
    final registry = BillingRoutePageBuilderRegistry.standard();

    expect(registry.hasPageBuilderFor(_entitlementsRoute), isFalse);
    expect(registry.explicitPageBuilderFor(_entitlementsRoute), isNull);
    expect(registry.pageBuilderFor(_entitlementsRoute), isNotNull);
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
