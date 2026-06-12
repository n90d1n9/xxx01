import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_evidence_task_resolution_components.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  group('financial report evidence task resolution components', () {
    testWidgets('status field reports selected status changes', (tester) async {
      var status = FinancialReportEvidenceCloseTaskResolutionStatus.completed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportEvidenceTaskStatusField(
              status: status,
              onChanged: (value) => status = value,
            ),
          ),
        ),
      );

      expect(
        find.byType(
          AppSelectField<FinancialReportEvidenceCloseTaskResolutionStatus>,
        ),
        findsOneWidget,
      );
      expect(find.text('Completed'), findsOneWidget);

      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deferred').last);
      await tester.pumpAndSettle();

      expect(status, FinancialReportEvidenceCloseTaskResolutionStatus.deferred);
    });

    testWidgets('header and summary card expose task review context', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const FinancialReportEvidenceTaskResolutionHeader(),
                    const SizedBox(height: 16),
                    FinancialReportEvidenceTaskSummaryCard(task: _task),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Resolve Evidence Task'), findsOneWidget);
      expect(
        find.text('Attach review evidence for close readiness.'),
        findsOneWidget,
      );
      expect(find.text('Bank evidence overdue'), findsOneWidget);
      expect(
        find.text('Upload bank statement and GL tie-out evidence.'),
        findsOneWidget,
      );
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Bank reconciliation'), findsOneWidget);
      expect(find.text('Treasury'), findsOneWidget);
      expect(find.text('Controller'), findsOneWidget);
      expect(find.text('1 critical / 2 watch'), findsOneWidget);
      expect(find.text('PSAK 207'), findsOneWidget);
      expect(find.byType(AppSurface), findsOneWidget);
      expect(find.byType(AppStatusPill), findsOneWidget);
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
  watchSignalCount: 2,
  readySignalCount: 0,
);
