import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_posting_guard_service.dart';

void main() {
  group('FinancialPeriodPostingGuardService', () {
    const closeService = FinancialPeriodCloseService();
    const guardService = FinancialPeriodPostingGuardService();

    test('blocks postings dated inside a closed period', () {
      final record = closeService.closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(
        () => guardService.ensureDateIsOpen(
          entryDate: DateTime(2026, 1, 15),
          records: [record],
          actionLabel: 'post a vendor bill',
        ),
        throwsStateError,
      );
    });

    test('allows postings outside a closed period', () {
      final record = closeService.closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(
        () => guardService.ensureDateIsOpen(
          entryDate: DateTime(2026, 2, 1),
          records: [record],
          actionLabel: 'post a vendor bill',
        ),
        returnsNormally,
      );
    });

    test('ignores reopened periods', () {
      final closed = closeService.closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final reopened = closeService.reopenPeriod(
        record: closed,
        reason: 'Late adjustment',
      );

      expect(
        guardService.closedRecordForDate(
          entryDate: DateTime(2026, 1, 15),
          records: [reopened],
        ),
        isNull,
      );
    });
  });
}

FinancialCloseChecklist _checklist() {
  return FinancialCloseChecklist(
    periodLabel: 'Jan 2026',
    generatedAt: DateTime(2026, 2, 1),
    totalDebit: 100,
    totalCredit: 100,
    trialBalanceVariance: 0,
    items: const [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance',
        description: 'Debits equal credits',
        status: FinancialCloseItemStatus.ready,
        reference: 'GL',
      ),
      FinancialCloseChecklistItem(
        id: 'report-pack',
        title: 'Report pack',
        description: 'Statements generated',
        status: FinancialCloseItemStatus.ready,
        reference: 'PSAK 201',
      ),
    ],
  );
}
