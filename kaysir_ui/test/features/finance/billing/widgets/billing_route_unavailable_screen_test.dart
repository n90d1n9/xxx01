import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_unavailable_screen.dart';

void main() {
  testWidgets('BillingRouteUnavailableScreen renders route and context', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BillingRouteUnavailableScreen(
          routeDefinition: _entitlementsRoute,
          routeContext: BillingRouteContext(
            tenantId: 'tenant-a',
            businessDomain: 'digital',
          ),
        ),
      ),
    );

    expect(find.text('Entitlements'), findsOneWidget);
    expect(find.text('Route builder unavailable'), findsOneWidget);
    expect(find.textContaining(_entitlementsRoute.path), findsOneWidget);
    expect(find.textContaining('tenant-a / digital'), findsOneWidget);
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
