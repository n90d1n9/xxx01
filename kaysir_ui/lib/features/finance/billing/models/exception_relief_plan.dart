import 'billing_exception_event.dart';
import 'billing_policy_capability.dart';
import 'policy_exception_plan.dart';

/// Operational action that may be performed during billing exception relief.
enum BillingExceptionReliefActionKind {
  pauseDueDates,
  suspendDunning,
  waiveLateFees,
  reschedulePayments,
  freezeIssuance,
  captureEvidence,
  requestApproval,
}

/// Blocking condition that prevents exception relief from being applied safely.
enum BillingExceptionReliefIssueKind {
  policyNotConfigured,
  missingCapability,
  approvalRequired,
  evidenceRequired,
  invalidAffectedInvoiceCount,
  invalidOpenAmount,
  invalidReliefDuration,
  noReliefEffects,
}

/// One executable or governance step in an exception relief workflow.
class BillingExceptionReliefAction {
  final BillingExceptionReliefActionKind kind;
  final String label;
  final String description;
  final BillingExceptionPolicyEffect? effect;
  final Set<BillingPolicyCapabilityId> requiredCapabilityIds;
  final Set<BillingPolicyCapabilityId> missingCapabilityIds;
  final bool completed;

  BillingExceptionReliefAction({
    required this.kind,
    required this.label,
    required this.description,
    this.effect,
    Iterable<BillingPolicyCapabilityId> requiredCapabilityIds = const [],
    Iterable<BillingPolicyCapabilityId> missingCapabilityIds = const [],
    this.completed = false,
  }) : requiredCapabilityIds = Set.unmodifiable(requiredCapabilityIds),
       missingCapabilityIds = Set.unmodifiable(missingCapabilityIds);

  bool get isGovernance {
    return kind == BillingExceptionReliefActionKind.captureEvidence ||
        kind == BillingExceptionReliefActionKind.requestApproval;
  }

  bool get isBlocked => missingCapabilityIds.isNotEmpty;

  bool get isReady => !isBlocked && (!isGovernance || completed);

  String get statusLabel {
    if (isBlocked) return 'Blocked';
    if (completed) return 'Done';
    if (isGovernance) return 'Required';
    return 'Ready';
  }

  String get capabilitySummaryLabel {
    if (missingCapabilityIds.isEmpty) return 'Capabilities ready';
    return 'Needs ${_capabilityListLabel(missingCapabilityIds)}';
  }
}

/// Human-readable issue emitted by exception relief planning.
class BillingExceptionReliefIssue {
  final BillingExceptionReliefIssueKind kind;
  final String message;
  final String? details;
  final BillingPolicyCapabilityId? capabilityId;

  const BillingExceptionReliefIssue({
    required this.kind,
    required this.message,
    this.details,
    this.capabilityId,
  });

  bool get isCapabilityIssue {
    return kind == BillingExceptionReliefIssueKind.missingCapability;
  }

  bool get isGovernanceIssue {
    return kind == BillingExceptionReliefIssueKind.approvalRequired ||
        kind == BillingExceptionReliefIssueKind.evidenceRequired;
  }

  bool get isContextIssue {
    return kind ==
            BillingExceptionReliefIssueKind.invalidAffectedInvoiceCount ||
        kind == BillingExceptionReliefIssueKind.invalidOpenAmount ||
        kind == BillingExceptionReliefIssueKind.invalidReliefDuration;
  }

  bool get isBlocker => true;
}

/// Evaluated relief workflow for an active billing exception condition.
class BillingExceptionReliefPlan {
  final BillingPolicyExceptionPlan policyPlan;
  final int affectedInvoiceCount;
  final double openAmount;
  final int reliefDurationDays;
  final bool approvalGranted;
  final bool evidenceCaptured;
  final List<BillingExceptionReliefAction> actions;
  final List<BillingExceptionReliefIssue> issues;

  BillingExceptionReliefPlan({
    required this.policyPlan,
    required this.affectedInvoiceCount,
    required this.openAmount,
    required this.reliefDurationDays,
    required this.approvalGranted,
    required this.evidenceCaptured,
    Iterable<BillingExceptionReliefAction> actions = const [],
    Iterable<BillingExceptionReliefIssue> issues = const [],
  }) : actions = List.unmodifiable(actions),
       issues = List.unmodifiable(issues);

  BillingExceptionEventKind get kind => policyPlan.kind;

  bool get hasIssues => issues.isNotEmpty;

  bool get hasBlockers => issues.any((issue) => issue.isBlocker);

  bool get needsCapability => issues.any((issue) => issue.isCapabilityIssue);

  bool get needsGovernance => issues.any((issue) => issue.isGovernanceIssue);

  bool get needsContext => issues.any((issue) => issue.isContextIssue);

  bool get isActionable => policyPlan.isActionable && !hasBlockers;

  int get operationalActionCount {
    return actions.where((action) => !action.isGovernance).length;
  }

  int get readyOperationalActionCount {
    return actions
        .where((action) => !action.isGovernance && !action.isBlocked)
        .length;
  }

  List<BillingExceptionReliefAction> get governanceActions {
    return List.unmodifiable(actions.where((action) => action.isGovernance));
  }

  List<BillingExceptionReliefAction> get blockedActions {
    return List.unmodifiable(actions.where((action) => action.isBlocked));
  }

  List<BillingExceptionReliefIssue> get blockerIssues {
    return List.unmodifiable(issues.where((issue) => issue.isBlocker));
  }

  String get statusLabel {
    if (hasIssueKind(BillingExceptionReliefIssueKind.policyNotConfigured)) {
      return 'Not configured';
    }
    if (needsContext) return 'Needs context';
    if (needsCapability) return 'Needs capability';
    if (needsGovernance) return 'Needs governance';
    if (hasIssueKind(BillingExceptionReliefIssueKind.noReliefEffects)) {
      return 'No relief effects';
    }
    return 'Ready';
  }

  String get summaryLabel {
    if (hasIssueKind(BillingExceptionReliefIssueKind.policyNotConfigured)) {
      return 'No ${kind.label.toLowerCase()} relief policy is configured.';
    }
    if (needsContext) {
      return 'Complete the affected invoice, amount, and duration context before relief can apply.';
    }
    if (needsCapability) {
      return '${kind.label} relief is blocked by missing capabilities.';
    }
    if (needsGovernance) {
      return '${kind.label} relief needs approval or evidence before it can be applied.';
    }
    if (hasIssueKind(BillingExceptionReliefIssueKind.noReliefEffects)) {
      return 'No operational relief effect is configured for ${kind.label.toLowerCase()}.';
    }

    return '${kind.label} relief can apply $readyOperationalActionCount '
        '${readyOperationalActionCount == 1 ? 'action' : 'actions'} across '
        '$_affectedInvoiceLabel.';
  }

  bool hasIssueKind(BillingExceptionReliefIssueKind kind) {
    return issues.any((issue) => issue.kind == kind);
  }

  String get _affectedInvoiceLabel {
    return affectedInvoiceCount == 1
        ? '1 invoice'
        : '$affectedInvoiceCount invoices';
  }
}

/// Labels for relief workflow action kinds.
extension BillingExceptionReliefActionKindLabels
    on BillingExceptionReliefActionKind {
  String get label {
    return switch (this) {
      BillingExceptionReliefActionKind.pauseDueDates => 'Pause due dates',
      BillingExceptionReliefActionKind.suspendDunning => 'Suspend dunning',
      BillingExceptionReliefActionKind.waiveLateFees => 'Waive late fees',
      BillingExceptionReliefActionKind.reschedulePayments =>
        'Reschedule payments',
      BillingExceptionReliefActionKind.freezeIssuance => 'Freeze issuance',
      BillingExceptionReliefActionKind.captureEvidence => 'Capture evidence',
      BillingExceptionReliefActionKind.requestApproval => 'Submit approval',
    };
  }
}

String _capabilityListLabel(Set<BillingPolicyCapabilityId> capabilityIds) {
  if (capabilityIds.isEmpty) return 'no additional capabilities';

  final labels = capabilityIds.map((id) => id.label).toList(growable: false);
  if (labels.length == 1) return labels.single;
  if (labels.length == 2) return '${labels.first} and ${labels.last}';

  return '${labels.take(labels.length - 1).join(', ')}, and ${labels.last}';
}
