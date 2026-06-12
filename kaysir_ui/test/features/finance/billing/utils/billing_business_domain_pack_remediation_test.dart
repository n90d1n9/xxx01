import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_readiness.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';

void main() {
  test('standard pack remediation maps warnings to hardening actions', () {
    final readiness =
        BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
          standardBillingDomainPackRegistry(),
        );
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      readiness,
    );

    expect(plan.isEmpty, isFalse);
    expect(plan.actionCount, 4);
    expect(plan.blockerActionCount, 0);
    expect(plan.warningActionCount, 4);
    expect(plan.affectedDomainKeys, ['commerce', 'construction', 'digital']);
    expect(
      plan.summaryLabel,
      '4 hardening actions can improve billing pack release quality.',
    );
    expect(plan.actions.first.label, 'Add Construction line item adapter');
    expect(
      plan.actions.last.label,
      'Register Commerce release profile saved views',
    );
  });

  test('pack remediation keeps tenant-gated blockers first', () {
    final readiness =
        BillingBusinessDomainPackRegistryReadinessReport.forRegistry(
          standardBillingDomainPackRegistry(),
          hasTenant: false,
        );
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      readiness,
    );

    expect(plan.actionCount, 7);
    expect(plan.blockerActionCount, 3);
    expect(plan.warningActionCount, 4);
    expect(
      plan.summaryLabel,
      '3 blocker actions should be cleared before pack release.',
    );
    expect(plan.actions.first.label, 'Restore Commerce navigation coverage');
    expect(plan.actions.first.isBlocker, isTrue);
  });

  test('pack remediation summarizes custom pack readiness', () {
    final readiness = BillingBusinessDomainPackReadinessReport.forPack(
      BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
      ),
    );
    final plan = BillingBusinessDomainPackRemediationPlan.forReport(readiness);

    expect(plan.actionCount, 7);
    expect(plan.blockerActions.length, 1);
    expect(plan.warningActions.length, 6);
    expect(
      plan.summaryLabel,
      'Service operations billing pack needs 1 blocker cleared before release.',
    );
    expect(
      plan.actions.first.label,
      'Register Service operations screen registry',
    );
    expect(
      plan.actions.last.label,
      'Register Service operations release profile saved views',
    );
  });

  test('pack remediation reports empty release-ready plans', () {
    final readiness = BillingBusinessDomainPackRegistryReadinessReport(
      packReports: const [],
    );
    final plan = BillingBusinessDomainPackRegistryRemediationPlan.forReadiness(
      readiness,
    );

    expect(plan.isEmpty, isTrue);
    expect(plan.summaryLabel, 'All billing packs have no remediation actions.');
  });
}

BillingBusinessDomainProfile _serviceProfile() {
  return BillingBusinessDomainProfile(
    domain: 'service',
    label: 'Service operations',
    defaultSourceType: 'work_order',
    capabilities: const {BillingBusinessDomainCapability.servicePeriods},
  );
}
