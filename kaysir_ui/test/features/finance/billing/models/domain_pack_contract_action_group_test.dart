import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/models/domain_pack_contract_action_group.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';

void main() {
  test('DomainPackContractActionGroup groups actions by destination', () {
    final groups = DomainPackContractActionGroup.fromActions(
      _standardPlan().actions,
    );

    expect(groups.map((group) => group.destinationId), [
      BillingNavigationDestinationId.productWorkspace,
      BillingNavigationDestinationId.diagnostics,
    ]);
    expect(groups.first.displayLabel, 'Open products (2)');
    expect(groups.first.actionCount, 2);
    expect(groups.last.displayLabel, 'Open diagnostics (2)');
    expect(groups.last.actionCount, 2);
    expect(groups.last.tooltipLabel, contains('Register Commerce'));
  });

  test('DomainPackContractActionGroup rejects empty groups', () {
    expect(
      () => DomainPackContractActionGroup(
        destinationId: BillingNavigationDestinationId.diagnostics,
        callToActionLabel: 'Open diagnostics',
        actions: const [],
      ),
      throwsArgumentError,
    );
  });
}

BillingBusinessDomainPackRegistryRemediationPlan _standardPlan() {
  final readiness =
      BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
        standardBillingDomainPackRegistry(),
      );

  return BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
    readiness,
  );
}
