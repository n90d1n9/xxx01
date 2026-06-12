import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/billing_routes.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract_remediation_navigation.dart';

void main() {
  test(
    'route contract remediation navigation opens diagnostics by default',
    () {
      final target = billingRouteContractRemediationNavigationTargetFor(
        _action(
          kind: BillingRouteContractRemediationActionKind.cleanupRegistry,
          routeName: BillingRoutes.managementRouteName,
        ),
      );

      expect(target.destinationId, BillingNavigationDestinationId.diagnostics);
      expect(target.callToActionLabel, 'Open diagnostics');
    },
  );

  test('route contract remediation navigation opens route destination', () {
    final target = billingRouteContractRemediationNavigationTargetFor(
      _action(
        kind: BillingRouteContractRemediationActionKind.attachPageBuilder,
        routeName: BillingRoutes.checkoutRouteName,
      ),
    );

    expect(target.destinationId, BillingNavigationDestinationId.cartCheckout);
    expect(target.callToActionLabel, 'Open checkout');
  });

  test(
    'route contract remediation navigation falls back for unknown route',
    () {
      final target = billingRouteContractRemediationNavigationTargetFor(
        _action(
          kind: BillingRouteContractRemediationActionKind.registerFeatureRoute,
          routeName: 'customBillingRoute',
        ),
      );

      expect(target.destinationId, BillingNavigationDestinationId.diagnostics);
      expect(target.callToActionLabel, 'Open diagnostics');
    },
  );
}

BillingRouteContractRemediationAction _action({
  required BillingRouteContractRemediationActionKind kind,
  required String routeName,
}) {
  return BillingRouteContractRemediationAction(
    id: '$routeName:${kind.name}',
    kind: kind,
    severity: BillingRouteContractIssueSeverity.blocker,
    routeName: routeName,
    label: 'Action label',
    detail: 'Action detail',
    priority: 1,
  );
}
