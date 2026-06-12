import '../models/relief_execution_plan.dart';
import '../models/relief_impact_summary.dart';
import '../models/relief_monitoring_plan.dart';

/// Builds a post-execution monitoring plan for exception relief.
BillingExceptionReliefMonitoringPlan buildBillingExceptionReliefMonitoringPlan({
  required BillingExceptionReliefExecutionPlan executionPlan,
  int closeoutBufferDays = 3,
}) {
  if (executionPlan.isBlocked) {
    return BillingExceptionReliefMonitoringPlan(
      executionPlan: executionPlan,
      status: BillingExceptionReliefMonitoringStatus.blocked,
      blockers:
          executionPlan.blockers.isEmpty
              ? const ['Resolve relief execution blockers first.']
              : executionPlan.blockers,
      checkpoints: const [
        BillingExceptionReliefMonitoringCheckpoint(
          kind: BillingExceptionReliefMonitoringCheckpointKind.unblock,
          label: 'Resolve execution blockers',
          ownerRole: 'Billing operations',
          description:
              'Complete the blocked execution handoff before monitoring starts.',
          dueInDays: 0,
          isBlocked: true,
        ),
      ],
    );
  }

  final summary = executionPlan.guidance.impactSummary;
  final reliefDurationDays = summary.reliefDurationDays;
  final checkpoints = <BillingExceptionReliefMonitoringCheckpoint>[
    if (executionPlan.requiresEscalation)
      const BillingExceptionReliefMonitoringCheckpoint(
        kind: BillingExceptionReliefMonitoringCheckpointKind.escalationReview,
        label: 'Escalation review',
        ownerRole: 'Finance leadership',
        description:
            'Confirm leadership has cleared exposure and recovery controls.',
        dueInDays: 0,
      ),
    BillingExceptionReliefMonitoringCheckpoint(
      kind: BillingExceptionReliefMonitoringCheckpointKind.executionStart,
      label: 'Execution start',
      ownerRole: 'Billing operations',
      description:
          'Verify relief commands are applied and the audit packet is attached.',
      dueInDays: 0,
      isBlocked: executionPlan.requiresEscalation,
    ),
    if (summary.hasCashDeferral)
      const BillingExceptionReliefMonitoringCheckpoint(
        kind: BillingExceptionReliefMonitoringCheckpointKind.cashForecastReview,
        label: 'Cash forecast review',
        ownerRole: 'Treasury',
        description:
            'Confirm deferred cash is visible in forecast and liquidity review.',
        dueInDays: 1,
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.collectionHold,
    ))
      BillingExceptionReliefMonitoringCheckpoint(
        kind: BillingExceptionReliefMonitoringCheckpointKind.collectionsReview,
        label: 'Collections pause review',
        ownerRole: 'Collections lead',
        description:
            'Check paused reminders and escalation holds before the midpoint.',
        dueInDays: _midpointDay(reliefDurationDays),
      ),
    if (executionPlan.hasPhase(BillingExceptionReliefExecutionPhase.customer))
      const BillingExceptionReliefMonitoringCheckpoint(
        kind: BillingExceptionReliefMonitoringCheckpointKind.customerFollowUp,
        label: 'Customer follow-up',
        ownerRole: 'Customer success',
        description:
            'Confirm external relief communication has been sent and logged.',
        dueInDays: 1,
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.recoverySchedule,
    ))
      BillingExceptionReliefMonitoringCheckpoint(
        kind: BillingExceptionReliefMonitoringCheckpointKind.recoveryKickoff,
        label: 'Recovery kickoff',
        ownerRole: 'Accounts receivable',
        description:
            'Start the post-relief recovery schedule for open exposure.',
        dueInDays: reliefDurationDays,
      ),
    if (summary.hasSignalKind(
      BillingExceptionReliefImpactSignalKind.lateFeeSuppression,
    ))
      BillingExceptionReliefMonitoringCheckpoint(
        kind:
            BillingExceptionReliefMonitoringCheckpointKind
                .feeWaiverReconciliation,
        label: 'Fee waiver reconciliation',
        ownerRole: 'Billing policy owner',
        description:
            'Reconcile suppressed late fees against the approved relief packet.',
        dueInDays: reliefDurationDays,
      ),
    BillingExceptionReliefMonitoringCheckpoint(
      kind: BillingExceptionReliefMonitoringCheckpointKind.reliefCloseout,
      label: 'Relief closeout',
      ownerRole: 'Finance owner',
      description:
          'Close the relief window, confirm recovery ownership, and archive evidence.',
      dueInDays: reliefDurationDays + closeoutBufferDays,
    ),
  ];

  return BillingExceptionReliefMonitoringPlan(
    executionPlan: executionPlan,
    status: _statusFor(executionPlan),
    checkpoints: checkpoints,
  );
}

BillingExceptionReliefMonitoringStatus _statusFor(
  BillingExceptionReliefExecutionPlan executionPlan,
) {
  if (executionPlan.requiresEscalation) {
    return BillingExceptionReliefMonitoringStatus.escalationWatch;
  }
  if (executionPlan.status ==
          BillingExceptionReliefExecutionStatus.controlsRequired ||
      executionPlan.guidance.impactSummary.riskLevel ==
          BillingExceptionReliefImpactRiskLevel.high ||
      executionPlan.guidance.impactSummary.riskLevel ==
          BillingExceptionReliefImpactRiskLevel.medium) {
    return BillingExceptionReliefMonitoringStatus.activeWatch;
  }

  return BillingExceptionReliefMonitoringStatus.standardWatch;
}

int _midpointDay(int reliefDurationDays) {
  if (reliefDurationDays <= 2) return 1;
  return (reliefDurationDays / 2).ceil();
}
