import '../accounting_core/models/accounting_account.dart';
import '../accounting_core/models/ledger_posting.dart';
import '../accounting_core/models/payable_posting_accounts.dart';
import '../accounting_core/services/ledger_posting_service.dart';
import '../accounting_core/services/payable_journal_factory.dart';
import '../models/invoice.dart';
import '../models/payment.dart';

class PayablePostingService {
  final PayableJournalFactory journalFactory;
  final LedgerPostingService postingService;
  final List<AccountingAccount> chartOfAccounts;
  final PayablePostingAccounts accounts;
  final double tolerance;

  const PayablePostingService({
    required this.journalFactory,
    required this.postingService,
    required this.chartOfAccounts,
    required this.accounts,
    this.tolerance = 0.01,
  });

  LedgerPosting postBill(Invoice bill, {AccountingAccount? expenseAccount}) {
    final reference = bill.invoiceNumber ?? bill.id;
    final billExpenseAccount =
        expenseAccount ?? _configuredExpenseAccount(bill.expenseAccountId);
    final draft = journalFactory.billReceived(
      billId: reference,
      billDate: bill.invoiceDate ?? DateTime.now(),
      amount: bill.amount,
      description: bill.description,
      accounts: accounts,
      expenseAccount: billExpenseAccount,
    );

    return postingService.post(draft, chartOfAccounts);
  }

  LedgerPosting postPayment({required Invoice bill, required Payment payment}) {
    if (payment.amount - bill.remainingAmount > tolerance) {
      throw ArgumentError.value(
        payment.amount,
        'payment.amount',
        'Cannot exceed outstanding bill balance',
      );
    }

    final draft = journalFactory.billPayment(
      billId: bill.invoiceNumber ?? bill.id,
      paymentId: payment.id,
      paymentDate: payment.paymentDate ?? DateTime.now(),
      amount: payment.amount,
      accounts: accounts,
    );

    return postingService.post(draft, chartOfAccounts);
  }

  AccountingAccount? _configuredExpenseAccount(String? accountId) {
    if (accountId == null) {
      return null;
    }

    for (final account in chartOfAccounts) {
      if (account.id == accountId &&
          account.type == AccountingAccountType.expense) {
        return account;
      }
    }

    throw StateError('Expense account $accountId is not configured');
  }
}
