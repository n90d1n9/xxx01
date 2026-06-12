import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_report_evidence_task_resolution_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_evidence_task_audit_service.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_evidence_task_resolution_provider.dart';

void main() {
  group('Financial report evidence task resolution provider', () {
    test('stores evidence task resolutions by selected period', () {
      final repository =
          InMemoryFinancialReportEvidenceTaskResolutionRepository();
      final container = ProviderContainer(
        overrides: [
          financialReportEvidenceTaskResolutionRepositoryProvider
              .overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(selectedFinancialPeriodProvider.notifier)
          .state = FinancialStatementPeriod(
        preset: FinancialPeriodPreset.custom,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );

      final januaryKey = container.read(
        currentFinancialReportEvidenceTaskResolutionPeriodKeyProvider,
      );
      final resolution = FinancialReportEvidenceCloseTaskResolution(
        taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 10),
        note: 'Attached bank timing evidence.',
        evidenceReference: 'WP-BANK-001',
      );

      container
          .read(financialReportEvidenceTaskResolutionProvider.notifier)
          .upsertResolution(periodKey: januaryKey, resolution: resolution);

      expect(
        container.read(currentFinancialReportEvidenceTaskResolutionsProvider),
        [resolution],
      );

      container
          .read(selectedFinancialPeriodProvider.notifier)
          .state = FinancialStatementPeriod(
        preset: FinancialPeriodPreset.custom,
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      expect(
        container.read(currentFinancialReportEvidenceTaskResolutionsProvider),
        [],
      );
      expect(repository.loadResolutions()[januaryKey], [resolution]);
    });

    test('replaces existing evidence for the same task', () {
      final repository =
          InMemoryFinancialReportEvidenceTaskResolutionRepository();
      final notifier = FinancialReportEvidenceTaskResolutionNotifier(
        repository: repository,
        auditService: FinancialReportEvidenceTaskAuditService(
          nextId: () => 'audit-1',
        ),
      );
      addTearDown(notifier.dispose);

      final deferred = FinancialReportEvidenceCloseTaskResolution(
        taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
        status: FinancialReportEvidenceCloseTaskResolutionStatus.deferred,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 10),
        note: 'Waiting for later statement.',
      );
      final completed = FinancialReportEvidenceCloseTaskResolution(
        taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 12),
        note: 'Clearing evidence attached.',
        evidenceReference: 'WP-BANK-001',
      );

      notifier.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: deferred,
      );
      notifier.upsertResolution(
        periodKey: '20260101-20260131',
        resolution: completed,
      );

      expect(notifier.state['20260101-20260131'], [completed]);
      expect(
        repository.loadResolutions()['20260101-20260131']?.single.status,
        FinancialReportEvidenceCloseTaskResolutionStatus.completed,
      );
    });

    test('records audit trail when evidence is saved', () {
      final repository =
          InMemoryFinancialReportEvidenceTaskResolutionRepository();
      final notifier = FinancialReportEvidenceTaskResolutionNotifier(
        repository: repository,
        auditService: FinancialReportEvidenceTaskAuditService(
          nextId: () => 'audit-1',
        ),
      );
      addTearDown(notifier.dispose);

      final resolution = FinancialReportEvidenceCloseTaskResolution(
        taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 10),
        note: 'Clearing evidence attached.',
        evidenceReference: 'WP-BANK-001',
      );

      final event = notifier.recordResolution(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        task: _task(),
        resolution: resolution,
      );

      expect(event.id, 'audit-1');
      expect(event.actor, 'Controller');
      expect(
        event.status,
        FinancialReportEvidenceCloseTaskResolutionStatus.completed,
      );
      expect(repository.loadAuditEvents(), [event]);
      expect(
        repository.loadResolutions()['20260101-20260131']?.single,
        resolution,
      );
    });
  });
}

FinancialReportEvidenceCloseTask _task() {
  return FinancialReportEvidenceCloseTask(
    id: 'evidence-bankReconciliation-bank-reconciliation-evidence',
    scheduleKind: FinancialReportSupportingScheduleKind.bankReconciliation,
    scheduleTitle: 'Bank Reconciliation Evidence',
    priority: FinancialReportEvidenceCloseTaskPriority.action,
    title: 'Bank Reconciliation Evidence evidence follow-up',
    actionLabel: 'Resolve 1 critical evidence signal(s).',
    owner: 'Treasury / Cash accountant',
    dueDate: DateTime(2026, 2, 2),
    reviewer: 'Controller',
    evidenceLabel: 'Bank statement, timing review, and clearing evidence',
    reference: 'PSAK 207 / PSAK 201',
    criticalSignalCount: 1,
    watchSignalCount: 0,
    readySignalCount: 0,
  );
}
