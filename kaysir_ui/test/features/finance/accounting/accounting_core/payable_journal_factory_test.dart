import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/payable_posting_accounts.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/payable_journal_factory.dart';

void main() {
  group('PayableJournalFactory', () {
    const accounts = PayablePostingAccounts(
      cash: AccountingAccount(
        id: 'cash',
        code: '1000',
        name: 'Cash',
        type: AccountingAccountType.asset,
      ),
      accountsPayable: AccountingAccount(
        id: 'ap',
        code: '2000',
        name: 'Accounts Payable',
        type: AccountingAccountType.liability,
      ),
      defaultExpense: AccountingAccount(
        id: 'expense',
        code: '5000',
        name: 'Rent Expense',
        type: AccountingAccountType.expense,
      ),
    );
    const utilitiesExpense = AccountingAccount(
      id: 'utilities',
      code: '5100',
      name: 'Utilities Expense',
      type: AccountingAccountType.expense,
    );
    final chart = [
      accounts.cash,
      accounts.accountsPayable,
      accounts.defaultExpense,
      utilitiesExpense,
    ];

    test('creates a balanced bill-received journal', () {
      const factory = PayableJournalFactory();

      final draft = factory.billReceived(
        billId: 'BILL-001',
        billDate: DateTime(2026, 2, 1),
        amount: 900,
        description: 'Office rent',
        accounts: accounts,
      );

      expect(draft.source, JournalSource.payableBill);
      expect(draft.debitTotal, 900);
      expect(draft.creditTotal, 900);
      expect(draft.lines.first.accountId, 'expense');
      expect(draft.lines.first.side, JournalSide.debit);
      expect(draft.lines.last.accountId, 'ap');
      expect(draft.lines.last.side, JournalSide.credit);
    });

    test('uses a bill-specific expense account when provided', () {
      const factory = PayableJournalFactory();

      final draft = factory.billReceived(
        billId: 'BILL-UTIL-001',
        billDate: DateTime(2026, 2, 1),
        amount: 240,
        description: 'Power bill',
        accounts: accounts,
        expenseAccount: utilitiesExpense,
      );

      expect(draft.lines.first.accountId, 'utilities');
      expect(draft.lines.first.accountName, 'Utilities Expense');
      expect(draft.lines.first.side, JournalSide.debit);
      expect(draft.lines.last.accountId, 'ap');
    });

    test(
      'creates a bill payment journal that posts through ledger service',
      () {
        const factory = PayableJournalFactory();
        final postingService = LedgerPostingService(nextId: () => 'posting-1');

        final draft = factory.billPayment(
          billId: 'BILL-001',
          paymentId: 'PAY-AP-001',
          paymentDate: DateTime(2026, 2, 5),
          amount: 500,
          accounts: accounts,
        );
        final posting = postingService.post(draft, chart);

        expect(draft.source, JournalSource.payablePayment);
        expect(posting.debitTotal, 500);
        expect(posting.creditTotal, 500);
        expect(posting.lines.first.accountId, 'ap');
        expect(posting.lines.last.accountId, 'cash');
      },
    );

    test('rejects zero-value payable events', () {
      const factory = PayableJournalFactory();

      expect(
        () => factory.billReceived(
          billId: 'BILL-002',
          billDate: DateTime(2026, 2, 1),
          amount: 0,
          description: 'No amount',
          accounts: accounts,
        ),
        throwsArgumentError,
      );
    });
  });
}
