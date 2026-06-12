import '../../models/ledger_trx.dart';
import '../models/accounting_account.dart';
import '../models/journal_entry.dart';
import '../models/ledger_posting.dart';

extension PostedLedgerTransactionAdapter on LedgerPosting {
  List<LedgerTransaction> toLedgerTransactions(
    List<AccountingAccount> chartOfAccounts,
  ) {
    final accountById = {
      for (final account in chartOfAccounts) account.id: account,
    };

    return [
      for (final line in lines)
        LedgerTransaction(
          id: line.id,
          date: entryDate,
          account: _accountLabel(line, accountById[line.accountId]),
          description: _lineDescription(line),
          type: line.side.toTransactionType(),
          amount: line.amount,
          reference: reference,
          category: source.ledgerCategory,
          isSystemGenerated: true,
          journalId: journalId,
        ),
    ];
  }

  String _lineDescription(LedgerPostingLine line) {
    final memo = line.memo?.trim();
    if (memo == null || memo.isEmpty) {
      return description;
    }
    return '$description - $memo';
  }
}

extension JournalSideTransactionTypeAdapter on JournalSide {
  TransactionType toTransactionType() {
    switch (this) {
      case JournalSide.debit:
        return TransactionType.debit;
      case JournalSide.credit:
        return TransactionType.credit;
    }
  }
}

extension JournalSourceLedgerCategory on JournalSource {
  String get ledgerCategory {
    switch (this) {
      case JournalSource.manualAdjustment:
        return 'Posted Adjustment';
      case JournalSource.receivableInvoice:
        return 'AR Invoice';
      case JournalSource.receivablePayment:
        return 'AR Payment';
      case JournalSource.payableBill:
        return 'AP Bill';
      case JournalSource.payablePayment:
        return 'AP Payment';
      case JournalSource.periodClose:
        return 'Period Close';
    }
  }
}

String _accountLabel(
  LedgerPostingLine line,
  AccountingAccount? accountingAccount,
) {
  if (accountingAccount == null) {
    return line.accountName;
  }

  return '${accountingAccount.code} - ${accountingAccount.name}';
}
