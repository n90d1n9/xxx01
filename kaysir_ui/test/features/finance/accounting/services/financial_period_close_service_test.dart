import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';

void main() {
  group('FinancialPeriodCloseService', () {
    const service = FinancialPeriodCloseService();

    test('closes a period when the checklist has no blockers', () {
      final closedAt = DateTime(2026, 2, 1, 9);
      final record = service.closePeriod(
        checklist: _checklist(blocked: 0),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        closedAt: closedAt,
        closedBy: 'Accountant',
        reportPackageHash: 'abc123',
        reportPackageHashAlgorithm: 'SHA-256',
        closingEntryPostingId: 'posting-close-jan',
        closingEntryReference: 'CL-2026-01',
        closingEntryPostedAt: DateTime(2026, 2, 1, 8, 45),
      );

      expect(record.periodKey, '20260101-20260131');
      expect(record.periodStart, DateTime(2026, 1, 1));
      expect(record.periodEnd, DateTime(2026, 1, 31));
      expect(record.status, FinancialPeriodCloseStatus.closed);
      expect(record.isClosed, isTrue);
      expect(record.closedAt, closedAt);
      expect(record.closedBy, 'Accountant');
      expect(record.blockerCount, 0);
      expect(record.reportPackageHash, 'abc123');
      expect(record.reportPackageHashAlgorithm, 'SHA-256');
      expect(record.reportPackageShortHash, 'ABC123');
      expect(record.closingEntryPostingId, 'posting-close-jan');
      expect(record.closingEntryReference, 'CL-2026-01');
      expect(record.closingEntryPostedAt, DateTime(2026, 2, 1, 8, 45));
      expect(record.closingEntryEvidenceLabel, 'CL-2026-01');
    });

    test('blocks close when checklist blockers remain', () {
      expect(
        () => service.closePeriod(
          checklist: _checklist(blocked: 1),
          periodLabel: 'Jan 2026',
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        ),
        throwsStateError,
      );
    });

    test('reopens a closed period with a reason', () {
      final record = service.closePeriod(
        checklist: _checklist(blocked: 0),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );
      final reopenedAt = DateTime(2026, 2, 2, 10);
      final reopened = service.reopenPeriod(
        record: record,
        reason: 'Late vendor bill',
        reopenedAt: reopenedAt,
        reopenedBy: 'Controller',
      );

      expect(reopened.status, FinancialPeriodCloseStatus.reopened);
      expect(reopened.isClosed, isFalse);
      expect(reopened.reopenedAt, reopenedAt);
      expect(reopened.reopenedBy, 'Controller');
      expect(reopened.reopenReason, 'Late vendor bill');
    });

    test('requires a reason when reopening', () {
      final record = service.closePeriod(
        checklist: _checklist(blocked: 0),
        periodLabel: 'Jan 2026',
      );

      expect(
        () => service.reopenPeriod(record: record, reason: '  '),
        throwsArgumentError,
      );
    });
  });
}

FinancialCloseChecklist _checklist({required int blocked}) {
  return FinancialCloseChecklist(
    periodLabel: 'Jan 2026',
    generatedAt: DateTime(2026, 2, 1),
    totalDebit: 100,
    totalCredit: blocked == 0 ? 100 : 90,
    trialBalanceVariance: blocked == 0 ? 0 : 10,
    items: [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance',
        description: 'Debits equal credits',
        status:
            blocked == 0
                ? FinancialCloseItemStatus.ready
                : FinancialCloseItemStatus.blocked,
        reference: 'GL',
      ),
      const FinancialCloseChecklistItem(
        id: 'report-pack',
        title: 'Report pack',
        description: 'Statements generated',
        status: FinancialCloseItemStatus.ready,
        reference: 'PSAK 201',
      ),
    ],
  );
}
