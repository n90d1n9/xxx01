import '../models/bank_reconciliation.dart';
import '../models/ledger_trx.dart';

typedef BankLedgerMatcher = bool Function(LedgerTransaction transaction);

class BankReconciliationService {
  const BankReconciliationService();

  BankReconciliation reconcile({
    required Iterable<BankStatementLine> statementLines,
    required Iterable<LedgerTransaction> ledgerTransactions,
    BankLedgerMatcher? isBankLedgerTransaction,
    DateTime? periodStart,
    DateTime? periodEnd,
    double tolerance = 0.01,
    int dateToleranceDays = 3,
  }) {
    final statements =
        statementLines
            .where((line) => _isInsidePeriod(line.date, periodStart, periodEnd))
            .toList()
          ..sort(_compareStatementLines);
    final ledgerLines =
        ledgerTransactions
            .where(
              (transaction) =>
                  _isInsidePeriod(transaction.date, periodStart, periodEnd),
            )
            .where(isBankLedgerTransaction ?? defaultBankLedgerMatcher)
            .map(BankLedgerReconciliationLine.fromTransaction)
            .toList()
          ..sort(_compareLedgerLines);
    final unmatchedLedgerLines = [...ledgerLines];
    final unmatchedStatementLines = <BankStatementLine>[];
    final matches = <BankReconciliationMatch>[];

    for (final statementLine in statements) {
      final referenceMatch = _takeMatch(
        statementLine: statementLine,
        candidates: unmatchedLedgerLines,
        tolerance: tolerance,
        dateToleranceDays: dateToleranceDays,
        matchType: BankReconciliationMatchType.reference,
      );
      final amountDateMatch =
          referenceMatch ??
          _takeMatch(
            statementLine: statementLine,
            candidates: unmatchedLedgerLines,
            tolerance: tolerance,
            dateToleranceDays: dateToleranceDays,
            matchType: BankReconciliationMatchType.amountAndDate,
          );

      if (amountDateMatch == null) {
        unmatchedStatementLines.add(statementLine);
        continue;
      }

      unmatchedLedgerLines.remove(amountDateMatch.ledgerLine);
      matches.add(amountDateMatch);
    }

    return BankReconciliation(
      statementLines: statements,
      ledgerLines: ledgerLines,
      matches: matches,
      unmatchedStatementLines: unmatchedStatementLines,
      unmatchedLedgerLines: unmatchedLedgerLines,
      tolerance: tolerance,
    );
  }

  bool defaultBankLedgerMatcher(LedgerTransaction transaction) {
    final account = transaction.account.toLowerCase();
    return account.contains('cash') ||
        account.contains('bank') ||
        account.contains('kas') ||
        account.contains('giro');
  }

  BankReconciliationMatch? _takeMatch({
    required BankStatementLine statementLine,
    required List<BankLedgerReconciliationLine> candidates,
    required double tolerance,
    required int dateToleranceDays,
    required BankReconciliationMatchType matchType,
  }) {
    BankReconciliationMatch? bestMatch;

    for (final ledgerLine in candidates) {
      final dateDifferenceDays = _dateDifferenceDays(
        statementLine.date,
        ledgerLine.date,
      );
      if (dateDifferenceDays > dateToleranceDays) {
        continue;
      }

      final amountVariance = statementLine.amount - ledgerLine.signedAmount;
      if (amountVariance.abs() > tolerance) {
        continue;
      }

      if (matchType == BankReconciliationMatchType.reference &&
          !_sameReference(statementLine.reference, ledgerLine.reference)) {
        continue;
      }

      final match = BankReconciliationMatch(
        statementLine: statementLine,
        ledgerLine: ledgerLine,
        matchType: matchType,
        dateDifferenceDays: dateDifferenceDays,
        amountVariance: amountVariance,
      );

      if (bestMatch == null ||
          match.dateDifferenceDays < bestMatch.dateDifferenceDays) {
        bestMatch = match;
      }
    }

    return bestMatch;
  }

  bool _sameReference(String? statementReference, String ledgerReference) {
    final statement = _normalizeReference(statementReference);
    final ledger = _normalizeReference(ledgerReference);
    return statement.isNotEmpty && statement == ledger;
  }

  String _normalizeReference(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  bool _isInsidePeriod(DateTime date, DateTime? start, DateTime? end) {
    final startsAfter = start == null || !date.isBefore(start);
    final endsBefore =
        end == null || date.isBefore(end.add(const Duration(days: 1)));
    return startsAfter && endsBefore;
  }

  int _dateDifferenceDays(DateTime a, DateTime b) {
    return a.difference(b).inDays.abs();
  }

  int _compareStatementLines(BankStatementLine a, BankStatementLine b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return a.id.compareTo(b.id);
  }

  int _compareLedgerLines(
    BankLedgerReconciliationLine a,
    BankLedgerReconciliationLine b,
  ) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return a.transactionId.compareTo(b.transactionId);
  }
}
