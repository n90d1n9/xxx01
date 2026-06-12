import 'billing_exception_event.dart';
import 'billing_policy_capability.dart';

/// Runtime billing policy configuration for a tenant or business domain.
class BillingPolicyConfig {
  final Set<BillingPolicyCapabilityId> enabledCapabilityIds;
  final List<BillingExceptionEventPolicy> exceptionPolicies;
  final int maxSplitRecipients;
  final bool requireApprovalForExceptions;
  final bool requireEvidenceForExceptions;

  BillingPolicyConfig({
    Iterable<BillingPolicyCapabilityId> enabledCapabilityIds = const [],
    Iterable<BillingExceptionEventPolicy> exceptionPolicies = const [],
    this.maxSplitRecipients = 4,
    this.requireApprovalForExceptions = true,
    this.requireEvidenceForExceptions = true,
  }) : enabledCapabilityIds = Set.unmodifiable(enabledCapabilityIds),
       exceptionPolicies = List.unmodifiable(exceptionPolicies),
       assert(maxSplitRecipients > 0);

  bool isEnabled(BillingPolicyCapabilityId capabilityId) {
    return enabledCapabilityIds.contains(capabilityId);
  }

  bool get allowsSplitBilling {
    return isEnabled(BillingPolicyCapabilityId.splitBilling);
  }

  bool get allowsExceptionEvents {
    return isEnabled(BillingPolicyCapabilityId.exceptionEvents);
  }

  bool get allowsForceMajeureRelief {
    return isEnabled(BillingPolicyCapabilityId.forceMajeureRelief);
  }

  int get enabledCapabilityCount => enabledCapabilityIds.length;

  BillingExceptionEventPolicy? policyForException(
    BillingExceptionEventKind kind,
  ) {
    for (final policy in exceptionPolicies) {
      if (policy.kind == kind) return policy;
    }

    return null;
  }

  BillingPolicyConfig enable(BillingPolicyCapabilityId capabilityId) {
    return copyWith(
      enabledCapabilityIds: {...enabledCapabilityIds, capabilityId},
    );
  }

  BillingPolicyConfig disable(BillingPolicyCapabilityId capabilityId) {
    return copyWith(
      enabledCapabilityIds: enabledCapabilityIds.where(
        (id) => id != capabilityId,
      ),
    );
  }

  BillingPolicyConfig copyWith({
    Iterable<BillingPolicyCapabilityId>? enabledCapabilityIds,
    Iterable<BillingExceptionEventPolicy>? exceptionPolicies,
    int? maxSplitRecipients,
    bool? requireApprovalForExceptions,
    bool? requireEvidenceForExceptions,
  }) {
    return BillingPolicyConfig(
      enabledCapabilityIds: enabledCapabilityIds ?? this.enabledCapabilityIds,
      exceptionPolicies: exceptionPolicies ?? this.exceptionPolicies,
      maxSplitRecipients: maxSplitRecipients ?? this.maxSplitRecipients,
      requireApprovalForExceptions:
          requireApprovalForExceptions ?? this.requireApprovalForExceptions,
      requireEvidenceForExceptions:
          requireEvidenceForExceptions ?? this.requireEvidenceForExceptions,
    );
  }
}

/// Read-only summary for presenting billing policy configuration coverage.
class BillingPolicyConfigSummary {
  final BillingPolicyConfig config;
  final int totalCapabilityCount;

  const BillingPolicyConfigSummary({
    required this.config,
    required this.totalCapabilityCount,
  });

  int get enabledCapabilityCount => config.enabledCapabilityCount;

  int get disabledCapabilityCount {
    final disabled = totalCapabilityCount - enabledCapabilityCount;
    return disabled < 0 ? 0 : disabled;
  }

  int get exceptionPolicyCount => config.exceptionPolicies.length;

  String get capabilitySummaryLabel {
    return '$enabledCapabilityCount of $totalCapabilityCount capabilities enabled';
  }

  String get exceptionSummaryLabel {
    return '$exceptionPolicyCount exception ${exceptionPolicyCount == 1 ? 'policy' : 'policies'} configured';
  }
}
