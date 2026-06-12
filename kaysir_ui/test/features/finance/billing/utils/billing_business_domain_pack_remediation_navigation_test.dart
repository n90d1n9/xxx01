import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_module_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation_navigation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('remediation navigation maps line item work to products', () {
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      ),
    );
    final lineItemAction = plan.actions.firstWhere(
      (action) =>
          action.kind ==
          BillingBusinessDomainPackRemediationActionKind.addLineItemAdapter,
    );

    final target = billingBusinessDomainPackRemediationNavigationTargetFor(
      lineItemAction,
    );

    expect(
      target.destinationId,
      BillingNavigationDestinationId.productWorkspace,
    );
    expect(target.callToActionLabel, 'Open products');
  });

  test('remediation navigation maps diagnostics work to diagnostics', () {
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      ),
    );
    final diagnosticsAction = plan.actions.firstWhere(
      (action) =>
          action.kind ==
          BillingBusinessDomainPackRemediationActionKind
              .registerDiagnosticsProfile,
    );

    final target = billingBusinessDomainPackRemediationNavigationTargetFor(
      diagnosticsAction,
    );

    expect(target.destinationId, BillingNavigationDestinationId.diagnostics);
    expect(target.callToActionLabel, 'Open diagnostics');
  });

  test(
    'remediation navigation maps saved-view profile work to diagnostics',
    () {
      final plan =
          BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
            BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
              standardBillingDomainPackRegistry(),
            ),
          );
      final savedViewAction = plan.actions.firstWhere(
        (action) =>
            action.kind ==
            BillingBusinessDomainPackRemediationActionKind
                .registerReleaseProfileSavedViewProfile,
      );

      final target = billingBusinessDomainPackRemediationNavigationTargetFor(
        savedViewAction,
      );

      expect(target.destinationId, BillingNavigationDestinationId.diagnostics);
      expect(target.callToActionLabel, 'Open diagnostics');
    },
  );

  test(
    'remediation navigation maps release gate target work to diagnostics',
    () {
      final target = billingBusinessDomainPackRemediationNavigationTargetFor(
        BillingBusinessDomainPackRemediationAction(
          id: 'service:pack:missingReleaseGateLaneTarget:0',
          domainKey: 'service',
          domainLabel: 'Service operations',
          kind:
              BillingBusinessDomainPackRemediationActionKind
                  .registerReleaseGateLaneTarget,
          source: BillingBusinessDomainPackRemediationActionSource.pack,
          severity: BillingDomainModuleReadinessIssueSeverity.warning,
          label: 'Map Service operations release gate lanes to diagnostics',
          detail:
              'Service operations has release gate lanes without diagnostics '
              'navigation targets.',
          priority: 98,
        ),
      );

      expect(target.destinationId, BillingNavigationDestinationId.diagnostics);
      expect(target.callToActionLabel, 'Open diagnostics');
    },
  );
}
