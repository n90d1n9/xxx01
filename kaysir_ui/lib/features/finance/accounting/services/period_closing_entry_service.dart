import 'package:intl/intl.dart';

import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/journal_entry.dart';
import '../models/ledger_trx.dart';
import '../models/period_closing_entry.dart';

class PeriodClosingEntryService {
  final double tolerance;

  const PeriodClosingEntryService({this.tolerance = 0.01});

  PeriodClosingEntryPreview preview({
    required String periodLabel,
    required DateTime closingDate,
    required List<LedgerTransaction> transactions,
    required List<AccountingAccount> chartOfAccounts,
    DateTime? periodStart,
    DateTime? periodEnd,
    String retainedEarningsCode = '3000',
  }) {
    final retainedEarnings = _retainedEarningsAccount(
      chartOfAccounts,
      retainedEarningsCode,
    );
    final accountBalances = _nominalAccountBalances(
      transactions: transactions,
      chartOfAccounts: chartOfAccounts,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
    final revenueBalances = _balancesForType(
      accountBalances,
      AccountingAccountType.revenue,
    );
    final expenseBalances = _balancesForType(
      accountBalances,
      AccountingAccountType.expense,
    );
    final warnings = <String>[
      if (retainedEarnings == null)
        'Retained earnings account $retainedEarningsCode is not configured.',
      if (revenueBalances.isEmpty && expenseBalances.isEmpty)
        'No revenue or expense balances found for $periodLabel.',
    ];

    return PeriodClosingEntryPreview(
      periodLabel: periodLabel,
      closingDate: closingDate,
      retainedEarningsAccount: retainedEarnings,
      revenueBalances: revenueBalances,
      expenseBalances: expenseBalances,
      draft:
          warnings.isEmpty
              ? _draft(
                periodLabel: periodLabel,
                closingDate: closingDate,
                retainedEarnings: retainedEarnings!,
                revenueBalances: revenueBalances,
                expenseBalances: expenseBalances,
              )
              : null,
      warnings: warnings,
      tolerance: tolerance,
    );
  }

  AccountingAccount? _retainedEarningsAccount(
    List<AccountingAccount> chartOfAccounts,
    String retainedEarningsCode,
  ) {
    for (final account in chartOfAccounts) {
      if (account.code == retainedEarningsCode &&
          account.type == AccountingAccountType.equity &&
          account.isActive) {
        return account;
      }
    }

    for (final account in chartOfAccounts) {
      final name = account.name.toLowerCase();
      if (account.type == AccountingAccountType.equity &&
          account.isActive &&
          (name.contains('retained earnings') || name.contains('saldo laba'))) {
        return account;
      }
    }

    return null;
  }

  Map<String, PeriodClosingAccountBalance> _nominalAccountBalances({
    required List<LedgerTransaction> transactions,
    required List<AccountingAccount> chartOfAccounts,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    final balances = <String, PeriodClosingAccountBalance>{};
    for (final transaction in transactions) {
      if (transaction.category == 'Period Close') {
        continue;
      }
      if (!_isInPeriod(transaction.date, periodStart, periodEnd)) {
        continue;
      }

      final account = _accountFor(transaction, chartOfAccounts);
      if (account == null || !_isNominal(account)) {
        continue;
      }

      final signedAmount = _normalSignedAmount(transaction, account);
      final nextBalance = (balances[account.id]?.balance ?? 0) + signedAmount;
      if (nextBalance.abs() <= tolerance) {
        balances.remove(account.id);
      } else {
        balances[account.id] = PeriodClosingAccountBalance(
          account: account,
          balance: nextBalance,
        );
      }
    }
    return balances;
  }

  List<PeriodClosingAccountBalance> _balancesForType(
    Map<String, PeriodClosingAccountBalance> balances,
    AccountingAccountType type,
  ) {
    return balances.values.where((item) => item.account.type == type).toList()
      ..sort((a, b) => a.account.code.compareTo(b.account.code));
  }

  JournalDraft _draft({
    required String periodLabel,
    required DateTime closingDate,
    required AccountingAccount retainedEarnings,
    required List<PeriodClosingAccountBalance> revenueBalances,
    required List<PeriodClosingAccountBalance> expenseBalances,
  }) {
    final lines = <JournalLineDraft>[
      for (final balance in revenueBalances)
        _closingLine(
          balance,
          normalBalanceSide: JournalSide.credit,
          memo: 'Close revenue balance',
        ),
      for (final balance in expenseBalances)
        _closingLine(
          balance,
          normalBalanceSide: JournalSide.debit,
          memo: 'Close expense balance',
        ),
    ];
    final netIncome =
        revenueBalances.fold(0.0, (sum, item) => sum + item.balance) -
        expenseBalances.fold(0.0, (sum, item) => sum + item.balance);

    if (netIncome.abs() > tolerance) {
      lines.add(
        JournalLineDraft(
          accountId: retainedEarnings.id,
          accountName: _accountLabel(retainedEarnings),
          side: netIncome > 0 ? JournalSide.credit : JournalSide.debit,
          amount: netIncome.abs(),
          memo: netIncome > 0 ? 'Transfer net income' : 'Transfer net loss',
        ),
      );
    }

    final dateKey = DateFormat('yyyyMMdd').format(closingDate);
    return JournalDraft(
      id: 'period-close-$dateKey',
      date: closingDate,
      reference: 'CLOSE-$dateKey',
      description: 'Close nominal accounts for $periodLabel',
      source: JournalSource.periodClose,
      lines: lines,
    );
  }

  JournalLineDraft _closingLine(
    PeriodClosingAccountBalance balance, {
    required JournalSide normalBalanceSide,
    required String memo,
  }) {
    final account = balance.account;
    final side =
        balance.balance >= 0 ? _opposite(normalBalanceSide) : normalBalanceSide;
    return JournalLineDraft(
      accountId: account.id,
      accountName: _accountLabel(account),
      side: side,
      amount: balance.balance.abs(),
      memo: memo,
    );
  }

  JournalSide _opposite(JournalSide side) {
    return side == JournalSide.debit ? JournalSide.credit : JournalSide.debit;
  }

  bool _isInPeriod(DateTime date, DateTime? start, DateTime? end) {
    final startsAfter = start == null || !date.isBefore(start);
    final endsBefore =
        end == null || date.isBefore(end.add(const Duration(days: 1)));
    return startsAfter && endsBefore;
  }

  bool _isNominal(AccountingAccount account) {
    return account.type == AccountingAccountType.revenue ||
        account.type == AccountingAccountType.expense;
  }

  AccountingAccount? _accountFor(
    LedgerTransaction transaction,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final accountCode = RegExp(
      r'^\s*(\d+)',
    ).firstMatch(transaction.account)?.group(1);
    if (accountCode != null) {
      for (final account in chartOfAccounts) {
        if (account.code == accountCode) {
          return account;
        }
      }
    }

    final accountName = transaction.account.toLowerCase();
    for (final account in chartOfAccounts) {
      if (accountName == account.name.toLowerCase() ||
          accountName.endsWith(' - ${account.name.toLowerCase()}')) {
        return account;
      }
    }

    return null;
  }

  double _normalSignedAmount(
    LedgerTransaction transaction,
    AccountingAccount account,
  ) {
    final isDebit = transaction.type == TransactionType.debit;
    final debitIncreases = account.normalBalance == NormalBalance.debit;
    return isDebit == debitIncreases ? transaction.amount : -transaction.amount;
  }

  String _accountLabel(AccountingAccount account) {
    return '${account.code} - ${account.name}';
  }
}
