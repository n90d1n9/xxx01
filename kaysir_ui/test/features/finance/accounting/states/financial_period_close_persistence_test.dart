import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_audit.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_period_close_repository.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_audit_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_period_close_service.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_period_close_audit_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_period_close_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_provider.dart';

void main() {
  group('Financial period close persistence', () {
    test('close notifier hydrates and writes records through repository', () {
      const service = FinancialPeriodCloseService();
      final repository = InMemoryFinancialPeriodCloseRepository();
      final seeded = service.closePeriod(
        checklist: _checklist('Jan 1, 2026 - Jan 31, 2026'),
        periodLabel: 'Jan 1, 2026 - Jan 31, 2026',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        closedAt: DateTime(2026, 2, 1, 9),
        closedBy: 'Controller',
      );
      repository.upsertRecord(seeded);

      final notifier = FinancialPeriodCloseNotifier(
        repository: repository,
        service: service,
      );

      expect(notifier.state[seeded.periodKey], seeded);

      final next = notifier.closeCurrentPeriod(
        checklist: _checklist('Feb 1, 2026 - Feb 28, 2026'),
        period: FinancialStatementPeriod(
          preset: FinancialPeriodPreset.custom,
          startDate: DateTime(2026, 2, 1),
          endDate: DateTime(2026, 2, 28),
        ),
        closedBy: 'Accounting Lead',
      );

      expect(repository.loadRecords()[next.periodKey], next);
      expect(notifier.state[next.periodKey], next);

      final reopened = notifier.reopenCurrentPeriod(
        period: FinancialStatementPeriod(
          preset: FinancialPeriodPreset.custom,
          startDate: DateTime(2026, 2, 1),
          endDate: DateTime(2026, 2, 28),
        ),
        reason: 'Late accrual',
        reopenedBy: 'Controller',
      );

      expect(repository.loadRecords()[next.periodKey], reopened);
      expect(notifier.state[next.periodKey]?.reopenReason, 'Late accrual');
    });

    test('audit notifier hydrates and writes events through repository', () {
      const closeService = FinancialPeriodCloseService();
      final repository = InMemoryFinancialPeriodCloseRepository();
      final seeded = FinancialPeriodCloseAuditEvent(
        id: 'audit-seeded',
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 1, 2026 - Jan 31, 2026',
        action: FinancialPeriodCloseAuditAction.closed,
        occurredAt: DateTime(2026, 2, 1, 9),
        actor: 'Controller',
        reason: null,
        checklistReadinessRatio: 1,
        blockerCount: 0,
      );
      repository.appendAuditEvent(seeded);
      final auditService = FinancialPeriodCloseAuditService(
        nextId: () => 'audit-next',
      );
      final notifier = FinancialPeriodCloseAuditNotifier(
        repository: repository,
        service: auditService,
      );

      expect(notifier.state, [seeded]);

      final closed = closeService.closePeriod(
        checklist: _checklist('Feb 1, 2026 - Feb 28, 2026'),
        periodLabel: 'Feb 1, 2026 - Feb 28, 2026',
        periodStart: DateTime(2026, 2, 1),
        periodEnd: DateTime(2026, 2, 28),
        closedAt: DateTime(2026, 3, 1, 9),
        closedBy: 'Accounting Lead',
      );
      final event = notifier.recordClosed(closed);

      expect(event.id, 'audit-next');
      expect(repository.loadAuditEvents().map((item) => item.id), [
        'audit-seeded',
        'audit-next',
      ]);
      expect(notifier.state.map((item) => item.id), [
        'audit-seeded',
        'audit-next',
      ]);

      final reopened = closeService.reopenPeriod(
        record: closed,
        reason: 'Late accrual',
        reopenedAt: DateTime(2026, 3, 2, 9),
        reopenedBy: 'Controller',
      );
      final reopenEvent = notifier.recordReopened(reopened);

      expect(reopenEvent.id, 'audit-next');
      expect(repository.loadAuditEvents().map((item) => item.action), [
        FinancialPeriodCloseAuditAction.closed,
        FinancialPeriodCloseAuditAction.closed,
        FinancialPeriodCloseAuditAction.reopened,
      ]);
    });
  });
}

FinancialCloseChecklist _checklist(String periodLabel) {
  return FinancialCloseChecklist(
    periodLabel: periodLabel,
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
