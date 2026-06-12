import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_page_builder_registry.dart';

void main() {
  test('BillingRouteExecutionReport accepts standard route builders', () {
    final report = BillingRouteExecutionReport.forRegistry();

    expect(report.isReady, isTrue);
    expect(report.explicitBuilderCount, BillingRoutes.sidebarRoutes.length);
    expect(report.fallbackBuilderCount, 0);
    expect(
      report.summaryLabel,
      'Billing route execution is ready across '
      '${BillingRoutes.sidebarRoutes.length} routes.',
    );
  });

  test('BillingRouteExecutionReport detects extension fallback builders', () {
    final report = BillingRouteExecutionReport.forRegistry(
      routeDefinitionRegistry: BillingRouteDefinitionRegistry(
        extensionDefinitions: const [_entitlementsRoute],
      ),
    );

    expect(report.isReady, isFalse);
    expect(report.explicitBuilderCount, BillingRoutes.sidebarRoutes.length);
    expect(report.fallbackBuilderCount, 1);
    expect(
      report.issues.single.kind,
      BillingRouteExecutionIssueKind.missingExplicitPageBuilder,
    );
    expect(report.issues.single.routeName, _entitlementsRoute.routeName);
    expect(
      report.summaryLabel,
      'Billing route execution has 1 builder blocker.',
    );
  });

  test('BillingRouteExecutionReport accepts extension page builders', () {
    final report = BillingRouteExecutionReport.forRegistry(
      routeDefinitionRegistry: BillingRouteDefinitionRegistry(
        extensionDefinitions: const [_entitlementsRoute],
      ),
      pageBuilderRegistry: BillingRoutePageBuilderRegistry.standard(
        extensionBuildersByRouteIdentityKey: {
          'billingEntitlements': _entitlementsPageBuilder,
        },
      ),
    );

    expect(report.isReady, isTrue);
    expect(report.explicitBuilderCount, BillingRoutes.sidebarRoutes.length + 1);
    expect(report.fallbackBuilderCount, 0);
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
