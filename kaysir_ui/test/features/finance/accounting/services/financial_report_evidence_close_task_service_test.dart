import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_evidence_task_audit_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_evidence_close_task_service.dart';

void main() {
  group('FinancialReportEvidenceCloseTaskService', () {
    const service = FinancialReportEvidenceCloseTaskService();

    test('builds owner, due date, reviewer, and evidence metadata', () {
      final tasks = service.buildTasks([
        _bankScheduleWithCriticalEvidence(),
      ], generatedAt: DateTime(2026, 2, 1, 9));

      expect(tasks, hasLength(1));
      final task = tasks.single;
      expect(
        task.id,
        'evidence-bankReconciliation-bank-reconciliation-evidence',
      );
      expect(task.priority, FinancialReportEvidenceCloseTaskPriority.action);
      expect(task.blocksClose, isTrue);
      expect(task.owner, 'Treasury / Cash accountant');
      expect(task.reviewer, 'Controller');
      expect(task.dueDate, DateTime(2026, 2, 2));
      expect(task.signalLabel, '1 critical / 2 watch / 1 ready');
      expect(task.reference, 'PSAK 207 / PSAK 201');
      expect(task.evidenceLabel, contains('Bank statement'));
      expect(task.actionLabel, contains('Clear overdue timing deadline'));
    });

    test('keeps monitor-only evidence as review work', () {
      final tasks = service.buildTasks([
        _taxScheduleWithWatchEvidence(),
      ], generatedAt: DateTime(2026, 2, 2));

      expect(tasks, hasLength(1));
      final task = tasks.single;
      expect(task.priority, FinancialReportEvidenceCloseTaskPriority.monitor);
      expect(task.blocksClose, isFalse);
      expect(task.owner, 'Tax accountant');
      expect(task.reviewer, 'Tax manager');
      expect(task.dueDate, DateTime(2026, 2, 5));
      expect(task.signalLabel, '1 watch');
      expect(task.reference, 'PSAK 212 / Indonesia Tax');
    });

    test('assigns UKTM reconciliation evidence to financial reporting', () {
      final tasks = service.buildTasks([
        _managementPerformanceScheduleWithWatchEvidence(),
      ], generatedAt: DateTime(2026, 2, 2));

      expect(tasks, hasLength(1));
      final task = tasks.single;
      expect(
        task.id,
        'evidence-managementPerformanceMeasure-uktm-reconciliation',
      );
      expect(task.priority, FinancialReportEvidenceCloseTaskPriority.monitor);
      expect(task.owner, 'Financial reporting lead');
      expect(task.reviewer, 'Controller');
      expect(task.reference, 'PSAK 118 / UKTM');
      expect(task.evidenceLabel, contains('UKTM approval'));
    });

    test('does not create tasks for ready evidence', () {
      final tasks = service.buildTasks([_readySchedule()]);

      expect(tasks, isEmpty);
    });

    test('matches resolutions back to derived task ids', () {
      final items = service.buildReviewItems(
        schedules: [_bankScheduleWithCriticalEvidence()],
        resolutions: [
          FinancialReportEvidenceCloseTaskResolution(
            taskId: 'evidence-bankReconciliation-bank-reconciliation-evidence',
            status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 10),
            note: 'Attached clearing evidence.',
            evidenceReference: 'WP-BANK-001',
          ),
        ],
        generatedAt: DateTime(2026, 2, 1, 9),
      );

      expect(items, hasLength(1));
      expect(items.single.isResolved, isTrue);
      expect(items.single.blocksClose, isFalse);
      expect(items.single.resolution?.evidenceReference, 'WP-BANK-001');
    });
  });

  group('FinancialReportEvidenceTaskAuditService', () {
    test('creates evidence saved audit events', () {
      final service = FinancialReportEvidenceTaskAuditService(
        nextId: () => 'audit-1',
      );
      final task =
          FinancialReportEvidenceCloseTaskService().buildTasks([
            _bankScheduleWithCriticalEvidence(),
          ], generatedAt: DateTime(2026, 2, 1, 9)).single;
      final resolution = FinancialReportEvidenceCloseTaskResolution(
        taskId: task.id,
        status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
        reviewer: 'Controller',
        resolvedAt: DateTime(2026, 2, 1, 10),
        note: 'Attached clearing evidence.',
        evidenceReference: 'WP-BANK-001',
      );

      final event = service.evidenceSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        task: task,
        resolution: resolution,
      );

      expect(event.id, 'audit-1');
      expect(
        event.action,
        FinancialReportEvidenceTaskAuditAction.evidenceSaved,
      );
      expect(event.actor, 'Controller');
      expect(
        event.status,
        FinancialReportEvidenceCloseTaskResolutionStatus.completed,
      );
      expect(event.evidenceReference, 'WP-BANK-001');
    });
  });
}

FinancialReportSupportingSchedule _bankScheduleWithCriticalEvidence() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.bankReconciliation,
    title: 'Bank Reconciliation Evidence',
    subtitle: 'Bank statement and GL cash/bank tie-out.',
    totalLabel: 'Bank reconciliation variance',
    lines: [],
    metrics: [
      FinancialReportScheduleMetric(
        label: 'Timing deadline risk',
        value: '1 overdue / 1 due soon',
        helperText: 'Clear-by deadline risk.',
      ),
      FinancialReportScheduleMetric(
        label: 'Timing review gaps',
        value: '1 unreviewed / 0 owner gaps / 0 overdue unresolved',
        helperText: 'Open documentation, owner, and overdue review gaps.',
      ),
      FinancialReportScheduleMetric(
        label: 'Timing review coverage',
        value: '2/3 documented / 2/3 resolved',
        helperText: 'Review evidence coverage.',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _taxScheduleWithWatchEvidence() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.incomeTaxSettlement,
    title: 'Income Tax Settlement',
    subtitle: 'Income tax payable and credits.',
    totalLabel: 'Income tax payable',
    lines: [
      FinancialReportScheduleLine(
        label: 'PPh 23 credit',
        amount: 120,
        sourceCategory: 'Review open / awaiting withholding slip',
      ),
    ],
  );
}

FinancialReportSupportingSchedule
_managementPerformanceScheduleWithWatchEvidence() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.managementPerformanceMeasure,
    title: 'UKTM Reconciliation',
    subtitle: 'Management performance measure reconciliation.',
    totalLabel: 'UKTM reconciliation variance',
    lines: [
      FinancialReportScheduleLine(
        label: 'Management measure approval',
        amount: 0,
        sourceCategory: 'Review open / approval pending',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _readySchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.cashRollForward,
    title: 'Cash roll-forward',
    subtitle: 'Movement in cash and bank balances.',
    totalLabel: 'Net cash movement',
    lines: [
      FinancialReportScheduleLine(
        label: 'Statement movement',
        amount: 100,
        sourceCategory: 'Imported bank statement lines',
      ),
    ],
  );
}
