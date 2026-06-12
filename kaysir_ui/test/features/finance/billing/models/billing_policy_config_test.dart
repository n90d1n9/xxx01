import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_config.dart';

void main() {
  test('BillingPolicyConfig enables and disables capabilities immutably', () {
    final config = BillingPolicyConfig(
      enabledCapabilityIds: const [BillingPolicyCapabilityId.splitBilling],
    );

    final withExceptionEvents = config.enable(
      BillingPolicyCapabilityId.exceptionEvents,
    );
    final withoutSplitBilling = withExceptionEvents.disable(
      BillingPolicyCapabilityId.splitBilling,
    );

    expect(config.allowsSplitBilling, isTrue);
    expect(config.allowsExceptionEvents, isFalse);
    expect(withExceptionEvents.allowsExceptionEvents, isTrue);
    expect(withoutSplitBilling.allowsSplitBilling, isFalse);
    expect(withoutSplitBilling.allowsExceptionEvents, isTrue);
  });

  test('BillingPolicyConfig resolves exception policies', () {
    final config = BillingPolicyConfig(
      exceptionPolicies: [
        BillingExceptionEventPolicy(
          kind: BillingExceptionEventKind.forceMajeure,
          effects: const [
            BillingExceptionPolicyEffect.pauseDueDates,
            BillingExceptionPolicyEffect.suspendDunning,
          ],
        ),
      ],
    );

    final policy = config.policyForException(
      BillingExceptionEventKind.forceMajeure,
    );

    expect(policy, isNotNull);
    expect(policy!.applies(BillingExceptionPolicyEffect.pauseDueDates), isTrue);
    expect(policy.applies(BillingExceptionPolicyEffect.waiveLateFees), isFalse);
    expect(
      config.policyForException(BillingExceptionEventKind.platformOutage),
      isNull,
    );
  });

  test('BillingPolicyConfigSummary reports capability coverage', () {
    final summary = BillingPolicyConfigSummary(
      config: BillingPolicyConfig(
        enabledCapabilityIds: const [
          BillingPolicyCapabilityId.splitBilling,
          BillingPolicyCapabilityId.exceptionEvents,
        ],
      ),
      totalCapabilityCount: 5,
    );

    expect(summary.enabledCapabilityCount, 2);
    expect(summary.disabledCapabilityCount, 3);
    expect(summary.capabilitySummaryLabel, '2 of 5 capabilities enabled');
  });
}
