import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';

void main() {
  group('LedgerPostingService', () {
    final chart = [
      const AccountingAccount(
        id: 'cash',
        code: '1000',
        name: 'Cash',
        type: AccountingAccountType.asset,
      ),
      const AccountingAccount(
        id: 'revenue',
        code: '4000',
        name: 'Sales Revenue',
        type: AccountingAccountType.revenue,
      ),
    ];

    test('posts a balanced journal into immutable ledger lines', () {
      final service = LedgerPostingService(
        now: () => DateTime(2026, 1, 2, 9),
        nextId: () => 'posting-1',
      );

      final posting = service.post(
        JournalDraft(
          id: 'je-1',
          date: DateTime(2026, 1, 1),
          reference: 'JE-001',
          description: 'Record sale',
          source: JournalSource.manualAdjustment,
          lines: const [
            JournalLineDraft(
              accountId: 'cash',
              accountName: 'Cash',
              side: JournalSide.debit,
              amount: 500,
            ),
            JournalLineDraft(
              accountId: 'revenue',
              accountName: 'Sales Revenue',
              side: JournalSide.credit,
              amount: 500,
            ),
          ],
        ),
        chart,
      );

      expect(posting.id, 'posting-1');
      expect(posting.debitTotal, 500);
      expect(posting.creditTotal, 500);
      expect(posting.lines.first.signedAmount, 500);
      expect(posting.lines.last.signedAmount, -500);
    });

    test('rejects an unbalanced journal', () {
      final service = LedgerPostingService(nextId: () => 'posting-1');

      expect(
        () => service.post(
          JournalDraft(
            id: 'je-2',
            date: DateTime(2026, 1, 1),
            reference: 'JE-002',
            description: 'Broken entry',
            source: JournalSource.manualAdjustment,
            lines: const [
              JournalLineDraft(
                accountId: 'cash',
                accountName: 'Cash',
                side: JournalSide.debit,
                amount: 500,
              ),
              JournalLineDraft(
                accountId: 'revenue',
                accountName: 'Sales Revenue',
                side: JournalSide.credit,
                amount: 250,
              ),
            ],
          ),
          chart,
        ),
        throwsA(isA<LedgerPostingException>()),
      );
    });

    test('rejects missing or inactive accounts', () {
      final service = LedgerPostingService(nextId: () => 'posting-1');
      final inactiveChart = [
        chart.first,
        const AccountingAccount(
          id: 'old-revenue',
          code: '4999',
          name: 'Old Revenue',
          type: AccountingAccountType.revenue,
          isActive: false,
        ),
      ];

      final validation = service.validate(
        JournalDraft(
          id: 'je-3',
          date: DateTime(2026, 1, 1),
          reference: 'JE-003',
          description: 'Invalid account entry',
          source: JournalSource.manualAdjustment,
          lines: const [
            JournalLineDraft(
              accountId: 'cash',
              accountName: 'Cash',
              side: JournalSide.debit,
              amount: 500,
            ),
            JournalLineDraft(
              accountId: 'old-revenue',
              accountName: 'Old Revenue',
              side: JournalSide.credit,
              amount: 250,
            ),
            JournalLineDraft(
              accountId: 'missing',
              accountName: 'Missing Account',
              side: JournalSide.credit,
              amount: 250,
            ),
          ],
        ),
        inactiveChart,
      );

      expect(validation.isValid, isFalse);
      expect(validation.issues, contains('Account is inactive: Old Revenue'));
      expect(validation.issues, contains('Account not found: Missing Account'));
    });
  });
}
