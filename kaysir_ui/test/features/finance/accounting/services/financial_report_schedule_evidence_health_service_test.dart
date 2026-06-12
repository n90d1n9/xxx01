import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_schedule_evidence_health_service.dart';

void main() {
  group('FinancialReportScheduleEvidenceHealthService', () {
    const service = FinancialReportScheduleEvidenceHealthService();

    test('summarizes timing review metrics into action health', () {
      final summary = service.summarize([_timingScheduleWithMetrics()]);

      expect(summary.level, FinancialReportScheduleEvidenceHealthLevel.action);
      expect(summary.criticalSignalCount, 1);
      expect(summary.watchSignalCount, 2);
      expect(summary.actionLabel, contains('Resolve 1 critical'));
      expect(summary.actionLabel, contains('Monitor 2 watch'));
      expect(summary.actionLabel, contains('Clear overdue timing deadline'));
    });

    test('keeps per-schedule health rows for drill-down', () {
      final items = service.summarizeBySchedule([
        _timingScheduleWithMetrics(),
        _cleanSchedule(),
      ]);

      expect(items, hasLength(2));
      expect(items.first.scheduleTitle, 'Bank Reconciliation Evidence');
      expect(
        items.first.level,
        FinancialReportScheduleEvidenceHealthLevel.action,
      );
      expect(items.first.summary.criticalSignalCount, 1);
      expect(items.last.scheduleTitle, 'Cash roll-forward');
      expect(
        items.last.level,
        FinancialReportScheduleEvidenceHealthLevel.ready,
      );
      expect(items.last.actionLabel, 'Evidence ready');
    });

    test('falls back to source-line evidence when metrics are unavailable', () {
      final summary = service.summarize([_timingScheduleWithoutMetrics()]);

      expect(summary.level, FinancialReportScheduleEvidenceHealthLevel.action);
      expect(summary.criticalSignalCount, 1);
      expect(summary.watchSignalCount, 0);
    });

    test('marks clean evidence as ready', () {
      final summary = service.summarize([_cleanSchedule()]);

      expect(summary.level, FinancialReportScheduleEvidenceHealthLevel.ready);
      expect(summary.actionLabel, 'Evidence ready');
    });
  });
}

FinancialReportSupportingSchedule _timingScheduleWithMetrics() {
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
        label: 'Timing review action',
        value: 'Document 1 open review(s)',
        helperText: 'Review follow-up.',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _timingScheduleWithoutMetrics() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.bankReconciliation,
    title: 'Bank Reconciliation Evidence',
    subtitle: 'Bank statement and GL cash/bank tie-out.',
    totalLabel: 'Bank reconciliation variance',
    lines: [
      FinancialReportScheduleLine(
        label: 'Timing PAY-002 - Outstanding payment',
        amount: -300,
        sourceCategory:
            'Stale timing difference / Escalate / Clear by Jan 29, 2026 / '
            'Overdue / Review Cleared / Owner Controller',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _cleanSchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.cashRollForward,
    title: 'Cash roll-forward',
    subtitle: 'Movement in cash and bank balances.',
    totalLabel: 'Net cash movement',
    lines: [
      FinancialReportScheduleLine(
        label: 'Statement movement',
        amount: 0,
        sourceCategory: 'Imported bank statement lines',
      ),
    ],
  );
}
