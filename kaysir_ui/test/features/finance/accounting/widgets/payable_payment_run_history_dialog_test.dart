import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/payable_payment_run.dart';
import 'package:kaysir/features/finance/accounting/states/payable_payment_run_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_run_history_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_run_history_dialog.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

void main() {
  testWidgets('payment run history dialog shows a reusable empty state', (
    tester,
  ) async {
    await tester.pumpWidget(_historyDialog());

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No payment runs yet'), findsOneWidget);
    expect(find.textContaining('Posted AP payment runs'), findsOneWidget);
  });

  testWidgets('payment run history dialog renders modern record cards', (
    tester,
  ) async {
    await tester.pumpWidget(
      _historyDialog(records: [_samplePaymentRunRecord()]),
    );

    expect(find.byType(PaymentRunHistoryRecordCard), findsOneWidget);
    expect(find.text('PAY-RUN-001'), findsOneWidget);
    expect(find.text('Bank transfer'), findsOneWidget);
    expect(find.byType(AppStatusPill), findsOneWidget);
    expect(find.text('\$1,375.00'), findsOneWidget);
    expect(find.text('2 bills'), findsOneWidget);

    await tester.tap(find.text('PAY-RUN-001'));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentRunHistoryItemList), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);
    expect(find.textContaining('Acme Supplies'), findsOneWidget);
    expect(find.textContaining('Payment PMT-001'), findsOneWidget);
    expect(find.text('BILL-002'), findsOneWidget);
    expect(find.text('\$500.00'), findsOneWidget);
  });
}

Widget _historyDialog({List<PayablePaymentRunRecord> records = const []}) {
  return ProviderScope(
    overrides: [
      payablePaymentRunRecordsProvider.overrideWith(
        (ref) => _SeededPaymentRunRecords(records),
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: PayablePaymentRunHistoryDialog())),
    ),
  );
}

PayablePaymentRunRecord _samplePaymentRunRecord() {
  return PayablePaymentRunRecord(
    id: 'run-001',
    reference: 'PAY-RUN-001',
    paymentDate: DateTime(2026, 5, 30),
    createdAt: DateTime(2026, 5, 30, 9, 15),
    method: 'bank_transfer',
    items: [
      PayablePaymentRunRecordItem(
        billId: 'bill-001',
        billReference: 'BILL-001',
        vendorName: 'Acme Supplies',
        dueDate: DateTime(2026, 5, 29),
        paymentId: 'PMT-001',
        amount: 875,
      ),
      PayablePaymentRunRecordItem(
        billId: 'bill-002',
        billReference: 'BILL-002',
        vendorName: 'Northwind Logistics',
        dueDate: DateTime(2026, 6, 4),
        paymentId: 'PMT-002',
        amount: 500,
      ),
    ],
  );
}

class _SeededPaymentRunRecords extends PayablePaymentRunRecordsNotifier {
  _SeededPaymentRunRecords(List<PayablePaymentRunRecord> records) {
    state = records;
  }
}
