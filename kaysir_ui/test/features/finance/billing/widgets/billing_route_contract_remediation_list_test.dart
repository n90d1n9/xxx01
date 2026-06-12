import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract_remediation.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_contract_remediation_list.dart';

void main() {
  testWidgets('BillingRouteContractRemediationList renders visible actions', (
    tester,
  ) async {
    final plan = BillingRouteContractRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.duplicateRouteName,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: BillingRoutes.managementRouteName,
          message: 'Duplicate route name',
          details: const [BillingRoutes.managementRouteName],
        ),
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.featureRouteOrderMismatch,
          severity: BillingRouteContractIssueSeverity.warning,
          routeName: BillingRoutes.managementRouteName,
          message: 'Order drift',
        ),
      ]),
    );

    await _pumpList(
      tester,
      BillingRouteContractRemediationList(
        actions: plan.actions,
        maxVisibleActions: 1,
      ),
    );

    expect(
      find.byKey(const ValueKey('billing-route-contract-remediation-list')),
      findsOneWidget,
    );
    expect(find.text('Suggested fixes'), findsOneWidget);
    expect(
      find.text('Clean up ${BillingRoutes.managementRouteName} route registry'),
      findsOneWidget,
    );
    expect(find.text('Blocker'), findsOneWidget);
    expect(find.textContaining('Registry cleanup'), findsOneWidget);
    expect(find.text('+1 more fix hidden'), findsOneWidget);
    expect(find.text('Restore billing sidebar route order'), findsNothing);
  });

  testWidgets('BillingRouteContractRemediationList dispatches destination', (
    tester,
  ) async {
    final plan = BillingRouteContractRemediationPlan.forReport(
      _reportWithIssues([
        BillingRouteContractIssue(
          kind: BillingRouteContractIssueKind.missingFeaturePageBuilder,
          severity: BillingRouteContractIssueSeverity.blocker,
          routeName: BillingRoutes.checkoutRouteName,
          message: 'Missing checkout page builder',
        ),
      ]),
    );
    BillingNavigationDestinationId? selectedDestination;

    await _pumpList(
      tester,
      BillingRouteContractRemediationList(
        actions: plan.actions,
        onDestinationSelected: (destination) {
          selectedDestination = destination;
        },
      ),
    );

    await tester.tap(
      find.byKey(
        ValueKey(
          'billing-route-contract-remediation-open-'
          '${BillingRoutes.checkoutRouteName}:missingFeaturePageBuilder:0',
        ),
      ),
    );
    await tester.pump();

    expect(selectedDestination, BillingNavigationDestinationId.cartCheckout);
    expect(find.text('Open checkout'), findsOneWidget);
  });
}

BillingRouteContractReport _reportWithIssues(
  Iterable<BillingRouteContractIssue> issues,
) {
  final registryReport = BillingRouteContractReport.forRouteRegistry();

  return BillingRouteContractReport(
    rootRoute: registryReport.rootRoute,
    routeDefinitions: registryReport.routeDefinitions,
    issues: issues,
  );
}

Future<void> _pumpList(WidgetTester tester, Widget child) {
  tester.view.physicalSize = const Size(960, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(child: SizedBox(width: 720, child: child)),
      ),
    ),
  );
}
