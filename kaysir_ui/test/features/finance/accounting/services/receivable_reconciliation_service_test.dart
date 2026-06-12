import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/models/receivable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/services/receivable_reconciliation_service.dart';

void main() {
  group('ReceivableReconciliationService', () {
    const service = ReceivableReconciliationService();
    const accountsReceivable = AccountingAccount(
      id: 'ar',
      code: '1100',
      name: 'Accounts Receivable',
      type: AccountingAccountType.asset,
    );

    test('reconciles open customer invoices to AR ledger balance', () {
      final reconciliation = service.reconcile(
        invoices: [
          _invoice(
            id: 'invoice-1',
            amount: 1000,
            dueDate: DateTime(2026, 1, 15),
          ),
          _invoice(
            id: 'invoice-2',
            amount: 500,
            dueDate: DateTime(2026, 2, 15),
            payments: [
              Payment(id: 'pay-1', invoiceId: 'invoice-2', amount: 200),
            ],
          ),
        ],
        postings: [
          _posting('posting-1', JournalSide.debit, 1000),
          _posting('posting-2', JournalSide.debit, 500),
          _posting('posting-3', JournalSide.credit, 200),
        ],
        accountsReceivable: accountsReceivable,
        asOf: DateTime(2026, 2, 20),
        customerNamesById: const {'customer-1': 'Acme Retail'},
      );

      expect(reconciliation.subledgerBalance, 1300);
      expect(reconciliation.ledgerBalance, 1300);
      expect(reconciliation.variance, 0);
      expect(reconciliation.isBalanced, isTrue);
      expect(reconciliation.overdueBalance, 1300);
      expect(reconciliation.oldestDaysPastDue, 36);
      expect(reconciliation.subledgerLines.map((line) => line.reference), [
        'INV-invoice-1',
        'INV-invoice-2',
      ]);
      expect(
        reconciliation.subledgerLines.map((line) => line.remainingAmount),
        [1000, 300],
      );
      expect(reconciliation.subledgerLines.first.customerName, 'Acme Retail');
      expect(reconciliation.ledgerLines.map((line) => line.balanceImpact), [
        1000,
        500,
        -200,
      ]);
      expect(
        _bucket(reconciliation, ReceivableAgingBucketIds.overdue1To30).amount,
        300,
      );
      expect(
        _bucket(reconciliation, ReceivableAgingBucketIds.overdue31To60).amount,
        1000,
      );
    });

    test('reports variance when AR ledger is missing activity', () {
      final reconciliation = service.reconcile(
        invoices: [
          _invoice(
            id: 'invoice-1',
            amount: 750,
            dueDate: DateTime(2026, 1, 31),
          ),
        ],
        postings: const [],
        accountsReceivable: accountsReceivable,
        asOf: DateTime(2026, 2, 1),
      );

      expect(reconciliation.subledgerBalance, 750);
      expect(reconciliation.ledgerBalance, 0);
      expect(reconciliation.variance, 750);
      expect(reconciliation.isBalanced, isFalse);
    });

    test('ignores payable bills and settled invoices', () {
      final reconciliation = service.reconcile(
        invoices: [
          Invoice(
            id: 'bill-1',
            vendorId: 'vendor-1',
            invoiceNumber: 'BILL-1',
            invoiceDate: DateTime(2026, 1, 1),
            dueDate: DateTime(2026, 1, 31),
            amount: 400,
          ),
          _invoice(
            id: 'invoice-1',
            amount: 300,
            dueDate: DateTime(2026, 1, 31),
            payments: [
              Payment(id: 'pay-1', invoiceId: 'invoice-1', amount: 300),
            ],
          ),
        ],
        postings: const [],
        accountsReceivable: accountsReceivable,
        asOf: DateTime(2026, 2, 1),
      );

      expect(reconciliation.subledgerBalance, 0);
      expect(reconciliation.subledgerLines, isEmpty);
      expect(
        reconciliation.agingBuckets.every((bucket) => bucket.amount == 0),
        isTrue,
      );
    });
  });
}

ReceivableAgingBucket _bucket(
  ReceivableReconciliation reconciliation,
  String id,
) {
  return reconciliation.agingBuckets.singleWhere((bucket) => bucket.id == id);
}

Invoice _invoice({
  required String id,
  required double amount,
  required DateTime dueDate,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    customerId: 'customer-1',
    invoiceNumber: 'INV-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: dueDate,
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
    source: JournalSource.receivableInvoice,
    lines: [
      LedgerPostingLine(
        id: '$id-line',
        accountId: 'ar',
        accountName: 'Accounts Receivable',
        side: side,
        amount: amount,
      ),
    ],
  );
}
