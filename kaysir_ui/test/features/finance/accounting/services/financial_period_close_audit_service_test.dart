import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_audit.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_audit_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';

void main() {
  group('FinancialPeriodCloseAuditService', () {
    test('creates an audit event for period close', () {
      final service = FinancialPeriodCloseAuditService(nextId: () => 'audit-1');
      final closedAt = DateTime(2026, 2, 1, 9);
      final record = const FinancialPeriodCloseService().closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        closedAt: closedAt,
        closedBy: 'Controller',
        reportPackageHash: 'abcdef1234567890',
        reportPackageHashAlgorithm: 'SHA-256',
        closingEntryPostingId: 'posting-close-jan',
        closingEntryReference: 'CL-2026-01',
        closingEntryPostedAt: DateTime(2026, 2, 1, 8, 45),
      );

      final event = service.closed(record);

      expect(event.id, 'audit-1');
      expect(event.periodKey, '20260101-20260131');
      expect(event.action, FinancialPeriodCloseAuditAction.closed);
      expect(event.occurredAt, closedAt);
      expect(event.actor, 'Controller');
      expect(event.reason, isNull);
      expect(event.checklistReadinessRatio, 1);
      expect(event.reportPackageHash, 'abcdef1234567890');
      expect(event.reportPackageHashAlgorithm, 'SHA-256');
      expect(event.reportPackageShortHash, 'ABCDEF123456');
      expect(event.closingEntryPostingId, 'posting-close-jan');
      expect(event.closingEntryReference, 'CL-2026-01');
      expect(event.closingEntryPostedAt, DateTime(2026, 2, 1, 8, 45));
      expect(event.closingEntryEvidenceLabel, 'CL-2026-01');
    });

    test('creates an audit event for reopen with reason', () {
      var next = 0;
      final service = FinancialPeriodCloseAuditService(
        nextId: () => 'audit-${++next}',
      );
      final closeService = const FinancialPeriodCloseService();
      final closed = closeService.closePeriod(
        checklist: _checklist(),
        periodLabel: 'Jan 2026',
      );
      final reopenedAt = DateTime(2026, 2, 2, 10);
      final reopened = closeService.reopenPeriod(
        record: closed,
        reason: 'Late vendor bill',
        reopenedAt: reopenedAt,
        reopenedBy: 'Accountant',
      );

      final event = service.reopened(reopened);

      expect(event.id, 'audit-1');
      expect(event.action, FinancialPeriodCloseAuditAction.reopened);
      expect(event.occurredAt, reopenedAt);
      expect(event.actor, 'Accountant');
      expect(event.reason, 'Late vendor bill');
    });

    test('sorts audit events newest first', () {
      final service = FinancialPeriodCloseAuditService(nextId: () => 'audit');
      final older = FinancialPeriodCloseAuditEvent(
        id: 'older',
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        action: FinancialPeriodCloseAuditAction.closed,
        occurredAt: DateTime(2026, 2, 1),
        actor: 'Controller',
        reason: null,
        checklistReadinessRatio: 1,
        blockerCount: 0,
      );
      final newer = FinancialPeriodCloseAuditEvent(
        id: 'newer',
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        action: FinancialPeriodCloseAuditAction.reopened,
        occurredAt: DateTime(2026, 2, 2),
        actor: 'Controller',
        reason: 'Late adjustment',
        checklistReadinessRatio: 1,
        blockerCount: 0,
      );

      final sorted = service.newestFirst([older, newer]);

      expect(sorted.map((event) => event.id), ['newer', 'older']);
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
