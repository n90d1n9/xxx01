import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/models/receivable_posting_accounts.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../accounting_core/services/receivable_journal_factory.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class ReceivablePaymentPostingService {
  final ReceivableJournalFactory journalFactory;
  final LedgerPostingService postingService;
  final List<AccountingAccount> chartOfAccounts;
  final ReceivablePostingAccounts accounts;
  final double tolerance;

  const ReceivablePaymentPostingService({
    required this.journalFactory,
    required this.postingService,
    required this.chartOfAccounts,
    required this.accounts,
    this.tolerance = 0.01,
  });

  LedgerPosting postPayment({
    required Invoice invoice,
    required Payment payment,
  }) {
    if (payment.amount - invoice.remainingAmount > tolerance) {
      throw ArgumentError.value(
        payment.amount,
        'payment.amount',
        'Cannot exceed outstanding invoice balance',
      );
    }

    final draft = journalFactory.paymentReceived(
      invoiceId: invoice.id,
      paymentId: payment.id,
      paymentDate: payment.paymentDate ?? DateTime.now(),
      amount: payment.amount,
      accounts: accounts,
    );

    return postingService.post(draft, chartOfAccounts);
  }
}
