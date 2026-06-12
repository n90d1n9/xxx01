import 'relief_application_packet.dart';

/// Estimated operational risk level created by an exception relief packet.
enum BillingExceptionReliefImpactRiskLevel { blocked, low, medium, high }

/// Impact signal kind derived from relief application commands.
enum BillingExceptionReliefImpactSignalKind {
  cashDeferral,
  collectionHold,
  lateFeeSuppression,
  recoverySchedule,
  issuanceFreeze,
}

/// One business impact signal produced by a relief application packet.
class BillingExceptionReliefImpactSignal {
  final BillingExceptionReliefImpactSignalKind kind;
  final String label;
  final String description;
  final double amount;
  final int affectedInvoiceCount;
  final int durationDays;

  const BillingExceptionReliefImpactSignal({
    required this.kind,
    required this.label,
    required this.description,
    this.amount = 0,
    this.affectedInvoiceCount = 0,
    this.durationDays = 0,
  });

  bool get hasAmount => amount > 0;
}

/// Read-only business impact summary for an exception relief application.
class BillingExceptionReliefImpactSummary {
  final BillingExceptionReliefApplicationPacket packet;
  final BillingExceptionReliefImpactRiskLevel riskLevel;
  final double deferredCashAmount;
  final double estimatedDailyCashDeferral;
  final double estimatedLateFeeWaiverAmount;
  final List<BillingExceptionReliefImpactSignal> signals;
  final List<String> blockers;

  BillingExceptionReliefImpactSummary({
    required this.packet,
    required this.riskLevel,
    this.deferredCashAmount = 0,
    this.estimatedDailyCashDeferral = 0,
    this.estimatedLateFeeWaiverAmount = 0,
    Iterable<BillingExceptionReliefImpactSignal> signals = const [],
    Iterable<String> blockers = const [],
  }) : signals = List.unmodifiable(signals),
       blockers = List.unmodifiable(blockers);

  bool get isReady =>
      riskLevel != BillingExceptionReliefImpactRiskLevel.blocked;

  bool get hasSignals => signals.isNotEmpty;

  bool get hasBlockers => blockers.isNotEmpty;

  int get signalCount => signals.length;

  int get affectedInvoiceCount => packet.plan.affectedInvoiceCount;

  int get reliefDurationDays => packet.plan.reliefDurationDays;

  bool get hasCashDeferral {
    return hasSignalKind(BillingExceptionReliefImpactSignalKind.cashDeferral);
  }

  String get statusLabel {
    return switch (riskLevel) {
      BillingExceptionReliefImpactRiskLevel.blocked => 'Blocked',
      BillingExceptionReliefImpactRiskLevel.low => 'Low impact',
      BillingExceptionReliefImpactRiskLevel.medium => 'Medium impact',
      BillingExceptionReliefImpactRiskLevel.high => 'High impact',
    };
  }

  String get summaryLabel {
    if (!isReady) {
      return 'Relief impact cannot be finalized until packet blockers are resolved.';
    }
    if (signals.isEmpty) {
      return 'No material relief impact signals were detected.';
    }

    return '$signalCount impact ${signalCount == 1 ? 'signal' : 'signals'} '
        'across $affectedInvoiceCount '
        '${affectedInvoiceCount == 1 ? 'invoice' : 'invoices'}.';
  }

  bool hasSignalKind(BillingExceptionReliefImpactSignalKind kind) {
    return signals.any((signal) => signal.kind == kind);
  }

  BillingExceptionReliefImpactSignal? signalFor(
    BillingExceptionReliefImpactSignalKind kind,
  ) {
    for (final signal in signals) {
      if (signal.kind == kind) return signal;
    }

    return null;
  }
}
