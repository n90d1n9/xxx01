import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_evidence_close_tasks_panel.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report evidence close task components', () {
    testWidgets('renders task header counters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportEvidenceCloseTasksHeader(
              taskCount: 3,
              resolvedCount: 1,
              blockerCount: 2,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Close Evidence Tasks'), findsOneWidget);
      expect(find.text('3 task(s)'), findsOneWidget);
      expect(find.text('1 resolved'), findsOneWidget);
      expect(find.text('2 blocks close'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(3));
    });

    testWidgets('renders task row and emits resolution action', (tester) async {
      FinancialReportEvidenceCloseTask? selectedTask;
      FinancialReportEvidenceCloseTaskResolutionStatus? selectedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportEvidenceCloseTaskRow(
              item: FinancialReportEvidenceCloseTaskReviewItem(task: _task),
              onResolveTask: (task, status) {
                selectedTask = task;
                selectedStatus = status;
              },
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Jan 31, 2026'), findsOneWidget);
      expect(find.text('Blocks close'), findsOneWidget);
      expect(find.text('Bank evidence overdue'), findsOneWidget);
      expect(find.text('Treasury'), findsOneWidget);
      expect(find.text('Controller'), findsOneWidget);
      expect(find.text('PSAK 207'), findsOneWidget);
      expect(find.text('Save Evidence'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(7));

      await tester.tap(find.text('Save Evidence'));
      await tester.pump();

      expect(selectedTask, _task);
      expect(
        selectedStatus,
        FinancialReportEvidenceCloseTaskResolutionStatus.completed,
      );
    });

    testWidgets('renders close task panel with shared panel surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportEvidenceCloseTasksPanel(
              items: [FinancialReportEvidenceCloseTaskReviewItem(task: _task)],
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Close Evidence Tasks'), findsOneWidget);
      expect(find.text('Bank evidence overdue'), findsOneWidget);
      expect(find.byType(FinancialReportPanelSurface), findsOneWidget);
      expect(find.byType(FinancialReportEvidenceCloseTaskRow), findsOneWidget);
    });

    testWidgets('renders audit trail and older-event count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportEvidenceTaskAuditTrail(
              events: _auditEvents,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Evidence Audit Trail'), findsOneWidget);
      expect(find.text('Evidence saved: Completed'), findsNWidgets(5));
      expect(
        find.text('Controller / Jan 31, 2026 09:00 / EVD-1'),
        findsOneWidget,
      );
      expect(find.text('Uploaded evidence 1'), findsOneWidget);
      expect(find.text('+1 older event(s)'), findsOneWidget);
      expect(
        find.byType(
          FinancialReportAuditTrailPanel<FinancialReportEvidenceTaskAuditEvent>,
        ),
        findsOneWidget,
      );
    });
  });
}

final _task = FinancialReportEvidenceCloseTask(
  id: 'bank-evidence',
  scheduleKind: FinancialReportSupportingScheduleKind.bankReconciliation,
  scheduleTitle: 'Bank reconciliation',
  priority: FinancialReportEvidenceCloseTaskPriority.action,
  title: 'Bank evidence overdue',
  actionLabel: 'Upload bank statement and GL tie-out evidence.',
  owner: 'Treasury',
  dueDate: DateTime(2026, 1, 31),
  reviewer: 'Controller',
  evidenceLabel: 'Bank statement and reconciliation worksheet required.',
  reference: 'PSAK 207',
  criticalSignalCount: 1,
  watchSignalCount: 0,
  readySignalCount: 0,
);

final _auditEvents = List<FinancialReportEvidenceTaskAuditEvent>.generate(
  6,
  (index) => FinancialReportEvidenceTaskAuditEvent(
    id: 'audit-$index',
    periodKey: '2026-01',
    periodLabel: 'Jan 2026',
    taskId: _task.id,
    taskTitle: _task.title,
    scheduleTitle: _task.scheduleTitle,
    action: FinancialReportEvidenceTaskAuditAction.evidenceSaved,
    occurredAt: DateTime(2026, 1, 31, 9, index),
    actor: 'Controller',
    status: FinancialReportEvidenceCloseTaskResolutionStatus.completed,
    note: 'Uploaded evidence ${index + 1}',
    evidenceReference: 'EVD-${index + 1}',
  ),
);
