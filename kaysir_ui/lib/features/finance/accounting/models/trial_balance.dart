import 'ledger_trx.dart';

/// Debit or credit presentation side for a trial balance account row.
enum TrialBalanceNormalSide { debit, credit }

/// Severity used for trial balance diagnostics.
enum TrialBalanceDiagnosticSeverity { blocker, warning }

/// One account row in a generated trial balance.
class TrialBalanceRow {
  const TrialBalanceRow({
    required this.account,
    required this.category,
    this.openingBalance = 0,
    this.debitMovement = 0,
    this.creditMovement = 0,
    this.entryCount = 0,
  });

  final String account;
  final String category;
  final double openingBalance;
  final double debitMovement;
  final double creditMovement;
  final int entryCount;

  double get closingBalance => openingBalance + debitMovement - creditMovement;

  double get debitBalance => closingBalance > 0 ? closingBalance : 0;

  double get creditBalance => closingBalance < 0 ? closingBalance.abs() : 0;

  TrialBalanceNormalSide get normalSide =>
      closingBalance >= 0
          ? TrialBalanceNormalSide.debit
          : TrialBalanceNormalSide.credit;

  String get normalSideLabel =>
      normalSide == TrialBalanceNormalSide.debit ? 'Debit' : 'Credit';

  bool get hasCategory => category.trim().isNotEmpty;

  TrialBalanceRow addOpening(LedgerTransaction transaction) {
    final signedAmount =
        transaction.type == TransactionType.debit
            ? transaction.amount
            : -transaction.amount;

    return TrialBalanceRow(
      account: account,
      category: category,
      openingBalance: openingBalance + signedAmount,
      debitMovement: debitMovement,
      creditMovement: creditMovement,
      entryCount: entryCount,
    );
  }

  TrialBalanceRow addMovement(LedgerTransaction transaction) {
    return TrialBalanceRow(
      account: account,
      category: category,
      openingBalance: openingBalance,
      debitMovement:
          debitMovement +
          (transaction.type == TransactionType.debit ? transaction.amount : 0),
      creditMovement:
          creditMovement +
          (transaction.type == TransactionType.credit ? transaction.amount : 0),
      entryCount: entryCount + 1,
    );
  }
}

/// Aggregate totals and balance status for a generated trial balance.
class TrialBalanceSummary {
  const TrialBalanceSummary({
    required this.accountCount,
    required this.totalDebits,
    required this.totalCredits,
    required this.variance,
    required this.isBalanced,
  });

  final int accountCount;
  final double totalDebits;
  final double totalCredits;
  final double variance;
  final bool isBalanced;
}

/// One close-readiness control check derived from the trial balance.
class TrialBalanceCloseCheck {
  const TrialBalanceCloseCheck({required this.label, required this.passed});

  final String label;
  final bool passed;
}

/// One actionable issue or warning found in a trial balance report.
class TrialBalanceDiagnostic {
  const TrialBalanceDiagnostic({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.amount,
    this.count,
    this.affectedAccounts = const [],
    this.affectedTransactionIds = const [],
  });

  final String id;
  final String title;
  final String message;
  final TrialBalanceDiagnosticSeverity severity;
  final double? amount;
  final int? count;
  final List<String> affectedAccounts;
  final List<String> affectedTransactionIds;

  bool get isBlocker => severity == TrialBalanceDiagnosticSeverity.blocker;

  bool get hasDetails =>
      affectedAccounts.isNotEmpty || affectedTransactionIds.isNotEmpty;
}

/// Complete trial balance result used by screens, close controls, and exports.
class TrialBalanceReport {
  const TrialBalanceReport({
    required this.transactions,
    required this.rows,
    required this.summary,
    required this.closeChecks,
    required this.diagnostics,
  });

  final List<LedgerTransaction> transactions;
  final List<TrialBalanceRow> rows;
  final TrialBalanceSummary summary;
  final List<TrialBalanceCloseCheck> closeChecks;
  final List<TrialBalanceDiagnostic> diagnostics;

  bool get isReadyForClose => closeChecks.every((check) => check.passed);

  bool get hasDiagnostics => diagnostics.isNotEmpty;

  int get blockerCount =>
      diagnostics.where((diagnostic) => diagnostic.isBlocker).length;

  int get warningCount => diagnostics.length - blockerCount;
}
