import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_review_exception.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_exception_resolution_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_exception_resolution_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  group('FinancialReportExceptionResolutionDialog', () {
    testWidgets('requires a posted adjustment journal for adjusted evidence', (
      tester,
    ) async {
      FinancialReportExceptionResolution? savedResolution;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    savedResolution =
                        await showFinancialReportExceptionResolutionDialog(
                          context,
                          exception: _exception,
                          initialStatus:
                              FinancialReportExceptionResolutionStatus.adjusted,
                          adjustmentPostings: [_posting],
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
        find.byType(FinancialReportExceptionResolutionHeader),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportExceptionSummaryCard), findsOneWidget);
      expect(find.byType(FinancialReportExceptionStatusField), findsOneWidget);
      expect(
        find.byType(FinancialReportExceptionEvidenceField),
        findsOneWidget,
      );
      expect(find.byType(AppDialogActions), findsOneWidget);
      expect(find.text('Posted adjustment journal'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Resolution note'),
        'Adjusted cash presentation and posted the correcting journal.',
      );
      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(
        find.text('Posted adjustment journal is required'),
        findsOneWidget,
      );
      expect(savedResolution, isNull);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ADJ-001 - Correct cash classification').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Evidence'));
      await tester.pumpAndSettle();

      expect(
        savedResolution?.status,
        FinancialReportExceptionResolutionStatus.adjusted,
      );
      expect(savedResolution?.adjustmentReference, 'ADJ-001');
      expect(savedResolution?.adjustmentPostingId, 'posting-1');
      expect(
        savedResolution?.note,
        'Adjusted cash presentation and posted the correcting journal.',
      );
    });
  });
}

const _exception = FinancialReportReviewException(
  id: 'cash-reconciliation-blocking',
  sourceComplianceId: 'cash-reconciliation',
  title: 'Cash flow reconciles to cash ledger',
  description: 'Ending cash agrees to the cash ledger balance.',
  standardReference: 'PSAK 207',
  severity: FinancialReportReviewExceptionSeverity.blocking,
  variance: 75,
);

final _posting = LedgerPosting(
  id: 'posting-1',
  journalId: 'journal-1',
  entryDate: DateTime(2026, 1, 31),
  postedAt: DateTime(2026, 2, 1, 10),
  reference: 'ADJ-001',
  description: 'Correct cash classification',
  source: JournalSource.manualAdjustment,
  lines: const [
    LedgerPostingLine(
      id: 'posting-1-1',
      accountId: 'cash',
      accountName: 'Cash',
      side: JournalSide.debit,
      amount: 75,
    ),
    LedgerPostingLine(
      id: 'posting-1-2',
      accountId: 'expense',
      accountName: 'Expense',
      side: JournalSide.credit,
      amount: 75,
    ),
  ],
);
