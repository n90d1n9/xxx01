import 'relief_impact_summary.dart';

/// Approval route recommended after exception relief impact is evaluated.
enum BillingExceptionReliefApprovalDecision {
  blocked,
  approve,
  approveWithControls,
  escalate,
}

/// Operational control that should be completed around relief approval.
enum BillingExceptionReliefApprovalActionKind {
  resolveBlockers,
  financeOwnerSignOff,
  updateCashForecast,
  notifyCollections,
  prepareRecoverySchedule,
  documentFeeWaiver,
  reviewIssuanceFreeze,
  customerNotice,
}

/// One recommended operator action for applying relief safely.
class BillingExceptionReliefApprovalAction {
  final BillingExceptionReliefApprovalActionKind kind;
  final String label;
  final String description;
  final bool isRequired;

  const BillingExceptionReliefApprovalAction({
    required this.kind,
    required this.label,
    required this.description,
    this.isRequired = true,
  });

  String get statusLabel => isRequired ? 'Required' : 'Recommended';
}

/// Approval guidance derived from relief readiness and business impact.
class BillingExceptionReliefApprovalGuidance {
  final BillingExceptionReliefImpactSummary impactSummary;
  final BillingExceptionReliefApprovalDecision decision;
  final List<BillingExceptionReliefApprovalAction> actions;
  final List<String> reasons;

  BillingExceptionReliefApprovalGuidance({
    required this.impactSummary,
    required this.decision,
    Iterable<BillingExceptionReliefApprovalAction> actions = const [],
    Iterable<String> reasons = const [],
  }) : actions = List.unmodifiable(actions),
       reasons = List.unmodifiable(reasons);

  bool get isBlocked =>
      decision == BillingExceptionReliefApprovalDecision.blocked;

  bool get requiresEscalation =>
      decision == BillingExceptionReliefApprovalDecision.escalate;

  bool get hasActions => actions.isNotEmpty;

  bool get hasReasons => reasons.isNotEmpty;

  int get requiredActionCount {
    return actions.where((action) => action.isRequired).length;
  }

  String get statusLabel {
    return switch (decision) {
      BillingExceptionReliefApprovalDecision.blocked => 'Blocked',
      BillingExceptionReliefApprovalDecision.approve => 'Approve',
      BillingExceptionReliefApprovalDecision.approveWithControls =>
        'Approve with controls',
      BillingExceptionReliefApprovalDecision.escalate => 'Escalate',
    };
  }

  String get primaryActionLabel {
    return switch (decision) {
      BillingExceptionReliefApprovalDecision.blocked => 'Resolve blockers',
      BillingExceptionReliefApprovalDecision.approve => 'Apply relief',
      BillingExceptionReliefApprovalDecision.approveWithControls =>
        'Assign controls',
      BillingExceptionReliefApprovalDecision.escalate => 'Escalate review',
    };
  }

  String get summaryLabel {
    return switch (decision) {
      BillingExceptionReliefApprovalDecision.blocked =>
        'Resolve packet blockers before relief approval can continue.',
      BillingExceptionReliefApprovalDecision.approve =>
        'Relief can be approved with the standard audit trail.',
      BillingExceptionReliefApprovalDecision.approveWithControls =>
        'Relief can proceed after the recommended operational controls are assigned.',
      BillingExceptionReliefApprovalDecision.escalate =>
        'Relief should be escalated before application because exposure or hold risk is high.',
    };
  }

  bool hasActionKind(BillingExceptionReliefApprovalActionKind kind) {
    return actions.any((action) => action.kind == kind);
  }
}
