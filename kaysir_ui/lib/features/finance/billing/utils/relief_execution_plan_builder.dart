import '../models/relief_approval_guidance.dart';
import '../models/relief_execution_plan.dart';

/// Builds an ordered execution handoff from approval guidance.
BillingExceptionReliefExecutionPlan buildBillingExceptionReliefExecutionPlan({
  required BillingExceptionReliefApprovalGuidance guidance,
}) {
  if (guidance.isBlocked) {
    return BillingExceptionReliefExecutionPlan(
      guidance: guidance,
      status: BillingExceptionReliefExecutionStatus.blocked,
      blockers:
          guidance.reasons.isEmpty
              ? const ['Resolve relief approval blockers first.']
              : guidance.reasons,
      steps: const [
        BillingExceptionReliefExecutionStep(
          phase: BillingExceptionReliefExecutionPhase.unblock,
          label: 'Resolve blockers',
          ownerRole: 'Billing operations',
          description:
              'Complete missing governance, evidence, capability, or policy requirements before execution.',
          isBlocked: true,
        ),
      ],
    );
  }

  final steps = <BillingExceptionReliefExecutionStep>[
    if (guidance.requiresEscalation)
      const BillingExceptionReliefExecutionStep(
        phase: BillingExceptionReliefExecutionPhase.approval,
        label: 'Escalation review',
        ownerRole: 'Finance leadership',
        description:
            'Review relief exposure and approve the execution route before commands are applied.',
      ),
    for (final action in guidance.actions) _stepForAction(action),
    BillingExceptionReliefExecutionStep(
      phase: BillingExceptionReliefExecutionPhase.application,
      label: 'Apply relief commands',
      ownerRole: 'Billing operations',
      description:
          '${guidance.impactSummary.packet.commandCount} relief '
          '${guidance.impactSummary.packet.commandCount == 1 ? 'command is' : 'commands are'} '
          'ready to apply through the application packet.',
      isBlocked: guidance.requiresEscalation,
    ),
  ];

  return BillingExceptionReliefExecutionPlan(
    guidance: guidance,
    status: _statusFor(guidance),
    steps: steps,
  );
}

BillingExceptionReliefExecutionStatus _statusFor(
  BillingExceptionReliefApprovalGuidance guidance,
) {
  return switch (guidance.decision) {
    BillingExceptionReliefApprovalDecision.blocked =>
      BillingExceptionReliefExecutionStatus.blocked,
    BillingExceptionReliefApprovalDecision.escalate =>
      BillingExceptionReliefExecutionStatus.escalationRequired,
    BillingExceptionReliefApprovalDecision.approveWithControls =>
      BillingExceptionReliefExecutionStatus.controlsRequired,
    BillingExceptionReliefApprovalDecision.approve =>
      BillingExceptionReliefExecutionStatus.ready,
  };
}

BillingExceptionReliefExecutionStep _stepForAction(
  BillingExceptionReliefApprovalAction action,
) {
  return BillingExceptionReliefExecutionStep(
    phase: _phaseForAction(action.kind),
    label: action.label,
    ownerRole: _ownerForAction(action.kind),
    description: action.description,
    isRequired: action.isRequired,
  );
}

BillingExceptionReliefExecutionPhase _phaseForAction(
  BillingExceptionReliefApprovalActionKind kind,
) {
  return switch (kind) {
    BillingExceptionReliefApprovalActionKind.resolveBlockers =>
      BillingExceptionReliefExecutionPhase.unblock,
    BillingExceptionReliefApprovalActionKind.financeOwnerSignOff ||
    BillingExceptionReliefApprovalActionKind.documentFeeWaiver ||
    BillingExceptionReliefApprovalActionKind
        .reviewIssuanceFreeze => BillingExceptionReliefExecutionPhase.approval,
    BillingExceptionReliefApprovalActionKind.updateCashForecast =>
      BillingExceptionReliefExecutionPhase.forecast,
    BillingExceptionReliefApprovalActionKind.notifyCollections =>
      BillingExceptionReliefExecutionPhase.collections,
    BillingExceptionReliefApprovalActionKind.prepareRecoverySchedule =>
      BillingExceptionReliefExecutionPhase.recovery,
    BillingExceptionReliefApprovalActionKind.customerNotice =>
      BillingExceptionReliefExecutionPhase.customer,
  };
}

String _ownerForAction(BillingExceptionReliefApprovalActionKind kind) {
  return switch (kind) {
    BillingExceptionReliefApprovalActionKind.resolveBlockers =>
      'Billing operations',
    BillingExceptionReliefApprovalActionKind.financeOwnerSignOff =>
      'Finance owner',
    BillingExceptionReliefApprovalActionKind.updateCashForecast => 'Treasury',
    BillingExceptionReliefApprovalActionKind.notifyCollections =>
      'Collections lead',
    BillingExceptionReliefApprovalActionKind.prepareRecoverySchedule =>
      'Accounts receivable',
    BillingExceptionReliefApprovalActionKind.documentFeeWaiver =>
      'Billing policy owner',
    BillingExceptionReliefApprovalActionKind.reviewIssuanceFreeze =>
      'Business owner',
    BillingExceptionReliefApprovalActionKind.customerNotice =>
      'Customer success',
  };
}
