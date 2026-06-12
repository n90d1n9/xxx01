import 'billing_exception_event.dart';
import 'billing_policy_capability.dart';

/// Explains whether one exception effect can be applied under policy config.
class BillingPolicyExceptionEffectDecision {
  final BillingExceptionPolicyEffect effect;
  final Set<BillingPolicyCapabilityId> requiredCapabilityIds;
  final Set<BillingPolicyCapabilityId> missingCapabilityIds;

  BillingPolicyExceptionEffectDecision({
    required this.effect,
    Iterable<BillingPolicyCapabilityId> requiredCapabilityIds = const [],
    Iterable<BillingPolicyCapabilityId> missingCapabilityIds = const [],
  }) : requiredCapabilityIds = Set.unmodifiable(requiredCapabilityIds),
       missingCapabilityIds = Set.unmodifiable(missingCapabilityIds);

  bool get isAllowed => missingCapabilityIds.isEmpty;

  String get statusLabel => isAllowed ? 'Enabled' : 'Blocked';

  String get summaryLabel {
    if (isAllowed) return '${effect.label} can be applied.';
    return '${effect.label} needs ${_capabilityListLabel(missingCapabilityIds)}.';
  }
}

/// Evaluated policy outcome for an exceptional billing condition.
class BillingPolicyExceptionPlan {
  final BillingExceptionEventKind kind;
  final BillingExceptionEventPolicy? policy;
  final Set<BillingPolicyCapabilityId> requiredCapabilityIds;
  final Set<BillingPolicyCapabilityId> missingCapabilityIds;
  final List<BillingPolicyExceptionEffectDecision> effectDecisions;

  BillingPolicyExceptionPlan({
    required this.kind,
    required this.policy,
    Iterable<BillingPolicyCapabilityId> requiredCapabilityIds = const [],
    Iterable<BillingPolicyCapabilityId> missingCapabilityIds = const [],
    Iterable<BillingPolicyExceptionEffectDecision> effectDecisions = const [],
  }) : requiredCapabilityIds = Set.unmodifiable(requiredCapabilityIds),
       missingCapabilityIds = Set.unmodifiable(missingCapabilityIds),
       effectDecisions = List.unmodifiable(effectDecisions);

  bool get isConfigured => policy != null;

  bool get isActionable => isConfigured && missingCapabilityIds.isEmpty;

  bool get hasBlockedEffects => blockedEffects.isNotEmpty;

  bool get requiresApproval {
    return activeEffects.contains(BillingExceptionPolicyEffect.requireApproval);
  }

  bool get requiresEvidence {
    return activeEffects.contains(BillingExceptionPolicyEffect.requireEvidence);
  }

  List<BillingExceptionPolicyEffect> get activeEffects {
    return List.unmodifiable(
      effectDecisions
          .where((decision) => decision.isAllowed)
          .map((decision) => decision.effect),
    );
  }

  List<BillingExceptionPolicyEffect> get blockedEffects {
    return List.unmodifiable(
      effectDecisions
          .where((decision) => !decision.isAllowed)
          .map((decision) => decision.effect),
    );
  }

  String get statusLabel {
    if (!isConfigured) return 'Not configured';
    if (isActionable) {
      return 'Ready';
    }
    return 'Needs capability';
  }

  String get summaryLabel {
    if (!isConfigured) {
      return 'No ${kind.label.toLowerCase()} policy is configured.';
    }
    if (isActionable) {
      return '${kind.label} can apply ${activeEffects.length} '
          '${activeEffects.length == 1 ? 'effect' : 'effects'}.';
    }

    return '${kind.label} is blocked by ${_capabilityListLabel(missingCapabilityIds)}.';
  }

  BillingPolicyExceptionEffectDecision? decisionFor(
    BillingExceptionPolicyEffect effect,
  ) {
    for (final decision in effectDecisions) {
      if (decision.effect == effect) return decision;
    }

    return null;
  }
}

String _capabilityListLabel(Set<BillingPolicyCapabilityId> capabilityIds) {
  if (capabilityIds.isEmpty) return 'no additional capabilities';

  final labels = capabilityIds.map((id) => id.label).toList(growable: false);
  if (labels.length == 1) return labels.single;
  if (labels.length == 2) return '${labels.first} and ${labels.last}';

  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}
