import '../models/billing_exception_event.dart';
import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';
import '../models/policy_exception_plan.dart';

/// Builds the reusable operational plan for a billing exception event.
BillingPolicyExceptionPlan planBillingPolicyException({
  required BillingPolicyConfig config,
  required BillingExceptionEventKind kind,
}) {
  final policy = config.policyForException(kind);
  final baseRequiredCapabilityIds = _requiredCapabilitiesForException(kind);
  final requiredEffects = _effectivePolicyEffects(config, policy);
  final effectDecisions = [
    for (final effect in requiredEffects)
      _decisionForEffect(config, effect, baseRequiredCapabilityIds),
  ];

  return BillingPolicyExceptionPlan(
    kind: kind,
    policy: policy,
    requiredCapabilityIds: {
      ...baseRequiredCapabilityIds,
      for (final decision in effectDecisions) ...decision.requiredCapabilityIds,
    },
    missingCapabilityIds: {
      for (final capabilityId in baseRequiredCapabilityIds)
        if (!config.isEnabled(capabilityId)) capabilityId,
      for (final decision in effectDecisions) ...decision.missingCapabilityIds,
    },
    effectDecisions: effectDecisions,
  );
}

/// Lists the core capabilities needed before an exception kind can apply.
Set<BillingPolicyCapabilityId> billingPolicyCapabilitiesForExceptionKind(
  BillingExceptionEventKind kind,
) {
  return Set.unmodifiable(_requiredCapabilitiesForException(kind));
}

/// Lists the capabilities needed by one exception policy effect.
Set<BillingPolicyCapabilityId> billingPolicyCapabilitiesForExceptionEffect(
  BillingExceptionPolicyEffect effect,
) {
  return Set.unmodifiable(_requiredCapabilitiesForEffect(effect));
}

Set<BillingPolicyCapabilityId> _requiredCapabilitiesForException(
  BillingExceptionEventKind kind,
) {
  return {
    BillingPolicyCapabilityId.exceptionEvents,
    if (kind == BillingExceptionEventKind.forceMajeure)
      BillingPolicyCapabilityId.forceMajeureRelief,
  };
}

List<BillingExceptionPolicyEffect> _effectivePolicyEffects(
  BillingPolicyConfig config,
  BillingExceptionEventPolicy? policy,
) {
  if (policy == null) return const [];

  final effects = <BillingExceptionPolicyEffect>{...policy.effects};
  if (config.requireApprovalForExceptions) {
    effects.add(BillingExceptionPolicyEffect.requireApproval);
  }
  if (config.requireEvidenceForExceptions) {
    effects.add(BillingExceptionPolicyEffect.requireEvidence);
  }

  return List.unmodifiable(effects);
}

BillingPolicyExceptionEffectDecision _decisionForEffect(
  BillingPolicyConfig config,
  BillingExceptionPolicyEffect effect,
  Set<BillingPolicyCapabilityId> baseRequiredCapabilityIds,
) {
  final requiredCapabilityIds = {
    ...baseRequiredCapabilityIds,
    ..._requiredCapabilitiesForEffect(effect),
  };

  return BillingPolicyExceptionEffectDecision(
    effect: effect,
    requiredCapabilityIds: requiredCapabilityIds,
    missingCapabilityIds: requiredCapabilityIds.where(
      (capabilityId) => !config.isEnabled(capabilityId),
    ),
  );
}

Set<BillingPolicyCapabilityId> _requiredCapabilitiesForEffect(
  BillingExceptionPolicyEffect effect,
) {
  return switch (effect) {
    BillingExceptionPolicyEffect.pauseDueDates => {
      BillingPolicyCapabilityId.dueDatePause,
    },
    BillingExceptionPolicyEffect.suspendDunning => {
      BillingPolicyCapabilityId.dunningPause,
    },
    BillingExceptionPolicyEffect.waiveLateFees => {
      BillingPolicyCapabilityId.lateFeeWaiver,
    },
    BillingExceptionPolicyEffect.reschedulePayments => {
      BillingPolicyCapabilityId.paymentReschedule,
    },
    BillingExceptionPolicyEffect.freezeIssuance => const {},
    BillingExceptionPolicyEffect.requireApproval ||
    BillingExceptionPolicyEffect
        .requireEvidence => {BillingPolicyCapabilityId.approvalWorkflow},
  };
}
