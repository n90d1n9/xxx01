import '../models/ledger_trx.dart';
import '../models/trial_balance.dart';

/// Builds trial balance reports from ledger transactions.
class TrialBalanceService {
  const TrialBalanceService({this.tolerance = 0.01});

  final double tolerance;

  TrialBalanceReport buildReport({
    required Iterable<LedgerTransaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
    String query = '',
  }) {
    final periodTransactions = _filteredTransactions(
      transactions,
      startDate: startDate,
      endDate: endDate,
      query: query,
    );
    final openingTransactions = _openingTransactions(
      transactions,
      startDate: startDate,
      query: query,
    );
    final rows = _buildRows(
      openingTransactions: openingTransactions,
      periodTransactions: periodTransactions,
    );
    final totalDebits = rows.fold(0.0, (sum, row) => sum + row.debitBalance);
    final totalCredits = rows.fold(0.0, (sum, row) => sum + row.creditBalance);
    final variance = totalDebits - totalCredits;
    final isBalanced = variance.abs() < tolerance;
    final diagnostics = _buildDiagnostics(
      rows: rows,
      periodTransactions: periodTransactions,
      variance: variance,
      isBalanced: isBalanced,
    );

    return TrialBalanceReport(
      transactions: periodTransactions,
      rows: rows,
      summary: TrialBalanceSummary(
        accountCount: rows.length,
        totalDebits: totalDebits,
        totalCredits: totalCredits,
        variance: variance,
        isBalanced: isBalanced,
      ),
      closeChecks: [
        TrialBalanceCloseCheck(
          label: 'Debits equal credits',
          passed: isBalanced,
        ),
        TrialBalanceCloseCheck(
          label: 'References assigned',
          passed: periodTransactions.every(
            (transaction) => transaction.reference.trim().isNotEmpty,
          ),
        ),
        TrialBalanceCloseCheck(
          label: 'Categories mapped',
          passed: rows.every((row) => row.hasCategory),
        ),
        TrialBalanceCloseCheck(
          label: 'Activity loaded',
          passed: periodTransactions.isNotEmpty,
        ),
      ],
      diagnostics: diagnostics,
    );
  }

  List<LedgerTransaction> _filteredTransactions(
    Iterable<LedgerTransaction> transactions, {
    DateTime? startDate,
    DateTime? endDate,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return transactions.where((transaction) {
        final matchesStart =
            startDate == null || !transaction.date.isBefore(startDate);
        final matchesEnd =
            endDate == null ||
            transaction.date.isBefore(endDate.add(const Duration(days: 1)));
        final matchesQuery =
            normalizedQuery.isEmpty ||
            transaction.account.toLowerCase().contains(normalizedQuery) ||
            transaction.category.toLowerCase().contains(normalizedQuery) ||
            transaction.description.toLowerCase().contains(normalizedQuery) ||
            transaction.reference.toLowerCase().contains(normalizedQuery);

        return matchesStart && matchesEnd && matchesQuery;
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<LedgerTransaction> _openingTransactions(
    Iterable<LedgerTransaction> transactions, {
    DateTime? startDate,
    String query = '',
  }) {
    if (startDate == null) {
      return const [];
    }

    final normalizedQuery = query.trim().toLowerCase();
    return transactions.where((transaction) {
        final matchesPeriod = transaction.date.isBefore(startDate);
        final matchesQuery =
            normalizedQuery.isEmpty ||
            transaction.account.toLowerCase().contains(normalizedQuery) ||
            transaction.category.toLowerCase().contains(normalizedQuery) ||
            transaction.description.toLowerCase().contains(normalizedQuery) ||
            transaction.reference.toLowerCase().contains(normalizedQuery);

        return matchesPeriod && matchesQuery;
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<TrialBalanceRow> _buildRows({
    required List<LedgerTransaction> openingTransactions,
    required List<LedgerTransaction> periodTransactions,
  }) {
    final rows = <String, TrialBalanceRow>{};

    for (final transaction in openingTransactions) {
      rows[transaction.account] = _rowFor(
        rows,
        transaction,
      ).addOpening(transaction);
    }

    for (final transaction in periodTransactions) {
      rows[transaction.account] = _rowFor(
        rows,
        transaction,
      ).addMovement(transaction);
    }

    return rows.values.toList()..sort(
      (a, b) =>
          _accountSortKey(a.account).compareTo(_accountSortKey(b.account)),
    );
  }

  TrialBalanceRow _rowFor(
    Map<String, TrialBalanceRow> rows,
    LedgerTransaction transaction,
  ) {
    return rows[transaction.account] ??
        TrialBalanceRow(
          account: transaction.account,
          category: transaction.category,
        );
  }

  int _accountSortKey(String account) {
    final code = RegExp(r'^\d+').firstMatch(account)?.group(0);
    return int.tryParse(code ?? '') ?? 999999;
  }

  List<TrialBalanceDiagnostic> _buildDiagnostics({
    required List<TrialBalanceRow> rows,
    required List<LedgerTransaction> periodTransactions,
    required double variance,
    required bool isBalanced,
  }) {
    final diagnostics = <TrialBalanceDiagnostic>[];
    if (!isBalanced) {
      final varianceAccounts = [...rows]..sort(
        (a, b) => b.closingBalance.abs().compareTo(a.closingBalance.abs()),
      );
      diagnostics.add(
        TrialBalanceDiagnostic(
          id: 'trial-balance-variance',
          title: 'Trial balance variance',
          message:
              'Closing debit and credit balances do not tie. Review unmatched or one-sided journals before close.',
          severity: TrialBalanceDiagnosticSeverity.blocker,
          amount: variance.abs(),
          affectedAccounts: _uniqueLimited(
            varianceAccounts
                .where((row) => row.closingBalance.abs() >= tolerance)
                .map((row) => row.account),
          ),
        ),
      );
    }

    final missingReferenceTransactions =
        periodTransactions
            .where((transaction) => transaction.reference.trim().isEmpty)
            .toList();
    final missingReferenceCount = missingReferenceTransactions.length;
    if (missingReferenceCount > 0) {
      diagnostics.add(
        TrialBalanceDiagnostic(
          id: 'missing-references',
          title: 'Missing references',
          message:
              '$missingReferenceCount ledger row(s) need source references before close evidence is complete.',
          severity: TrialBalanceDiagnosticSeverity.warning,
          count: missingReferenceCount,
          affectedAccounts: _uniqueLimited(
            missingReferenceTransactions.map(
              (transaction) => transaction.account,
            ),
          ),
          affectedTransactionIds: _uniqueLimited(
            missingReferenceTransactions.map(_transactionTraceLabel),
          ),
        ),
      );
    }

    final unmappedAccounts = rows.where((row) => !row.hasCategory).toList();
    final unmappedAccountCount = unmappedAccounts.length;
    if (unmappedAccountCount > 0) {
      diagnostics.add(
        TrialBalanceDiagnostic(
          id: 'unmapped-categories',
          title: 'Unmapped categories',
          message:
              '$unmappedAccountCount account(s) need category mapping before financial statement tie-out.',
          severity: TrialBalanceDiagnosticSeverity.warning,
          count: unmappedAccountCount,
          affectedAccounts: _uniqueLimited(
            unmappedAccounts.map((row) => row.account),
          ),
        ),
      );
    }

    if (periodTransactions.isEmpty) {
      diagnostics.add(
        const TrialBalanceDiagnostic(
          id: 'no-period-activity',
          title: 'No period activity',
          message:
              'No ledger rows match the selected period and search filters.',
          severity: TrialBalanceDiagnosticSeverity.warning,
        ),
      );
    }

    return List.unmodifiable(diagnostics);
  }

  List<String> _uniqueLimited(Iterable<String> values, {int limit = 8}) {
    final seen = <String>{};
    final result = <String>[];

    for (final value in values) {
      final normalizedValue = value.trim();
      if (normalizedValue.isEmpty || seen.contains(normalizedValue)) {
        continue;
      }

      seen.add(normalizedValue);
      result.add(normalizedValue);
      if (result.length == limit) {
        break;
      }
    }

    return List.unmodifiable(result);
  }

  String _transactionTraceLabel(LedgerTransaction transaction) {
    final journalId = transaction.journalId?.trim();
    if (journalId != null && journalId.isNotEmpty) {
      return journalId;
    }

    return transaction.id;
  }
}
