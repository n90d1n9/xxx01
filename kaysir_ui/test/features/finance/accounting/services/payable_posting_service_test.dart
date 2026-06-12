import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/payable_posting_accounts.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/payable_journal_factory.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/payable_posting_service.dart';

void main() {
  group('PayablePostingService', () {
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

    final service = PayablePostingService(
      journalFactory: const PayableJournalFactory(),
      postingService: LedgerPostingService(nextId: () => 'posting-1'),
      chartOfAccounts: [
        accounts.cash,
        accounts.accountsPayable,
        accounts.defaultExpense,
        utilitiesExpense,
      ],
      accounts: accounts,
    );

    test('posts bills as expense debit and payables credit', () {
      final posting = service.postBill(
        Invoice(
          id: 'bill-1',
          invoiceNumber: 'BILL-001',
          invoiceDate: DateTime(2026, 2, 1),
          amount: 1200,
          description: 'Office rent',
        ),
      );

      expect(posting.source, JournalSource.payableBill);
      expect(posting.debitTotal, 1200);
      expect(posting.creditTotal, 1200);
      expect(posting.lines.first.accountId, 'expense');
      expect(posting.lines.last.accountId, 'ap');
    });

    test('posts bills to the invoice expense account', () {
      final posting = service.postBill(
        Invoice(
          id: 'bill-utilities',
          invoiceNumber: 'BILL-UTIL-001',
          invoiceDate: DateTime(2026, 2, 1),
          amount: 420,
          description: 'Power bill',
          expenseAccountId: utilitiesExpense.id,
        ),
      );

      expect(posting.source, JournalSource.payableBill);
      expect(posting.debitTotal, 420);
      expect(posting.creditTotal, 420);
      expect(posting.lines.first.accountId, 'utilities');
      expect(posting.lines.first.accountName, 'Utilities Expense');
      expect(posting.lines.last.accountId, 'ap');
    });

    test('posts bill payments as payables debit and cash credit', () {
      final posting = service.postPayment(
        bill: Invoice(id: 'bill-2', invoiceNumber: 'BILL-002', amount: 800),
        payment: Payment(
          id: 'PAY-AP-002',
          invoiceId: 'bill-2',
          amount: 800,
          paymentDate: DateTime(2026, 2, 8),
        ),
      );

      expect(posting.source, JournalSource.payablePayment);
      expect(posting.debitTotal, 800);
      expect(posting.creditTotal, 800);
      expect(posting.lines.first.accountId, 'ap');
      expect(posting.lines.last.accountId, 'cash');
    });

    test('rejects overpayments before posting', () {
      expect(
        () => service.postPayment(
          bill: Invoice(id: 'bill-3', amount: 300),
          payment: Payment(id: 'PAY-AP-003', invoiceId: 'bill-3', amount: 301),
        ),
        throwsArgumentError,
      );
    });
  });
}
