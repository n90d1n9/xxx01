import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/financial_statement_ledger_mapper.dart';

void main() {
  group('FinancialStatementLedgerMapper', () {
    const chart = [
      AccountingAccount(
        id: 'cash',
        code: '1000',
        name: 'Cash',
        type: AccountingAccountType.asset,
      ),
      AccountingAccount(
        id: 'revenue',
        code: '4000',
        name: 'Sales Revenue',
        type: AccountingAccountType.revenue,
      ),
      AccountingAccount(
        id: 'expense',
        code: '5000',
        name: 'Rent Expense',
        type: AccountingAccountType.expense,
      ),
    ];

    test('maps revenue and expense activity with normal signed amounts', () {
      const mapper = FinancialStatementLedgerMapper();
      final entries = mapper.toFinancialEntries([
        LedgerTransaction(
          id: 'line-1',
          date: DateTime(2026, 1, 1),
          account: '4000 - Sales Revenue',
          description: 'Invoice issued',
          type: TransactionType.credit,
          amount: 1200,
          reference: 'INV-001',
          category: 'AR Invoice',
        ),
        LedgerTransaction(
          id: 'line-2',
          date: DateTime(2026, 1, 2),
          account: '5000 - Rent Expense',
          description: 'Rent accrual',
          type: TransactionType.debit,
          amount: 300,
          reference: 'ADJ-001',
          category: 'Posted Adjustment',
        ),
      ], chart);

      expect(entries.first.type, 'income');
      expect(entries.first.amount, 1200);
      expect(entries.first.category, '4000 - Sales Revenue');
      expect(entries.first.sourceCategory, 'AR Invoice');
      expect(entries.last.type, 'expense');
      expect(entries.last.amount, 300);
    });

    test('maps asset credits as negative balances', () {
      const mapper = FinancialStatementLedgerMapper();
      final entries = mapper.toFinancialEntries([
        LedgerTransaction(
          id: 'cash-line',
          date: DateTime(2026, 1, 3),
          account: '1000 - Cash',
          description: 'Vendor payment',
          type: TransactionType.credit,
          amount: 125,
          reference: 'PAY-001',
          category: 'Operating',
        ),
      ], chart);

      expect(entries.single.name, 'Cash');
      expect(entries.single.type, 'asset');
      expect(entries.single.amount, -125);
    });

    test('skips rows that cannot be matched to the chart of accounts', () {
      const mapper = FinancialStatementLedgerMapper();
      final entries = mapper.toFinancialEntries([
        LedgerTransaction(
          id: 'unknown',
          date: DateTime(2026, 1, 4),
          account: '9999 - Unknown',
          description: 'Unknown account',
          type: TransactionType.debit,
          amount: 10,
          reference: 'UNK',
          category: 'Unknown',
        ),
      ], chart);

      expect(entries, isEmpty);
    });

    test('skips period close rows to preserve statement activity', () {
      const mapper = FinancialStatementLedgerMapper();
      final entries = mapper.toFinancialEntries([
        LedgerTransaction(
          id: 'revenue',
          date: DateTime(2026, 1, 4),
          account: '4000 - Sales Revenue',
          description: 'Invoice issued',
          type: TransactionType.credit,
          amount: 1200,
          reference: 'INV',
          category: 'AR Invoice',
        ),
        LedgerTransaction(
          id: 'close-revenue',
          date: DateTime(2026, 1, 31),
          account: '4000 - Sales Revenue',
          description: 'Close revenue',
          type: TransactionType.debit,
          amount: 1200,
          reference: 'CLOSE-20260131',
          category: 'Period Close',
        ),
      ], chart);

      expect(entries, hasLength(1));
      expect(entries.single.amount, 1200);
      expect(entries.single.sourceCategory, 'AR Invoice');
    });
  });
}
