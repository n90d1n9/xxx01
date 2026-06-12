import '../models/exception_relief_plan.dart';
import '../models/relief_application_packet.dart';
import '../models/relief_impact_summary.dart';

/// Builds a business impact summary from a relief application packet.
BillingExceptionReliefImpactSummary summarizeBillingExceptionReliefImpact({
  required BillingExceptionReliefApplicationPacket packet,
  double estimatedLateFeeWaiverRate = 0.015,
  double highExposureThreshold = 25000,
  int longReliefWindowDays = 30,
}) {
  if (!packet.isReady) {
    return BillingExceptionReliefImpactSummary(
      packet: packet,
      riskLevel: BillingExceptionReliefImpactRiskLevel.blocked,
      blockers:
          packet.issues.isEmpty
              ? const ['Resolve relief application blockers first.']
              : packet.issues.map((issue) => issue.message),
    );
  }

  final hasDueDatePause = _hasCommand(
    packet,
    BillingExceptionReliefActionKind.pauseDueDates,
  );
  final hasPaymentReschedule = _hasCommand(
    packet,
    BillingExceptionReliefActionKind.reschedulePayments,
  );
  final hasDunningPause = _hasCommand(
    packet,
    BillingExceptionReliefActionKind.suspendDunning,
  );
  final hasLateFeeWaiver = _hasCommand(
    packet,
    BillingExceptionReliefActionKind.waiveLateFees,
  );
  final hasIssuanceFreeze = _hasCommand(
    packet,
    BillingExceptionReliefActionKind.freezeIssuance,
  );
  final deferredCashAmount =
      hasDueDatePause || hasPaymentReschedule ? packet.plan.openAmount : 0.0;
  final estimatedDailyCashDeferral =
      packet.plan.reliefDurationDays > 0
          ? deferredCashAmount / packet.plan.reliefDurationDays
          : 0.0;
  final estimatedLateFeeWaiverAmount =
      hasLateFeeWaiver
          ? packet.plan.openAmount * estimatedLateFeeWaiverRate
          : 0.0;
  final signals = <BillingExceptionReliefImpactSignal>[
    if (deferredCashAmount > 0)
      BillingExceptionReliefImpactSignal(
        kind: BillingExceptionReliefImpactSignalKind.cashDeferral,
        label: 'Cash deferral',
        description:
            'Open exposure may be delayed for the approved relief window.',
        amount: deferredCashAmount,
        affectedInvoiceCount: packet.plan.affectedInvoiceCount,
        durationDays: packet.plan.reliefDurationDays,
      ),
    if (hasDunningPause)
      BillingExceptionReliefImpactSignal(
        kind: BillingExceptionReliefImpactSignalKind.collectionHold,
        label: 'Collection hold',
        description:
            'Reminder and escalation activity pauses for affected invoices.',
        affectedInvoiceCount: packet.plan.affectedInvoiceCount,
        durationDays: packet.plan.reliefDurationDays,
      ),
    if (estimatedLateFeeWaiverAmount > 0)
      BillingExceptionReliefImpactSignal(
        kind: BillingExceptionReliefImpactSignalKind.lateFeeSuppression,
        label: 'Late fee suppression',
        description: 'Estimated fees are suppressed during the relief window.',
        amount: estimatedLateFeeWaiverAmount,
        affectedInvoiceCount: packet.plan.affectedInvoiceCount,
        durationDays: packet.plan.reliefDurationDays,
      ),
    if (hasPaymentReschedule)
      BillingExceptionReliefImpactSignal(
        kind: BillingExceptionReliefImpactSignalKind.recoverySchedule,
        label: 'Recovery schedule',
        description:
            'Open exposure should move into a post-relief recovery schedule.',
        amount: packet.plan.openAmount,
        affectedInvoiceCount: packet.plan.affectedInvoiceCount,
        durationDays: packet.plan.reliefDurationDays,
      ),
    if (hasIssuanceFreeze)
      BillingExceptionReliefImpactSignal(
        kind: BillingExceptionReliefImpactSignalKind.issuanceFreeze,
        label: 'Issuance freeze',
        description: 'New invoice issuance is held until the exception clears.',
        affectedInvoiceCount: packet.plan.affectedInvoiceCount,
        durationDays: packet.plan.reliefDurationDays,
      ),
  ];

  return BillingExceptionReliefImpactSummary(
    packet: packet,
    riskLevel: _riskLevel(
      deferredCashAmount: deferredCashAmount,
      reliefDurationDays: packet.plan.reliefDurationDays,
      highExposureThreshold: highExposureThreshold,
      longReliefWindowDays: longReliefWindowDays,
      signalCount: signals.length,
      hasIssuanceFreeze: hasIssuanceFreeze,
    ),
    deferredCashAmount: deferredCashAmount,
    estimatedDailyCashDeferral: estimatedDailyCashDeferral,
    estimatedLateFeeWaiverAmount: estimatedLateFeeWaiverAmount,
    signals: signals,
  );
}

bool _hasCommand(
  BillingExceptionReliefApplicationPacket packet,
  BillingExceptionReliefActionKind kind,
) {
  return packet.commands.any((command) => command.actionKind == kind);
}

BillingExceptionReliefImpactRiskLevel _riskLevel({
  required double deferredCashAmount,
  required int reliefDurationDays,
  required double highExposureThreshold,
  required int longReliefWindowDays,
  required int signalCount,
  required bool hasIssuanceFreeze,
}) {
  if (hasIssuanceFreeze ||
      deferredCashAmount >= highExposureThreshold ||
      reliefDurationDays >= longReliefWindowDays) {
    return BillingExceptionReliefImpactRiskLevel.high;
  }
  if (signalCount >= 2 || deferredCashAmount > 0) {
    return BillingExceptionReliefImpactRiskLevel.medium;
  }

  return BillingExceptionReliefImpactRiskLevel.low;
}
