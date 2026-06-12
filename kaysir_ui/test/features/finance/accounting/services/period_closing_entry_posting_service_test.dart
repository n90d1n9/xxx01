import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/models/period_closing_entry.dart';
import 'package:kaysir/features/finance/accounting/services/period_closing_entry_posting_service.dart';
import 'package:kaysir/features/finance/accounting/services/period_closing_entry_service.dart';

void main() {
  group('PeriodClosingEntryPostingService', () {
    test('posts a ready closing entry preview', () {
      final service = PeriodClosingEntryPostingService(
        postingService: LedgerPostingService(
          now: () => DateTime(2026, 2, 1, 9),
          nextId: () => 'posting-1',
        ),
      );

      final posting = service.post(
        preview: _preview(),
        chartOfAccounts: _chart(),
        existingPostings: const [],
        closeRecords: const [],
      );

      expect(posting.id, 'posting-1');
      expect(posting.reference, 'CLOSE-20260131');
      expect(posting.source, JournalSource.periodClose);
      expect(posting.debitTotal, 1000);
      expect(posting.creditTotal, 1000);
    });

    test('prevents duplicate closing entry postings for the same period', () {
      final postingService = LedgerPostingService(
        now: () => DateTime(2026, 2, 1, 9),
        nextId: () => 'posting-1',
      );
      final service = PeriodClosingEntryPostingService(
        postingService: postingService,
      );
      final preview = _preview();
      final existing = service.post(
        preview: preview,
        chartOfAccounts: _chart(),
        existingPostings: const [],
        closeRecords: const [],
      );

      expect(
        () => service.post(
          preview: preview,
          chartOfAccounts: _chart(),
          existingPostings: [existing],
          closeRecords: const [],
        ),
        throwsStateError,
      );
    });

    test('blocks posting into a closed period', () {
      final service = PeriodClosingEntryPostingService(
        postingService: LedgerPostingService(nextId: () => 'posting-1'),
      );

      expect(
        () => service.post(
          preview: _preview(),
          chartOfAccounts: _chart(),
          existingPostings: const [],
          closeRecords: [_closedRecord()],
        ),
        throwsStateError,
      );
    });

    test('rejects previews that are not ready', () {
      final service = PeriodClosingEntryPostingService(
        postingService: LedgerPostingService(nextId: () => 'posting-1'),
      );
      final preview = _preview(
        chartOfAccounts:
            _chart().where((account) => account.code != '3000').toList(),
      );

      expect(
        () => service.post(
          preview: preview,
          chartOfAccounts: _chart(),
          existingPostings: const [],
          closeRecords: const [],
        ),
        throwsStateError,
      );
    });
  });
}

PeriodClosingEntryPreview _preview({List<AccountingAccount>? chartOfAccounts}) {
  return const PeriodClosingEntryService().preview(
    periodLabel: 'Jan 2026',
    closingDate: DateTime(2026, 1, 31),
    transactions: [
      LedgerTransaction(
        date: DateTime(2026, 1, 15),
        account: '4000 - Sales Revenue',
        description: 'Invoice',
        type: TransactionType.credit,
        amount: 1000,
        reference: 'INV',
        category: 'AR Invoice',
      ),
      LedgerTransaction(
        date: DateTime(2026, 1, 20),
        account: '5000 - Rent Expense',
        description: 'Rent',
        type: TransactionType.debit,
        amount: 400,
        reference: 'BILL',
        category: 'AP Bill',
      ),
    ],
    chartOfAccounts: chartOfAccounts ?? _chart(),
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
  );
}

FinancialPeriodCloseRecord _closedRecord() {
  return FinancialPeriodCloseRecord(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    status: FinancialPeriodCloseStatus.closed,
    closedAt: DateTime(2026, 2, 1),
    closedBy: 'Controller',
    reopenedAt: null,
    reopenedBy: null,
    reopenReason: null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportGeneratedAt: DateTime(2026, 2, 1),
  );
}

List<AccountingAccount> _chart() {
  return const [
    AccountingAccount(
      id: 'retained-earnings',
      code: '3000',
      name: 'Retained Earnings',
      type: AccountingAccountType.equity,
    ),
    AccountingAccount(
      id: 'sales-revenue',
      code: '4000',
      name: 'Sales Revenue',
      type: AccountingAccountType.revenue,
    ),
    AccountingAccount(
      id: 'rent-expense',
      code: '5000',
      name: 'Rent Expense',
      type: AccountingAccountType.expense,
    ),
  ];
}
