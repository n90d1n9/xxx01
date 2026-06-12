import '../models/accounting_account.dart';
import '../models/journal_entry.dart';
import '../models/payable_posting_accounts.dart';

class PayableJournalFactory {
  const PayableJournalFactory();

  JournalDraft billReceived({
    required String billId,
    required DateTime billDate,
    required double amount,
    required String description,
    required PayablePostingAccounts accounts,
    AccountingAccount? expenseAccount,
  }) {
    _checkPositiveAmount(amount);
    final narrative =
        description.trim().isEmpty ? 'Vendor bill $billId' : description.trim();
    final billExpenseAccount = expenseAccount ?? accounts.defaultExpense;

    return JournalDraft(
      id: 'ap-bill-$billId',
      date: billDate,
      reference: billId,
      description: narrative,
      source: JournalSource.payableBill,
      lines: [
        JournalLineDraft(
          accountId: billExpenseAccount.id,
          accountName: billExpenseAccount.name,
          side: JournalSide.debit,
          amount: amount,
          memo: narrative,
        ),
        JournalLineDraft(
          accountId: accounts.accountsPayable.id,
          accountName: accounts.accountsPayable.name,
          side: JournalSide.credit,
          amount: amount,
          memo: 'Recognize payable',
        ),
      ],
    );
  }

  JournalDraft billPayment({
    required String billId,
    required String paymentId,
    required DateTime paymentDate,
    required double amount,
    required PayablePostingAccounts accounts,
  }) {
    _checkPositiveAmount(amount);

    return JournalDraft(
      id: 'ap-payment-$paymentId',
      date: paymentDate,
      reference: paymentId,
      description: 'Payment made for bill $billId',
      source: JournalSource.payablePayment,
      lines: [
        JournalLineDraft(
          accountId: accounts.accountsPayable.id,
          accountName: accounts.accountsPayable.name,
          side: JournalSide.debit,
          amount: amount,
          memo: 'Settle bill $billId',
        ),
        JournalLineDraft(
          accountId: accounts.cash.id,
          accountName: accounts.cash.name,
          side: JournalSide.credit,
          amount: amount,
          memo: 'Cash disbursement',
        ),
      ],
    );
  }

  void _checkPositiveAmount(double amount) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero');
    }
  }
}
