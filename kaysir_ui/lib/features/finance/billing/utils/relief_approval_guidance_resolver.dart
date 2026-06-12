import '../models/relief_approval_guidance.dart';
import '../models/relief_impact_summary.dart';

/// Resolves operator approval guidance from a relief impact summary.
BillingExceptionReliefApprovalGuidance
resolveBillingExceptionReliefApprovalGuidance({
  required BillingExceptionReliefImpactSummary summary,
  double escalationExposureThreshold = 50000,
  int escalationWindowDays = 45,
}) {
  if (!summary.isReady) {
    return BillingExceptionReliefApprovalGuidance(
      impactSummary: summary,
      decision: BillingExceptionReliefApprovalDecision.blocked,
      reasons:
          summary.blockers.isEmpty
              ? const ['Resolve relief packet blockers first.']
              : summary.blockers,
      actions: const [
        BillingExceptionReliefApprovalAction(
          kind: BillingExceptionReliefApprovalActionKind.resolveBlockers,
          label: 'Resolve blockers',
          description:
              'Complete the missing governance, policy, or capability requirements before approval.',
        ),
      ],
    );
  }

  final requiresEscalation = _requiresEscalation(
    summary: summary,
    escalationExposureThreshold: escalationExposureThreshold,
    escalationWindowDays: escalationWindowDays,
  );
  final decision =
      requiresEscalation
          ? BillingExceptionReliefApprovalDecision.escalate
          : _standardDecision(summary);

  return BillingExceptionReliefApprovalGuidance(
    impactSummary: summary,
    decision: decision,
    reasons: _reasonsFor(
      summary: summary,
      requiresEscalation: requiresEscalation,
      escalationExposureThreshold: escalationExposureThreshold,
      escalationWindowDays: escalationWindowDays,
    ),
    actions: _actionsFor(summary: summary, decision: decision),
  );
}

BillingExceptionReliefApprovalDecision _standardDecision(
  BillingExceptionReliefImpactSummary summary,
) {
  return switch (summary.riskLevel) {
    BillingExceptionReliefImpactRiskLevel.high ||
    BillingExceptionReliefImpactRiskLevel
        .medium => BillingExceptionReliefApprovalDecision.approveWithControls,
    BillingExceptionReliefImpactRiskLevel.low =>
      BillingExceptionReliefApprovalDecision.approve,
    BillingExceptionReliefImpactRiskLevel.blocked =>
      BillingExceptionReliefApprovalDecision.blocked,
  };
}

bool _requiresEscalation({
  required BillingExceptionReliefImpactSummary summary,
  required double escalationExposureThreshold,
  required int escalationWindowDays,
}) {
  return summary.deferredCashAmount >= escalationExposureThreshold ||
      summary.reliefDurationDays >= escalationWindowDays ||
      summary.hasSignalKind(
        BillingExceptionReliefImpactSignalKind.issuanceFreeze,
      );
}

List<String> _reasonsFor({
  required BillingExceptionReliefImpactSummary summary,
  required bool requiresEscalation,
  required double escalationExposureThreshold,
  required int escalationWindowDays,
}) {
  if (requiresEscalation) {
    return [
      if (summary.deferredCashAmount >= escalationExposureThreshold)
        'Deferred exposure exceeds the escalation threshold.',
      if (summary.reliefDurationDays >= escalationWindowDays)
        'Relief duration exceeds the escalation window.',
      if (summary.hasSignalKind(
        BillingExceptionReliefImpactSignalKind.issuanceFreeze,
      ))
        'Invoice issuance is frozen for the exception window.',
    ];
  }

  if (summary.riskLevel == BillingExceptionReliefImpactRiskLevel.high) {
    return const ['High impact relief needs named operational controls.'];
  }
  if (summary.riskLevel == BillingExceptionReliefImpactRiskLevel.medium) {
    return const [
      'Relief changes collection or recovery behavior and should be tracked.',
    ];
  }

  return const ['No material approval guardrails were detected.'];
}

List<BillingExceptionReliefApprovalAction> _actionsFor({
  required BillingExceptionReliefImpactSummary summary,
  required BillingExceptionReliefApprovalDecision decision,
}) {
  final actions = <BillingExceptionReliefApprovalAction>[
    if (decision == BillingExceptionReliefApprovalDecision.escalate ||
        decision == BillingExceptionReliefApprovalDecision.approveWithControls)
      const BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.financeOwnerSignOff,
        label: 'Finance owner sign-off',
        description:
            'Assign a finance owner to accept relief exposure before application.',
      ),
    if (summary.hasCashDeferral)
      BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.updateCashForecast,
        label: 'Cash forecast update',
        description:
            'Move deferred cash into the forecast for the approved relief window.',
        isRequired: decision != BillingExceptionReliefApprovalDecision.approve,
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.collectionHold,
    ))
      const BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.notifyCollections,
        label: 'Collections notice',
        description:
            'Notify collection operators that reminder and escalation activity is paused.',
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.recoverySchedule,
    ))
      const BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.prepareRecoverySchedule,
        label: 'Recovery schedule',
        description:
            'Prepare the post-relief payment schedule before relief is applied.',
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.lateFeeSuppression,
    ))
      const BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.documentFeeWaiver,
        label: 'Fee waiver note',
        description:
            'Document the estimated fee suppression in the relief audit trail.',
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.issuanceFreeze,
    ))
      const BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.reviewIssuanceFreeze,
        label: 'Issuance freeze review',
        description:
            'Confirm the business owner accepts paused invoice issuance.',
      ),
    if (summary.hasSignals)
      BillingExceptionReliefApprovalAction(
        kind: BillingExceptionReliefApprovalActionKind.customerNotice,
        label: 'Customer notice',
        description:
            'Prepare external communication for the approved exception relief.',
        isRequired: decision != BillingExceptionReliefApprovalDecision.approve,
      ),
  ];

  return List.unmodifiable(actions);
}
