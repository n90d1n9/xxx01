class PayableReconciliation {
  final double subledgerBalance;
  final double ledgerBalance;
  final double tolerance;
  final List<PayableSubledgerReconciliationLine> subledgerLines;
  final List<PayableLedgerReconciliationLine> ledgerLines;

  const PayableReconciliation({
    required this.subledgerBalance,
    required this.ledgerBalance,
    this.tolerance = 0.01,
    this.subledgerLines = const [],
    this.ledgerLines = const [],
  });

  double get variance => subledgerBalance - ledgerBalance;

  bool get isBalanced => variance.abs() <= tolerance;
}

class PayableSubledgerReconciliationLine {
  final String billId;
  final String reference;
  final String vendorName;
  final DateTime? dueDate;
  final double remainingAmount;

  const PayableSubledgerReconciliationLine({
    required this.billId,
    required this.reference,
    required this.vendorName,
    required this.remainingAmount,
    this.dueDate,
  });
}

class PayableLedgerReconciliationLine {
  final String postingId;
  final String reference;
  final String description;
  final DateTime date;
  final String source;
  final double debitAmount;
  final double creditAmount;

  const PayableLedgerReconciliationLine({
    required this.postingId,
    required this.reference,
    required this.description,
    required this.date,
    required this.source,
    this.debitAmount = 0,
    this.creditAmount = 0,
  });

  double get balanceImpact => creditAmount - debitAmount;
}
