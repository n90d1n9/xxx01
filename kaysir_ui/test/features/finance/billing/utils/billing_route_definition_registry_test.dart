import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';

void main() {
  test('BillingRouteDefinitionRegistry exposes standard billing routes', () {
    final registry = BillingRouteDefinitionRegistry.standard();

    expect(registry.hasExtensions, isFalse);
    expect(registry.routeCount, BillingRoutes.sidebarRoutes.length);
    expect(registry.routeDefinitions, BillingRoutes.sidebarRoutes);
    expect(
      registry.definitionForRouteName(BillingRoutes.invoicesRouteName)?.path,
      BillingRoutes.invoicesPath,
    );
    expect(
      registry.definitionForPath(BillingRoutes.diagnosticsPath)?.routeName,
      BillingRoutes.diagnosticsRouteName,
    );
    expect(
      registry.definitionForRouteIdentityKey('diagnostics')?.routeName,
      BillingRoutes.diagnosticsRouteName,
    );
  });

  test('BillingRouteDefinitionRegistry composes extension routes', () {
    final registry = BillingRouteDefinitionRegistry(
      extensionDefinitions: const [_entitlementsRoute],
    );

    expect(registry.hasExtensions, isTrue);
    expect(registry.routeCount, BillingRoutes.sidebarRoutes.length + 1);
    expect(registry.extensionDefinitions, [_entitlementsRoute]);
    expect(
      registry.definitionForRouteIdentityKey('billingEntitlements'),
      _entitlementsRoute,
    );
    expect(
      registry.definitionsForDestination(
        BillingNavigationDestinationId.diagnostics,
      ),
      contains(_entitlementsRoute),
    );
    expect(registry.containsRouteIdentityKey('billingEntitlements'), isTrue);
  });

  test('BillingRouteDefinitionRegistry ignores blank lookup keys', () {
    final registry = BillingRouteDefinitionRegistry.standard();

    expect(registry.definitionForRouteIdentityKey('  '), isNull);
    expect(registry.definitionForRouteName('  '), isNull);
    expect(registry.definitionForPath('  '), isNull);
    expect(registry.containsRouteIdentityKey('  '), isFalse);
  });
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
