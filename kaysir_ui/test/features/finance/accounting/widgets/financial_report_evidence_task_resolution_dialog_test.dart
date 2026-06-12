import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_evidence_task_resolution_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_evidence_task_resolution_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  group('FinancialReportEvidenceTaskResolutionDialog', () {
    testWidgets('requires a resolution note before saving evidence', (
      tester,
    ) async {
      FinancialReportEvidenceCloseTaskResolution? savedResolution;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    savedResolution =
                        await showFinancialReportEvidenceTaskResolutionDialog(
                          context,
                          task: _task,
                          initialStatus:
                              FinancialReportEvidenceCloseTaskResolutionStatus
                                  .completed,
                        );
                  },
                  child: const Text('Open dialog'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(
        find.byType(FinancialReportEvidenceTaskResolutionHeader),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportEvidenceTaskSummaryCard),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportEvidenceTaskStatusField),
        findsOneWidget,
      );
      expect(find.byType(AppDialogActions), findsOneWidget);
      expect(find.text('Bank evidence overdue'), findsOneWidget);

      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(find.text('Required'), findsOneWidget);
      expect(savedResolution, isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Evidence reference'),
        'WP-BANK-001',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Resolution note'),
        'Uploaded bank statement and GL tie-out evidence.',
      );
      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(
        savedResolution?.status,
        FinancialReportEvidenceCloseTaskResolutionStatus.completed,
      );
      expect(savedResolution?.reviewer, 'Controller');
      expect(savedResolution?.evidenceReference, 'WP-BANK-001');
      expect(
        savedResolution?.note,
        'Uploaded bank statement and GL tie-out evidence.',
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
