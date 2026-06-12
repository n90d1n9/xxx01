import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/receivable_posting_accounts.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/receivable_journal_factory.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/receivable_payment_posting_service.dart';

void main() {
  group('ReceivablePaymentPostingService', () {
    const accounts = ReceivablePostingAccounts(
      accountsReceivable: AccountingAccount(
        id: 'ar',
        code: '1100',
        name: 'Accounts Receivable',
        type: AccountingAccountType.asset,
      ),
      salesRevenue: AccountingAccount(
        id: 'revenue',
        code: '4000',
        name: 'Sales Revenue',
        type: AccountingAccountType.revenue,
      ),
      cash: AccountingAccount(
        id: 'cash',
        code: '1000',
        name: 'Cash',
        type: AccountingAccountType.asset,
      ),
    );

    final service = ReceivablePaymentPostingService(
      journalFactory: const ReceivableJournalFactory(),
      postingService: LedgerPostingService(nextId: () => 'posting-1'),
      chartOfAccounts: [
        accounts.accountsReceivable,
        accounts.salesRevenue,
        accounts.cash,
      ],
      accounts: accounts,
    );

    test('posts payment as cash debit and receivables credit', () {
      final posting = service.postPayment(
        invoice: Invoice(id: 'INV-001', amount: 1000),
        payment: Payment(
          id: 'PAY-001',
          invoiceId: 'INV-001',
          amount: 400,
          paymentDate: DateTime(2026, 1, 8),
        ),
      );

      expect(posting.source, JournalSource.receivablePayment);
      expect(posting.debitTotal, 400);
      expect(posting.creditTotal, 400);
      expect(posting.lines.first.accountId, 'cash');
      expect(posting.lines.last.accountId, 'ar');
    });

    test('rejects overpayments before posting', () {
      expect(
        () => service.postPayment(
          invoice: Invoice(id: 'INV-002', amount: 1000),
          payment: Payment(id: 'PAY-002', invoiceId: 'INV-002', amount: 1001),
        ),
        throwsArgumentError,
      );
    });
  });
}
