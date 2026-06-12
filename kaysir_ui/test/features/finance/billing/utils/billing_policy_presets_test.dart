import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';

void main() {
  test('standardBillingPolicyCapabilities exposes every capability', () {
    final capabilities = standardBillingPolicyCapabilities();

    expect(
      capabilities.map((capability) => capability.id).toSet(),
      BillingPolicyCapabilityId.values.toSet(),
    );
    expect(
      capabilities.map((capability) => capability.group).toSet(),
      containsAll(BillingPolicyCapabilityGroup.values),
    );
  });

  test('standardBillingPolicyConfig resolves business-domain presets', () {
    final construction = standardBillingPolicyConfig(
      businessDomain: ' construction ',
    );
    final commerce = standardBillingPolicyConfig(businessDomain: 'grocery');
    final digital = standardBillingPolicyConfig(businessDomain: 'subscription');

    expect(construction.allowsSplitBilling, isTrue);
    expect(
      construction.isEnabled(BillingPolicyCapabilityId.milestoneBilling),
      isTrue,
    );
    expect(commerce.maxSplitRecipients, 6);
    expect(digital.maxSplitRecipients, 3);
  });

  test('standard policy config includes force majeure relief effects', () {
    final config = standardBillingPolicyConfig();
    final policy = config.policyForException(
      BillingExceptionEventKind.forceMajeure,
    );

    expect(config.allowsForceMajeureRelief, isTrue);
    expect(policy, isNotNull);
    expect(
      policy!.effects,
      containsAll([
        BillingExceptionPolicyEffect.pauseDueDates,
        BillingExceptionPolicyEffect.suspendDunning,
        BillingExceptionPolicyEffect.waiveLateFees,
        BillingExceptionPolicyEffect.reschedulePayments,
        BillingExceptionPolicyEffect.requireApproval,
        BillingExceptionPolicyEffect.requireEvidence,
      ]),
    );
  });
}
