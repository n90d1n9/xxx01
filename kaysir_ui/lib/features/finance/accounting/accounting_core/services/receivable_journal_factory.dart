import '../models/journal_entry.dart';
import '../models/receivable_posting_accounts.dart';

class ReceivableJournalFactory {
  const ReceivableJournalFactory();

  JournalDraft invoiceIssued({
    required String invoiceId,
    required DateTime issueDate,
    required double amount,
    required String description,
    required ReceivablePostingAccounts accounts,
  }) {
    _checkPositiveAmount(amount);
    final narrative =
        description.trim().isEmpty
            ? 'Customer invoice $invoiceId'
            : description.trim();

    return JournalDraft(
      id: 'ar-invoice-$invoiceId',
      date: issueDate,
      reference: invoiceId,
      description: narrative,
      source: JournalSource.receivableInvoice,
      lines: [
        JournalLineDraft(
          accountId: accounts.accountsReceivable.id,
          accountName: accounts.accountsReceivable.name,
          side: JournalSide.debit,
          amount: amount,
          memo: 'Recognize receivable',
        ),
        JournalLineDraft(
          accountId: accounts.salesRevenue.id,
          accountName: accounts.salesRevenue.name,
          side: JournalSide.credit,
          amount: amount,
          memo: narrative,
        ),
      ],
    );
  }

  JournalDraft paymentReceived({
    required String invoiceId,
    required String paymentId,
    required DateTime paymentDate,
    required double amount,
    required ReceivablePostingAccounts accounts,
  }) {
    _checkPositiveAmount(amount);

    return JournalDraft(
      id: 'ar-payment-$paymentId',
      date: paymentDate,
      reference: paymentId,
      description: 'Payment received for invoice $invoiceId',
      source: JournalSource.receivablePayment,
      lines: [
        JournalLineDraft(
          accountId: accounts.cash.id,
          accountName: accounts.cash.name,
          side: JournalSide.debit,
          amount: amount,
          memo: 'Cash receipt',
        ),
        JournalLineDraft(
          accountId: accounts.accountsReceivable.id,
          accountName: accounts.accountsReceivable.name,
          side: JournalSide.credit,
          amount: amount,
          memo: 'Settle invoice $invoiceId',
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
