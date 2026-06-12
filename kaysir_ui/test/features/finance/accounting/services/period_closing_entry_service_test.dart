import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/models/period_closing_entry.dart';
import 'package:kaysir/features/finance/accounting/services/period_closing_entry_service.dart';

void main() {
  group('PeriodClosingEntryService', () {
    const service = PeriodClosingEntryService();

    test('creates a balanced draft closing entry for net income', () {
      final preview = service.preview(
        periodLabel: 'Jan 2026',
        closingDate: DateTime(2026, 1, 31),
        transactions: [
          _trx(
            account: '4000 - Sales Revenue',
            type: TransactionType.credit,
            amount: 1000,
          ),
          _trx(
            account: '5000 - Rent Expense',
            type: TransactionType.debit,
            amount: 300,
          ),
          _trx(
            account: '5100 - Utilities Expense',
            type: TransactionType.debit,
            amount: 200,
          ),
        ],
        chartOfAccounts: _chart(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(preview.totalRevenue, 1000);
      expect(preview.totalExpenses, 500);
      expect(preview.netIncome, 500);
      expect(preview.canPost, isTrue);
      expect(preview.isBalanced, isTrue);
      expect(preview.draft?.source, JournalSource.periodClose);
      expect(preview.draft?.reference, 'CLOSE-20260131');
      expect(preview.draft?.debitTotal, 1000);
      expect(preview.draft?.creditTotal, 1000);
      expect(_line(preview, '4000')?.side, JournalSide.debit);
      expect(_line(preview, '5000')?.side, JournalSide.credit);
      expect(_line(preview, '3000')?.side, JournalSide.credit);
      expect(_line(preview, '3000')?.amount, 500);
    });

    test('debits retained earnings for a net loss', () {
      final preview = service.preview(
        periodLabel: 'Jan 2026',
        closingDate: DateTime(2026, 1, 31),
        transactions: [
          _trx(
            account: '4000 - Sales Revenue',
            type: TransactionType.credit,
            amount: 200,
          ),
          _trx(
            account: '5000 - Rent Expense',
            type: TransactionType.debit,
            amount: 450,
          ),
        ],
        chartOfAccounts: _chart(),
      );

      expect(preview.netIncome, -250);
      expect(preview.isBalanced, isTrue);
      expect(_line(preview, '3000')?.side, JournalSide.debit);
      expect(_line(preview, '3000')?.amount, 250);
    });

    test('keeps transactions outside the selected period out of the draft', () {
      final preview = service.preview(
        periodLabel: 'Jan 2026',
        closingDate: DateTime(2026, 1, 31),
        transactions: [
          _trx(
            date: DateTime(2026, 1, 10),
            account: '4000 - Sales Revenue',
            type: TransactionType.credit,
            amount: 1000,
          ),
          _trx(
            date: DateTime(2026, 2, 1),
            account: '4000 - Sales Revenue',
            type: TransactionType.credit,
            amount: 800,
          ),
          _trx(
            date: DateTime(2025, 12, 31),
            account: '5000 - Rent Expense',
            type: TransactionType.debit,
            amount: 600,
          ),
        ],
        chartOfAccounts: _chart(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(preview.totalRevenue, 1000);
      expect(preview.totalExpenses, 0);
      expect(preview.draft?.debitTotal, 1000);
      expect(preview.draft?.creditTotal, 1000);
    });

    test('ignores already posted period close rows in the preview', () {
      final preview = service.preview(
        periodLabel: 'Jan 2026',
        closingDate: DateTime(2026, 1, 31),
        transactions: [
          _trx(
            account: '4000 - Sales Revenue',
            type: TransactionType.credit,
            amount: 1000,
          ),
          _trx(
            account: '4000 - Sales Revenue',
            type: TransactionType.debit,
            amount: 1000,
            category: 'Period Close',
          ),
        ],
        chartOfAccounts: _chart(),
      );

      expect(preview.totalRevenue, 1000);
      expect(preview.draft?.debitTotal, 1000);
      expect(preview.draft?.creditTotal, 1000);
    });

    test(
      'returns review warnings when retained earnings is not configured',
      () {
        final preview = service.preview(
          periodLabel: 'Jan 2026',
          closingDate: DateTime(2026, 1, 31),
          transactions: [
            _trx(
              account: '4000 - Sales Revenue',
              type: TransactionType.credit,
              amount: 1000,
            ),
          ],
          chartOfAccounts:
              _chart().where((account) => account.code != '3000').toList(),
        );

        expect(preview.canPost, isFalse);
        expect(preview.draft, isNull);
        expect(
          preview.warnings,
          contains('Retained earnings account 3000 is not configured.'),
        );
      },
    );
  });
}

JournalLineDraft? _line(PeriodClosingEntryPreview preview, String code) {
  return preview.draft?.lines.cast<JournalLineDraft?>().firstWhere(
    (line) => line?.accountName.startsWith(code) ?? false,
    orElse: () => null,
  );
}

LedgerTransaction _trx({
  DateTime? date,
  required String account,
  required TransactionType type,
  required double amount,
  String category = 'Test',
}) {
  return LedgerTransaction(
    date: date ?? DateTime(2026, 1, 15),
    account: account,
    description: 'Activity',
    type: type,
    amount: amount,
    reference: 'REF',
    category: category,
  );
}

List<AccountingAccount> _chart() {
  return const [
    AccountingAccount(
      id: 'cash',
      code: '1000',
      name: 'Cash',
      type: AccountingAccountType.asset,
    ),
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
    AccountingAccount(
      id: 'utilities-expense',
      code: '5100',
      name: 'Utilities Expense',
      type: AccountingAccountType.expense,
    ),
  ];
}
