enum BankReconciliationControlSeverity {
  needsEvidence,
  ready,
  postAdjustments,
  timingReview,
  investigate,
}

extension BankReconciliationControlSeverityLabel
    on BankReconciliationControlSeverity {
  String get label {
    switch (this) {
      case BankReconciliationControlSeverity.needsEvidence:
        return 'Needs statement';
      case BankReconciliationControlSeverity.ready:
        return 'Balanced';
      case BankReconciliationControlSeverity.postAdjustments:
        return 'Post adjustments';
      case BankReconciliationControlSeverity.timingReview:
        return 'Review timing';
      case BankReconciliationControlSeverity.investigate:
        return 'Investigate';
    }
  }
}

class BankReconciliationControlSummary {
  final BankReconciliationControlSeverity severity;
  final String nextAction;
  final int statementLineCount;
  final int matchedCount;
  final int unmatchedStatementCount;
  final int unmatchedLedgerCount;
  final int suggestedJournalCount;
  final int timingDifferenceCount;
  final int staleThresholdDays;
  final BankReconciliationTimingAgingSummary timingAging;
  final int? oldestUnmatchedAgeDays;
  final DateTime? oldestUnmatchedDate;
  final String? oldestUnmatchedReference;

  const BankReconciliationControlSummary({
    required this.severity,
    required this.nextAction,
    required this.statementLineCount,
    required this.matchedCount,
    required this.unmatchedStatementCount,
    required this.unmatchedLedgerCount,
    required this.suggestedJournalCount,
    required this.timingDifferenceCount,
    required this.staleThresholdDays,
    this.timingAging = const BankReconciliationTimingAgingSummary.empty(),
    this.oldestUnmatchedAgeDays,
    this.oldestUnmatchedDate,
    this.oldestUnmatchedReference,
  });

  String get statusLabel => severity.label;

  bool get isReadyToClose =>
      severity == BankReconciliationControlSeverity.ready;

  bool get requiresAttention => !isReadyToClose;

  int get unmatchedCount => unmatchedStatementCount + unmatchedLedgerCount;

  bool get hasUnmatchedItems => unmatchedCount > 0;

  bool get hasStaleUnmatchedItems {
    final ageDays = oldestUnmatchedAgeDays;
    return ageDays != null && ageDays >= staleThresholdDays;
  }

  String get oldestUnmatchedAgeLabel {
    final ageDays = oldestUnmatchedAgeDays;
    if (ageDays == null) {
      return 'N/A';
    }
    return '$ageDays days';
  }

  String get timingAgingLabel => timingAging.label;
}

class BankReconciliationTimingAgingSummary {
  final int currentCount;
  final int watchCount;
  final int staleCount;
  final double currentAmount;
  final double watchAmount;
  final double staleAmount;

  const BankReconciliationTimingAgingSummary({
    required this.currentCount,
    required this.watchCount,
    required this.staleCount,
    required this.currentAmount,
    required this.watchAmount,
    required this.staleAmount,
  });

  const BankReconciliationTimingAgingSummary.empty()
    : currentCount = 0,
      watchCount = 0,
      staleCount = 0,
      currentAmount = 0,
      watchAmount = 0,
      staleAmount = 0;

  int get totalCount => currentCount + watchCount + staleCount;

  double get totalAmount => currentAmount + watchAmount + staleAmount;

  bool get hasItems => totalCount > 0;

  bool get hasWatchItems => watchCount > 0;

  bool get hasStaleItems => staleCount > 0;

  String amountLabel(String Function(double amount) formatAmount) {
    if (!hasItems) {
      return 'No timing exposure';
    }
    return 'Current ${formatAmount(currentAmount)} / Watch ${formatAmount(watchAmount)} / Stale ${formatAmount(staleAmount)}';
  }

  String get label {
    if (!hasItems) {
      return 'No timing items';
    }
    return 'Current $currentCount / Watch $watchCount / Stale $staleCount';
  }
}
