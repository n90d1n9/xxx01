/// Supported exceptional conditions that can alter billing behavior.
enum BillingExceptionEventKind {
  forceMajeure,
  governmentRestriction,
  platformOutage,
  customerDispute,
  operationalIncident,
  contractPause,
}

/// Policy effects that may be applied while an exception event is active.
enum BillingExceptionPolicyEffect {
  pauseDueDates,
  suspendDunning,
  waiveLateFees,
  reschedulePayments,
  freezeIssuance,
  requireApproval,
  requireEvidence,
}

/// Configured treatment for one billing exception event type.
class BillingExceptionEventPolicy {
  final BillingExceptionEventKind kind;
  final List<BillingExceptionPolicyEffect> effects;
  final String label;
  final String description;

  BillingExceptionEventPolicy({
    required this.kind,
    Iterable<BillingExceptionPolicyEffect> effects = const [],
    String? label,
    String? description,
  }) : effects = List.unmodifiable(effects),
       label = label ?? kind.label,
       description = description ?? kind.description;

  bool applies(BillingExceptionPolicyEffect effect) {
    return effects.contains(effect);
  }
}

/// Labels and descriptions for billing exception event kinds.
extension BillingExceptionEventKindLabels on BillingExceptionEventKind {
  String get label {
    return switch (this) {
      BillingExceptionEventKind.forceMajeure => 'Force majeure',
      BillingExceptionEventKind.governmentRestriction =>
        'Government restriction',
      BillingExceptionEventKind.platformOutage => 'Platform outage',
      BillingExceptionEventKind.customerDispute => 'Customer dispute',
      BillingExceptionEventKind.operationalIncident => 'Operational incident',
      BillingExceptionEventKind.contractPause => 'Contract pause',
    };
  }

  String get description {
    return switch (this) {
      BillingExceptionEventKind.forceMajeure =>
        'Extraordinary event that may justify temporary billing relief.',
      BillingExceptionEventKind.governmentRestriction =>
        'Regulatory, permit, or public-order condition affecting payment.',
      BillingExceptionEventKind.platformOutage =>
        'Provider outage that affects billing, checkout, or invoice delivery.',
      BillingExceptionEventKind.customerDispute =>
        'Customer challenges invoice content, delivery, quality, or terms.',
      BillingExceptionEventKind.operationalIncident =>
        'Internal service incident that changes collection handling.',
      BillingExceptionEventKind.contractPause =>
        'Commercially approved pause in service, billing, or collection.',
    };
  }
}

/// Labels for billing exception policy effects.
extension BillingExceptionPolicyEffectLabels on BillingExceptionPolicyEffect {
  String get label {
    return switch (this) {
      BillingExceptionPolicyEffect.pauseDueDates => 'Pause due dates',
      BillingExceptionPolicyEffect.suspendDunning => 'Suspend dunning',
      BillingExceptionPolicyEffect.waiveLateFees => 'Waive late fees',
      BillingExceptionPolicyEffect.reschedulePayments => 'Reschedule payments',
      BillingExceptionPolicyEffect.freezeIssuance => 'Freeze issuance',
      BillingExceptionPolicyEffect.requireApproval => 'Require approval',
      BillingExceptionPolicyEffect.requireEvidence => 'Require evidence',
    };
  }
}
