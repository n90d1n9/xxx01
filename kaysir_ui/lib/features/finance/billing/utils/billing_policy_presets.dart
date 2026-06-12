import '../models/billing_exception_event.dart';
import '../models/billing_policy_capability.dart';
import '../models/billing_policy_config.dart';

/// Ordered catalog of billing policy capabilities shown in policy UIs.
List<BillingPolicyCapability> standardBillingPolicyCapabilities() {
  return List.unmodifiable(
    BillingPolicyCapabilityId.values.map((id) => id.capability),
  );
}

/// Default policy configuration for a billing business domain.
BillingPolicyConfig standardBillingPolicyConfig({String? businessDomain}) {
  final domain = businessDomain?.trim().toLowerCase();

  return switch (domain) {
    'construction' => constructionBillingPolicyConfig(),
    'digital' ||
    'digital_subscription' ||
    'subscription' => digitalSubscriptionBillingPolicyConfig(),
    'commerce' ||
    'retail' ||
    'grocery' ||
    'kiosk' => commerceBillingPolicyConfig(),
    _ => agnosticBillingPolicyConfig(),
  };
}

/// Domain-agnostic policy profile for general billing products.
BillingPolicyConfig agnosticBillingPolicyConfig() {
  return BillingPolicyConfig(
    enabledCapabilityIds: const {
      BillingPolicyCapabilityId.partialCollection,
      BillingPolicyCapabilityId.exceptionEvents,
      BillingPolicyCapabilityId.forceMajeureRelief,
      BillingPolicyCapabilityId.dueDatePause,
      BillingPolicyCapabilityId.dunningPause,
      BillingPolicyCapabilityId.lateFeeWaiver,
      BillingPolicyCapabilityId.paymentReschedule,
      BillingPolicyCapabilityId.manualAdjustment,
      BillingPolicyCapabilityId.approvalWorkflow,
    },
    exceptionPolicies: _standardExceptionPolicies(),
  );
}

/// Commerce-oriented policy profile for checkout and receivables.
BillingPolicyConfig commerceBillingPolicyConfig() {
  return agnosticBillingPolicyConfig().copyWith(
    enabledCapabilityIds: {
      ...agnosticBillingPolicyConfig().enabledCapabilityIds,
      BillingPolicyCapabilityId.splitBilling,
      BillingPolicyCapabilityId.multiPayer,
    },
    maxSplitRecipients: 6,
  );
}

/// Construction-oriented policy profile for project and milestone billing.
BillingPolicyConfig constructionBillingPolicyConfig() {
  return agnosticBillingPolicyConfig().copyWith(
    enabledCapabilityIds: {
      ...agnosticBillingPolicyConfig().enabledCapabilityIds,
      BillingPolicyCapabilityId.splitBilling,
      BillingPolicyCapabilityId.multiPayer,
      BillingPolicyCapabilityId.milestoneBilling,
    },
    maxSplitRecipients: 8,
  );
}

/// Digital subscription policy profile for recurring SaaS billing.
BillingPolicyConfig digitalSubscriptionBillingPolicyConfig() {
  return agnosticBillingPolicyConfig().copyWith(
    enabledCapabilityIds: {
      ...agnosticBillingPolicyConfig().enabledCapabilityIds,
      BillingPolicyCapabilityId.paymentReschedule,
      BillingPolicyCapabilityId.lateFeeWaiver,
    },
    maxSplitRecipients: 3,
  );
}

List<BillingExceptionEventPolicy> _standardExceptionPolicies() {
  return [
    BillingExceptionEventPolicy(
      kind: BillingExceptionEventKind.forceMajeure,
      effects: const [
        BillingExceptionPolicyEffect.pauseDueDates,
        BillingExceptionPolicyEffect.suspendDunning,
        BillingExceptionPolicyEffect.waiveLateFees,
        BillingExceptionPolicyEffect.reschedulePayments,
        BillingExceptionPolicyEffect.requireApproval,
        BillingExceptionPolicyEffect.requireEvidence,
      ],
    ),
    BillingExceptionEventPolicy(
      kind: BillingExceptionEventKind.governmentRestriction,
      effects: const [
        BillingExceptionPolicyEffect.pauseDueDates,
        BillingExceptionPolicyEffect.freezeIssuance,
        BillingExceptionPolicyEffect.requireApproval,
        BillingExceptionPolicyEffect.requireEvidence,
      ],
    ),
    BillingExceptionEventPolicy(
      kind: BillingExceptionEventKind.platformOutage,
      effects: const [
        BillingExceptionPolicyEffect.suspendDunning,
        BillingExceptionPolicyEffect.waiveLateFees,
        BillingExceptionPolicyEffect.requireEvidence,
      ],
    ),
    BillingExceptionEventPolicy(
      kind: BillingExceptionEventKind.customerDispute,
      effects: const [
        BillingExceptionPolicyEffect.suspendDunning,
        BillingExceptionPolicyEffect.requireApproval,
        BillingExceptionPolicyEffect.requireEvidence,
      ],
    ),
  ];
}
