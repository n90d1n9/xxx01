import '../models/billing_navigation_destination_id.dart';
import 'billing_business_domain_pack_remediation.dart';

class BillingBusinessDomainPackRemediationNavigationTarget {
  final BillingNavigationDestinationId destinationId;
  final String callToActionLabel;

  const BillingBusinessDomainPackRemediationNavigationTarget({
    required this.destinationId,
    required this.callToActionLabel,
  });
}

BillingBusinessDomainPackRemediationNavigationTarget
billingBusinessDomainPackRemediationNavigationTargetFor(
  BillingBusinessDomainPackRemediationAction action,
) {
  final destinationId = _destinationForAction(action);
  return BillingBusinessDomainPackRemediationNavigationTarget(
    destinationId: destinationId,
    callToActionLabel: _callToActionLabel(destinationId),
  );
}

BillingNavigationDestinationId _destinationForAction(
  BillingBusinessDomainPackRemediationAction action,
) {
  return switch (action.kind) {
    BillingBusinessDomainPackRemediationActionKind.validateProfile =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind.registerScreenRegistry =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind.registerMissingScreens =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind.defineNavigationPolicy =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind.addLineItemAdapter =>
      BillingNavigationDestinationId.productWorkspace,
    BillingBusinessDomainPackRemediationActionKind.addIssuePolicy =>
      BillingNavigationDestinationId.createInvoice,
    BillingBusinessDomainPackRemediationActionKind.addPaymentSchedulePolicy =>
      BillingNavigationDestinationId.invoices,
    BillingBusinessDomainPackRemediationActionKind.restoreNavigationCoverage =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind.registerDiagnosticsProfile =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseWorkspaceProfile =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseProfileSavedViewProfile =>
      BillingNavigationDestinationId.diagnostics,
    BillingBusinessDomainPackRemediationActionKind
        .registerReleaseGateLaneTarget =>
      BillingNavigationDestinationId.diagnostics,
  };
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
