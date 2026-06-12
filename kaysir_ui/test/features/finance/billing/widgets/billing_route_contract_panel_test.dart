import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/core/features/feature_routes.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_definition_registry.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_contract_panel.dart';

void main() {
  testWidgets('BillingRouteContractPanel renders complete contract summary', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingRouteContractPanel(
        report: BillingRouteContractReport.forRouteRegistry(),
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-route-contract-panel')),
      findsOneWidget,
    );
    expect(find.text('Route contract'), findsOneWidget);
    expect(
      find.text(
        'Billing route contract is complete across '
        '${BillingRoutes.sidebarRoutes.length} routes.',
      ),
      findsOneWidget,
    );
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Sidebar'), findsOneWidget);
    expect(find.text('Blockers'), findsOneWidget);
    expect(find.text('Warnings'), findsOneWidget);
    expect(find.text('Builders'), findsOneWidget);
    expect(find.text('Fallbacks'), findsOneWidget);
    expect(
      find.text(
        'All billing routes are reachable from the sidebar with metadata aligned to the route registry.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('BillingRouteContractPanel renders execution blockers', (
    tester,
  ) async {
    final routeRegistry = BillingRouteDefinitionRegistry(
      extensionDefinitions: const [_entitlementsRoute],
    );

    await _pumpPanel(
      tester,
      BillingRouteContractPanel(
        report: BillingRouteContractReport.forRouteRegistry(
          routeDefinitions: routeRegistry.routeDefinitions,
        ),
        executionReport: BillingRouteExecutionReport.forRegistry(
          routeDefinitionRegistry: routeRegistry,
        ),
      ),
    );

    expect(find.text('Route execution readiness'), findsOneWidget);
    expect(
      find.text('Billing route execution has 1 builder blocker.'),
      findsOneWidget,
    );
    expect(
      find.text('Entitlements uses the fallback billing route page.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('billing-route-execution-readiness')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('billing-route-execution-issue-billingEntitlements'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('BillingRouteContractPanel renders issue severity and overflow', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      BillingRouteContractPanel(
        report: _issueReport(),
        maxVisibleIssues: 2,
        maxVisibleActions: 2,
      ),
    );

    expect(
      find.text('Billing route contract has 1 blocker and 2 warnings.'),
      findsOneWidget,
    );
    expect(find.text('Blocker'), findsWidgets);
    expect(find.text('Warning'), findsWidgets);
    expect(find.text('Duplicate route name'), findsOneWidget);
    expect(find.text('Registry route name is duplicated.'), findsOneWidget);
    expect(find.text('Missing route metadata'), findsOneWidget);
    expect(
      find.text('Diagnostics route metadata is incomplete.'),
      findsOneWidget,
    );
    expect(find.text('billingManagement'), findsWidgets);
    expect(find.text('+1 more issue hidden'), findsOneWidget);
    expect(find.text('Feature route order mismatch'), findsNothing);
    expect(find.text('Suggested fixes'), findsOneWidget);
    expect(
      find.text('Clean up ${BillingRoutes.managementRouteName} route registry'),
      findsOneWidget,
    );
    expect(
      find.text('Align ${BillingRoutes.diagnosticsRouteName} route metadata'),
      findsOneWidget,
    );
    expect(find.text('+1 more fix hidden'), findsOneWidget);
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

BillingRouteContractReport _issueReport() {
  return BillingRouteContractReport(
    rootRoute: FeatureRoutes(
      name: BillingRoutes.managementRouteName,
      title: BillingRoutes.managementTitle,
      path: BillingRoutes.managementPath,
    ),
    routeDefinitions: BillingRoutes.sidebarRoutes,
    issues: [
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.duplicateRouteName,
        severity: BillingRouteContractIssueSeverity.blocker,
        routeName: BillingRoutes.managementRouteName,
        message: 'Registry route name is duplicated.',
        details: [BillingRoutes.managementRouteName],
      ),
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.missingRouteMetadata,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: BillingRoutes.diagnosticsRouteName,
        message: 'Diagnostics route metadata is incomplete.',
        details: ['description'],
      ),
      BillingRouteContractIssue(
        kind: BillingRouteContractIssueKind.featureRouteOrderMismatch,
        severity: BillingRouteContractIssueSeverity.warning,
        routeName: BillingRoutes.managementRouteName,
        message: 'Order mismatch',
      ),
    ],
  );
}

Future<void> _pumpPanel(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(960, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(width: 720, child: child),
          ),
        ),
      ),
    ),
  );
}
