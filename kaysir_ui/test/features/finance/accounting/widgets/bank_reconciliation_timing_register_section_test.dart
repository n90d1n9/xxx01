import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register_filter.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_reconciliation_timing_register_section.dart';

void main() {
  testWidgets('deadline-risk view opens sorted by most urgent clear-by date', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BankReconciliationTimingRegisterSection(
              items: [
                _timingItem(
                  reference: 'DUE-SOON',
                  ageDays: 40,
                  clearByDaysFromDate: 44,
                  amount: -500,
                ),
                _timingItem(
                  reference: 'OVERDUE',
                  ageDays: 5,
                  clearByDaysFromDate: 5,
                  amount: 200,
                ),
                _timingItem(
                  reference: 'ON-TRACK',
                  ageDays: 60,
                  clearByDaysFromDate: 90,
                  amount: 900,
                ),
              ],
              currency: NumberFormat.currency(locale: 'en_US', symbol: '\$'),
              dateFormat: DateFormat('MM/dd/yyyy'),
              initialFilter:
                  BankReconciliationTimingRegisterFilter.deadlineRisk,
            ),
          ),
        ),
      ),
    );

    final registerSection = find.byKey(
      const Key('bank-timing-register-section'),
    );
    final atRiskFilter = find.descendant(
      of: registerSection,
      matching: find.widgetWithText(ChoiceChip, 'At Risk'),
    );

    expect(tester.widget<ChoiceChip>(atRiskFilter).selected, isTrue);
    expect(
      find.descendant(of: registerSection, matching: find.text('OVERDUE')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: registerSection, matching: find.text('DUE-SOON')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: registerSection, matching: find.text('ON-TRACK')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: registerSection,
        matching: find.text('2 / 3 item(s)'),
      ),
      findsOneWidget,
    );

    final overdueTop = tester.getTopLeft(
      find.descendant(of: registerSection, matching: find.text('OVERDUE')),
    );
    final dueSoonTop = tester.getTopLeft(
      find.descendant(of: registerSection, matching: find.text('DUE-SOON')),
    );
    expect(overdueTop.dy, lessThan(dueSoonTop.dy));
  });

  testWidgets('review column renders evidence and reports row updates', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    String? selectedReference;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BankReconciliationTimingRegisterSection(
              items: [
                _timingItem(
                  reference: 'REV-001',
                  ageDays: 12,
                  clearByDaysFromDate: 16,
                  amount: -275,
                ),
              ],
              reviews: {
                'REV-001': BankReconciliationTimingReview(
                  reference: 'REV-001',
                  status: BankReconciliationTimingReviewStatus.inReview,
                  owner: 'Controller',
                  note: 'Waiting for next bank statement',
                  reviewedAt: DateTime(2026, 2, 1),
                ),
              },
              currency: NumberFormat.currency(locale: 'en_US', symbol: '\$'),
              dateFormat: DateFormat('MM/dd/yyyy'),
              onReview: (item) => selectedReference = item.reference,
            ),
          ),
        ),
      ),
    );

    final registerSection = find.byKey(
      const Key('bank-timing-register-section'),
    );
    expect(
      find.descendant(of: registerSection, matching: find.text('Review')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: registerSection, matching: find.text('In Review')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: registerSection,
        matching: find.text('Controller / Waiting for next bank statement'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: registerSection,
        matching: find.text('Review Coverage'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: registerSection, matching: find.text('1/1')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: registerSection,
        matching: find.text('Unresolved Review'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: registerSection,
        matching: find.text('0 resolved / 0 overdue'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.descendant(of: registerSection, matching: find.byType(TextField)),
      'controller',
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: registerSection, matching: find.text('REV-001')),
      findsOneWidget,
    );

    final updateAction = find.byKey(
      const Key('bank-timing-review-action-REV-001'),
    );
    tester.widget<TextButton>(updateAction).onPressed?.call();

    expect(selectedReference, 'REV-001');
  });
}

BankReconciliationTimingRegisterItem _timingItem({
  required String reference,
  required int ageDays,
  required int clearByDaysFromDate,
  required double amount,
}) {
  final date = DateTime(2026, 1, 1);

  return BankReconciliationTimingRegisterItem(
    reference: reference,
    date: date,
    description: 'Timing difference $reference',
    amount: amount,
    ageDays: ageDays,
    clearByDate: date.add(Duration(days: clearByDaysFromDate)),
    bucket: BankReconciliationTimingBucket.stale,
    type:
        amount >= 0
            ? BankReconciliationResolutionType.depositInTransit
            : BankReconciliationResolutionType.outstandingPayment,
    clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
    suggestedAction: 'Follow up with bank operations',
  );
}
