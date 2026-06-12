import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_exception_event.dart';
import 'package:kaysir/features/finance/billing/models/billing_policy_capability.dart';
import 'package:kaysir/features/finance/billing/utils/billing_policy_presets.dart';
import 'package:kaysir/features/finance/billing/utils/policy_exception_planner.dart';

void main() {
  test('planBillingPolicyException accepts ready force majeure policy', () {
    final plan = planBillingPolicyException(
      config: constructionBillingPolicyConfig(),
      kind: BillingExceptionEventKind.forceMajeure,
    );

    expect(plan.isConfigured, isTrue);
    expect(plan.isActionable, isTrue);
    expect(plan.missingCapabilityIds, isEmpty);
    expect(plan.requiresApproval, isTrue);
    expect(plan.requiresEvidence, isTrue);
    expect(
      plan.activeEffects,
      containsAll([
        BillingExceptionPolicyEffect.pauseDueDates,
        BillingExceptionPolicyEffect.suspendDunning,
        BillingExceptionPolicyEffect.waiveLateFees,
        BillingExceptionPolicyEffect.reschedulePayments,
      ]),
    );
  });

  test(
    'planBillingPolicyException blocks force majeure when relief is off',
    () {
      final config = constructionBillingPolicyConfig().disable(
        BillingPolicyCapabilityId.forceMajeureRelief,
      );
      final plan = planBillingPolicyException(
        config: config,
        kind: BillingExceptionEventKind.forceMajeure,
      );

      expect(plan.isConfigured, isTrue);
      expect(plan.isActionable, isFalse);
      expect(
        plan.missingCapabilityIds,
        contains(BillingPolicyCapabilityId.forceMajeureRelief),
      );
      expect(
        plan.decisionFor(BillingExceptionPolicyEffect.pauseDueDates)?.isAllowed,
        isFalse,
      );
    },
  );

  test(
    'planBillingPolicyException applies global approval and evidence gates',
    () {
      final config = agnosticBillingPolicyConfig().copyWith(
        exceptionPolicies: [
          BillingExceptionEventPolicy(
            kind: BillingExceptionEventKind.platformOutage,
            effects: const [BillingExceptionPolicyEffect.suspendDunning],
          ),
        ],
      );
      final plan = planBillingPolicyException(
        config: config,
        kind: BillingExceptionEventKind.platformOutage,
      );

      expect(plan.requiresApproval, isTrue);
      expect(plan.requiresEvidence, isTrue);
      expect(
        plan.activeEffects,
        containsAll([
          BillingExceptionPolicyEffect.suspendDunning,
          BillingExceptionPolicyEffect.requireApproval,
          BillingExceptionPolicyEffect.requireEvidence,
        ]),
      );
    },
  );

  test('planBillingPolicyException blocks effects by capability', () {
    final config = constructionBillingPolicyConfig().disable(
      BillingPolicyCapabilityId.paymentReschedule,
    );
    final plan = planBillingPolicyException(
      config: config,
      kind: BillingExceptionEventKind.forceMajeure,
    );

    final reschedule = plan.decisionFor(
      BillingExceptionPolicyEffect.reschedulePayments,
    );
    final dunning = plan.decisionFor(
      BillingExceptionPolicyEffect.suspendDunning,
    );

    expect(plan.isActionable, isFalse);
    expect(reschedule?.isAllowed, isFalse);
    expect(
      reschedule?.missingCapabilityIds,
      contains(BillingPolicyCapabilityId.paymentReschedule),
    );
    expect(dunning?.isAllowed, isTrue);
  });

  test('planBillingPolicyException reports unconfigured exception kinds', () {
    final plan = planBillingPolicyException(
      config: agnosticBillingPolicyConfig(),
      kind: BillingExceptionEventKind.contractPause,
    );

    expect(plan.isConfigured, isFalse);
    expect(plan.isActionable, isFalse);
    expect(plan.effectDecisions, isEmpty);
    expect(plan.summaryLabel, 'No contract pause policy is configured.');
  });
}
