import '../billing_routes.dart';
import '../models/billing_navigation_destination_id.dart';
import 'billing_route_contract_remediation.dart';

/// Navigation target for a billing route contract remediation action.
class BillingRouteContractRemediationNavigationTarget {
  final BillingNavigationDestinationId destinationId;
  final String callToActionLabel;

  const BillingRouteContractRemediationNavigationTarget({
    required this.destinationId,
    required this.callToActionLabel,
  });
}

BillingRouteContractRemediationNavigationTarget
billingRouteContractRemediationNavigationTargetFor(
  BillingRouteContractRemediationAction action,
) {
  final destinationId = _destinationForAction(action);
  return BillingRouteContractRemediationNavigationTarget(
    destinationId: destinationId,
    callToActionLabel: _callToActionLabel(destinationId),
  );
}

BillingNavigationDestinationId _destinationForAction(
  BillingRouteContractRemediationAction action,
) {
  return switch (action.kind) {
    BillingRouteContractRemediationActionKind.attachPageBuilder ||
    BillingRouteContractRemediationActionKind
        .registerFeatureRoute => _destinationForRouteName(action.routeName),
    BillingRouteContractRemediationActionKind.cleanupRegistry ||
    BillingRouteContractRemediationActionKind.alignRouteIdentity ||
    BillingRouteContractRemediationActionKind.alignRoutePath ||
    BillingRouteContractRemediationActionKind.alignRouteMetadata ||
    BillingRouteContractRemediationActionKind.restoreSidebarCoverage ||
    BillingRouteContractRemediationActionKind.removeUnexpectedRoute ||
    BillingRouteContractRemediationActionKind.restoreRouteOrder ||
    BillingRouteContractRemediationActionKind
        .enrichSearchMetadata => BillingNavigationDestinationId.diagnostics,
  };
}

BillingNavigationDestinationId _destinationForRouteName(String routeName) {
  for (final definition in BillingRoutes.sidebarRoutes) {
    if (definition.routeName == routeName) return definition.destinationId;
  }

  return BillingNavigationDestinationId.diagnostics;
}

String _callToActionLabel(BillingNavigationDestinationId destinationId) {
  return switch (destinationId) {
    BillingNavigationDestinationId.dashboard => 'Open dashboard',
    BillingNavigationDestinationId.workCenter => 'Open work center',
    BillingNavigationDestinationId.productWorkspace => 'Open products',
    BillingNavigationDestinationId.cartCheckout => 'Open checkout',
    BillingNavigationDestinationId.tenants => 'Open tenants',
    BillingNavigationDestinationId.invoices => 'Open invoices',
    BillingNavigationDestinationId.createInvoice => 'Create invoice',
    BillingNavigationDestinationId.reports => 'Open reports',
    BillingNavigationDestinationId.issueOutbox => 'Open outbox',
    BillingNavigationDestinationId.policyCenter => 'Open policy center',
    BillingNavigationDestinationId.diagnostics => 'Open diagnostics',
  };
}
