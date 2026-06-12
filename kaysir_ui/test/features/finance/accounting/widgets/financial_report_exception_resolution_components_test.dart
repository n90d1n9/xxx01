import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_review_exception.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_exception_resolution_components.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('exception status field reports selected status changes', (
    tester,
  ) async {
    var status = FinancialReportExceptionResolutionStatus.approved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportExceptionStatusField(
            status: status,
            onChanged: (value) => status = value,
          ),
        ),
      ),
    );

    expect(
      find.byType(AppSelectField<FinancialReportExceptionResolutionStatus>),
      findsOneWidget,
    );
    expect(find.text('Approved'), findsOneWidget);

    await tester.tap(find.text('Approved'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deferred').last);
    await tester.pumpAndSettle();

    expect(status, FinancialReportExceptionResolutionStatus.deferred);
  });

  testWidgets('exception summary and evidence field expose review evidence', (
    tester,
  ) async {
    String? selectedPostingId;
    final referenceController = TextEditingController();
    addTearDown(referenceController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const FinancialReportExceptionSummaryCard(
                    exception: _exception,
                  ),
                  FinancialReportExceptionEvidenceField(
                    status: FinancialReportExceptionResolutionStatus.adjusted,
                    referenceController: referenceController,
                    adjustmentPostings: [_posting],
                    selectedAdjustmentPostingId: selectedPostingId,
                    onAdjustmentPostingChanged:
                        (value) => selectedPostingId = value,
                    postedAdjustmentValidator:
                        (value) =>
                            value == null ? 'Posted journal required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cash flow reconciles to cash ledger'), findsOneWidget);
    expect(find.text('PSAK 207'), findsOneWidget);
    expect(find.text('Blocking'), findsOneWidget);
    expect(find.text(r'$75.00'), findsOneWidget);
    expect(find.byType(AppSurface), findsOneWidget);
    expect(find.byType(AppStatusPill), findsOneWidget);
    expect(find.text('Posted adjustment journal'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADJ-001 - Correct cash classification').last);
    await tester.pumpAndSettle();

    expect(selectedPostingId, 'posting-1');
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
