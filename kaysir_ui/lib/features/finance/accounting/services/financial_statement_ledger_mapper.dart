import '../accounting_core/models/accounting_account.dart';
import '../models/financial_entry.dart';
import '../models/ledger_trx.dart';

class FinancialStatementLedgerMapper {
  const FinancialStatementLedgerMapper();

  List<FinancialEntry> toFinancialEntries(
    List<LedgerTransaction> transactions,
    List<AccountingAccount> chartOfAccounts,
  ) {
    final entries = <FinancialEntry>[];
    for (final transaction in transactions) {
      if (transaction.category == 'Period Close') {
        continue;
      }
      final account = _accountFor(transaction, chartOfAccounts);
      if (account == null) {
        continue;
      }

      entries.add(
        FinancialEntry(
          name: account.name,
          amount: _normalSignedAmount(transaction, account),
          date: transaction.date,
          category: '${account.code} - ${account.name}',
          type: account.type.statementType,
          sourceCategory: transaction.category,
        ),
      );
    }
    return entries;
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
}

extension FinancialStatementAccountType on AccountingAccountType {
  String get statementType {
    switch (this) {
      case AccountingAccountType.asset:
        return 'asset';
      case AccountingAccountType.liability:
        return 'liability';
      case AccountingAccountType.equity:
        return 'equity';
      case AccountingAccountType.revenue:
        return 'income';
      case AccountingAccountType.expense:
        return 'expense';
    }
  }
}
