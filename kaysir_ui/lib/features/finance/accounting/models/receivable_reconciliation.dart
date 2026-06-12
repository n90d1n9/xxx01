class ReceivableAgingBucketIds {
  static const current = 'current';
  static const overdue1To30 = 'overdue-1-30';
  static const overdue31To60 = 'overdue-31-60';
  static const overdue61To90 = 'overdue-61-90';
  static const overdueOver90 = 'overdue-over-90';

  const ReceivableAgingBucketIds._();
}

class ReceivableReconciliation {
  final double subledgerBalance;
  final double ledgerBalance;
  final double tolerance;
  final List<ReceivableSubledgerReconciliationLine> subledgerLines;
  final List<ReceivableLedgerReconciliationLine> ledgerLines;
  final List<ReceivableAgingBucket> agingBuckets;

  const ReceivableReconciliation({
    required this.subledgerBalance,
    required this.ledgerBalance,
    this.tolerance = 0.01,
    this.subledgerLines = const [],
    this.ledgerLines = const [],
    this.agingBuckets = const [],
  });

  double get variance => subledgerBalance - ledgerBalance;

  bool get isBalanced => variance.abs() <= tolerance;

  double get overdueBalance {
    return agingBuckets
        .where((bucket) => bucket.id != ReceivableAgingBucketIds.current)
        .fold(0.0, (sum, bucket) => sum + bucket.amount);
  }

  int get oldestDaysPastDue {
    if (subledgerLines.isEmpty) {
      return 0;
    }
    return subledgerLines
        .map((line) => line.daysPastDue)
        .reduce((value, element) => value >= element ? value : element);
  }
}

class ReceivableSubledgerReconciliationLine {
  final String invoiceId;
  final String reference;
  final String customerName;
  final DateTime? dueDate;
  final double remainingAmount;
  final int daysPastDue;

  const ReceivableSubledgerReconciliationLine({
    required this.invoiceId,
    required this.reference,
    required this.customerName,
    required this.remainingAmount,
    required this.daysPastDue,
    this.dueDate,
  });
}

class ReceivableLedgerReconciliationLine {
  final String postingId;
  final String reference;
  final String description;
  final DateTime date;
  final String source;
  final double debitAmount;
  final double creditAmount;

  const ReceivableLedgerReconciliationLine({
    required this.postingId,
    required this.reference,
    required this.description,
    required this.date,
    required this.source,
    this.debitAmount = 0,
    this.creditAmount = 0,
  });

  double get balanceImpact => debitAmount - creditAmount;
}

class ReceivableAgingBucket {
  final String id;
  final String label;
  final double amount;
  final int invoiceCount;

  const ReceivableAgingBucket({
    required this.id,
    required this.label,
    required this.amount,
    required this.invoiceCount,
  });
}
