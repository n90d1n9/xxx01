import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/adapters/posted_ledger_transaction_adapter.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';

void main() {
  group('PostedLedgerTransactionAdapter', () {
    test('maps posted receivable payment lines into locked ledger rows', () {
      final posting = LedgerPosting(
        id: 'posting-1',
        journalId: 'ar-payment-PAY-001',
        entryDate: DateTime(2026, 1, 5),
        postedAt: DateTime(2026, 1, 5, 10),
        reference: 'PAY-001',
        description: 'Payment received for invoice INV-001',
        source: JournalSource.receivablePayment,
        lines: const [
          LedgerPostingLine(
            id: 'posting-1-1',
            accountId: 'cash',
            accountName: 'Cash',
            side: JournalSide.debit,
            amount: 750,
            memo: 'Cash receipt',
          ),
          LedgerPostingLine(
            id: 'posting-1-2',
            accountId: 'ar',
            accountName: 'Accounts Receivable',
            side: JournalSide.credit,
            amount: 750,
            memo: 'Settle invoice INV-001',
          ),
        ],
      );

      final rows = posting.toLedgerTransactions(const [
        AccountingAccount(
          id: 'cash',
          code: '1000',
          name: 'Cash',
          type: AccountingAccountType.asset,
        ),
        AccountingAccount(
          id: 'ar',
          code: '1100',
          name: 'Accounts Receivable',
          type: AccountingAccountType.asset,
        ),
      ]);

      expect(rows, hasLength(2));
      expect(rows.first.account, '1000 - Cash');
      expect(rows.first.type, TransactionType.debit);
      expect(rows.first.category, 'AR Payment');
      expect(rows.first.isSystemGenerated, isTrue);
      expect(rows.first.journalId, 'ar-payment-PAY-001');
      expect(rows.last.account, '1100 - Accounts Receivable');
      expect(rows.last.type, TransactionType.credit);
    });

    test(
      'falls back to posting line account names when chart is incomplete',
      () {
        final posting = LedgerPosting(
          id: 'posting-2',
          journalId: 'manual-1',
          entryDate: DateTime(2026, 1, 6),
          postedAt: DateTime(2026, 1, 6, 10),
          reference: 'ADJ-001',
          description: 'Month-end adjustment',
          source: JournalSource.manualAdjustment,
          lines: const [
            LedgerPostingLine(
              id: 'posting-2-1',
              accountId: 'missing',
              accountName: 'Accrued Expenses',
              side: JournalSide.credit,
              amount: 250,
            ),
          ],
        );

        final rows = posting.toLedgerTransactions(const []);

        expect(rows.single.account, 'Accrued Expenses');
        expect(rows.single.category, 'Posted Adjustment');
      },
    );
  });
}
