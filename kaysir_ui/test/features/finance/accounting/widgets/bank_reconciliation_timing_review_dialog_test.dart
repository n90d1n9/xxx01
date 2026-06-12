import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_reconciliation_timing_review_dialog.dart';

void main() {
  testWidgets('timing review dialog saves status, owner, and note', (
    tester,
  ) async {
    BankReconciliationTimingReview? savedReview;
    final item = BankReconciliationTimingRegisterItem(
      reference: 'DEP-001',
      date: DateTime(2026, 1, 28),
      description: 'Deposit in transit',
      amount: 350,
      ageDays: 34,
      clearByDate: DateTime(2026, 2, 27),
      bucket: BankReconciliationTimingBucket.stale,
      type: BankReconciliationResolutionType.depositInTransit,
      clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
      suggestedAction: 'Confirm DEP-001 clears on a later bank statement.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  savedReview = await showBankTimingReviewDialog(
                    context,
                    item: item,
                    review: BankReconciliationTimingReview.open(item.reference),
                    currency: NumberFormat.currency(
                      locale: 'en_US',
                      symbol: '\$',
                    ),
                    dateFormat: DateFormat('MM/dd/yyyy'),
                  );
                },
                child: const Text('Open Review'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Review'));
    await tester.pumpAndSettle();

    expect(find.text('Timing review evidence'), findsOneWidget);
    expect(find.text('DEP-001'), findsOneWidget);

    await tester.tap(
      find.byType(
        DropdownButtonFormField<BankReconciliationTimingReviewStatus>,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('In Review').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Owner'),
      'Nadia Controller',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Review note'),
      'Waiting for next bank statement',
    );
    await tester.tap(find.text('Save Review'));
    await tester.pumpAndSettle();

    expect(savedReview?.reference, 'DEP-001');
    expect(savedReview?.status, BankReconciliationTimingReviewStatus.inReview);
    expect(savedReview?.owner, 'Nadia Controller');
    expect(savedReview?.note, 'Waiting for next bank statement');
  });
}
