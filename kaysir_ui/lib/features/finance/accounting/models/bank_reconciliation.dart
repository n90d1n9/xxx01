import 'ledger_trx.dart';

enum BankReconciliationMatchType { reference, amountAndDate }

extension BankReconciliationMatchTypeLabel on BankReconciliationMatchType {
  String get label {
    switch (this) {
      case BankReconciliationMatchType.reference:
        return 'Reference';
      case BankReconciliationMatchType.amountAndDate:
        return 'Amount/date';
    }
  }
}

class BankStatementLine {
  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final String? reference;

  const BankStatementLine({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.reference,
  });

  factory BankStatementLine.fromJson(Map<String, dynamic> json) {
    return BankStatementLine(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      reference: json['reference'] as String?,
    );
  }

  bool get isDeposit => amount >= 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'reference': reference,
    };
  }
}

class BankLedgerReconciliationLine {
  final String transactionId;
  final DateTime date;
  final String account;
  final String description;
  final String reference;
  final TransactionType type;
  final double amount;

  const BankLedgerReconciliationLine({
    required this.transactionId,
    required this.date,
    required this.account,
    required this.description,
    required this.reference,
    required this.type,
    required this.amount,
  });

  factory BankLedgerReconciliationLine.fromTransaction(
    LedgerTransaction transaction,
  ) {
    return BankLedgerReconciliationLine(
      transactionId: transaction.id,
      date: transaction.date,
      account: transaction.account,
      description: transaction.description,
      reference: transaction.reference,
      type: transaction.type,
      amount: transaction.amount,
    );
  }

  double get signedAmount {
    return type == TransactionType.debit ? amount : -amount;
  }
}

class BankReconciliationMatch {
  final BankStatementLine statementLine;
  final BankLedgerReconciliationLine ledgerLine;
  final BankReconciliationMatchType matchType;
  final int dateDifferenceDays;
  final double amountVariance;

  const BankReconciliationMatch({
    required this.statementLine,
    required this.ledgerLine,
    required this.matchType,
    required this.dateDifferenceDays,
    required this.amountVariance,
  });
}

class BankReconciliation {
  final double tolerance;
  final List<BankStatementLine> statementLines;
  final List<BankLedgerReconciliationLine> ledgerLines;
  final List<BankReconciliationMatch> matches;
  final List<BankStatementLine> unmatchedStatementLines;
  final List<BankLedgerReconciliationLine> unmatchedLedgerLines;

  const BankReconciliation({
    required this.statementLines,
    required this.ledgerLines,
    required this.matches,
    required this.unmatchedStatementLines,
    required this.unmatchedLedgerLines,
    this.tolerance = 0.01,
  });

  bool get hasStatementEvidence => statementLines.isNotEmpty;

  double get statementMovement {
    return statementLines.fold(0.0, (sum, line) => sum + line.amount);
  }

  double get ledgerMovement {
    return ledgerLines.fold(0.0, (sum, line) => sum + line.signedAmount);
  }

  double get variance => statementMovement - ledgerMovement;

  int get unmatchedCount {
    return unmatchedStatementLines.length + unmatchedLedgerLines.length;
  }

  bool get hasUnmatchedItems => unmatchedCount > 0;

  bool get isBalanced {
    return hasStatementEvidence &&
        variance.abs() <= tolerance &&
        !hasUnmatchedItems;
  }

  bool get blocksClose {
    return hasStatementEvidence && !isBalanced;
  }
}
