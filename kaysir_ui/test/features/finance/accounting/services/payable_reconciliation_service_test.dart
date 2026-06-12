import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/payable_reconciliation_service.dart';

void main() {
  group('PayableReconciliationService', () {
    const service = PayableReconciliationService();
    const accountsPayable = AccountingAccount(
      id: 'ap',
      code: '2000',
      name: 'Accounts Payable',
      type: AccountingAccountType.liability,
    );

    test('reconciles open payable bills to AP ledger balance', () {
      final reconciliation = service.reconcile(
        bills: [
          _bill(id: 'bill-1', amount: 1000),
          _bill(
            id: 'bill-2',
            amount: 500,
            payments: [Payment(id: 'pay-1', invoiceId: 'bill-2', amount: 200)],
          ),
        ],
        postings: [
          _posting('posting-1', JournalSide.credit, 1000),
          _posting('posting-2', JournalSide.credit, 500),
          _posting('posting-3', JournalSide.debit, 200),
        ],
        accountsPayable: accountsPayable,
      );

      expect(reconciliation.subledgerBalance, 1300);
      expect(reconciliation.ledgerBalance, 1300);
      expect(reconciliation.variance, 0);
      expect(reconciliation.isBalanced, isTrue);
      expect(reconciliation.subledgerLines.map((line) => line.reference), [
        'BILL-bill-1',
        'BILL-bill-2',
      ]);
      expect(
        reconciliation.subledgerLines.map((line) => line.remainingAmount),
        [1000, 300],
      );
      expect(reconciliation.ledgerLines.map((line) => line.balanceImpact), [
        1000,
        500,
        -200,
      ]);
    });

    test('reports variance when AP ledger is missing activity', () {
      final reconciliation = service.reconcile(
        bills: [_bill(id: 'bill-1', amount: 750)],
        postings: const [],
        accountsPayable: accountsPayable,
      );

      expect(reconciliation.subledgerBalance, 750);
      expect(reconciliation.ledgerBalance, 0);
      expect(reconciliation.variance, 750);
      expect(reconciliation.isBalanced, isFalse);
    });
  });
}

Invoice _bill({
  required String id,
  required double amount,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: 'vendor-1',
    invoiceNumber: 'BILL-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 2, 1),
    amount: amount,
    payments: payments,
  );
}

LedgerPosting _posting(String id, JournalSide side, double amount) {
  return LedgerPosting(
    id: id,
    journalId: 'journal-$id',
    entryDate: DateTime(2026, 1, 1),
    postedAt: DateTime(2026, 1, 1),
    reference: id,
    description: id,
    source: JournalSource.payableBill,
    lines: [
      LedgerPostingLine(
        id: '$id-line',
        accountId: 'ap',
        accountName: 'Accounts Payable',
        side: side,
        amount: amount,
      ),
    ],
  );
}
