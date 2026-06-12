import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/receivable_posting_accounts.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/receivable_journal_factory.dart';

void main() {
  group('ReceivableJournalFactory', () {
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
    final chart = [
      accounts.accountsReceivable,
      accounts.salesRevenue,
      accounts.cash,
    ];

    test('creates a balanced invoice-issued journal', () {
      const factory = ReceivableJournalFactory();

      final draft = factory.invoiceIssued(
        invoiceId: 'INV-001',
        issueDate: DateTime(2026, 1, 1),
        amount: 1200,
        description: 'Consulting services',
        accounts: accounts,
      );

      expect(draft.source, JournalSource.receivableInvoice);
      expect(draft.debitTotal, 1200);
      expect(draft.creditTotal, 1200);
      expect(draft.lines.first.accountId, 'ar');
      expect(draft.lines.first.side, JournalSide.debit);
      expect(draft.lines.last.accountId, 'revenue');
      expect(draft.lines.last.side, JournalSide.credit);
    });

    test('creates a payment journal that posts through ledger service', () {
      const factory = ReceivableJournalFactory();
      final postingService = LedgerPostingService(nextId: () => 'posting-1');

      final draft = factory.paymentReceived(
        invoiceId: 'INV-001',
        paymentId: 'PAY-001',
        paymentDate: DateTime(2026, 1, 5),
        amount: 750,
        accounts: accounts,
      );
      final posting = postingService.post(draft, chart);

      expect(draft.source, JournalSource.receivablePayment);
      expect(posting.debitTotal, 750);
      expect(posting.creditTotal, 750);
      expect(posting.lines.first.accountId, 'cash');
      expect(posting.lines.last.accountId, 'ar');
    });

    test('rejects zero-value receivable events', () {
      const factory = ReceivableJournalFactory();

      expect(
        () => factory.invoiceIssued(
          invoiceId: 'INV-002',
          issueDate: DateTime(2026, 1, 1),
          amount: 0,
          description: 'No amount',
          accounts: accounts,
        ),
        throwsArgumentError,
      );
    });
  });
}
