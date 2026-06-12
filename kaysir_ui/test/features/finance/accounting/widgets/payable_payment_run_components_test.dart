import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_run_components.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_checkbox_row.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('payment run controls use reusable select field', (tester) async {
    final referenceController = TextEditingController(text: 'RUN-001');
    addTearDown(referenceController.dispose);
    String? selectedMethod;
    var pickedDate = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            child: PaymentRunControls(
              referenceController: referenceController,
              paymentDate: DateTime(2026, 5, 31),
              method: 'bank_transfer',
              isPosting: false,
              onMethodChanged: (value) => selectedMethod = value,
              onPickDate: () => pickedDate = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payment Reference'), findsOneWidget);
    expect(find.text('RUN-001'), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.text('05/31/2026'), findsOneWidget);

    await tester.tap(find.text('05/31/2026'));
    await tester.pump();

    expect(pickedDate, isTrue);

    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();

    expect(selectedMethod, 'cash');
  });

  testWidgets('payment run quick select bar reports actions', (tester) async {
    var dueNow = 0;
    var nextSevenDays = 0;
    var allOpen = 0;
    var clear = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaymentRunQuickSelectBar(
            hasOpenBills: true,
            hasSelection: true,
            isPosting: false,
            onDueNow: () => dueNow++,
            onNextSevenDays: () => nextSevenDays++,
            onAllOpen: () => allOpen++,
            onClear: () => clear++,
          ),
        ),
      ),
    );

    expect(find.byType(AppActionButton), findsNWidgets(4));

    await tester.tap(find.text('Due Now'));
    await tester.tap(find.text('Next 7 Days'));
    await tester.tap(find.text('All Open'));
    await tester.tap(find.text('Clear'));
    await tester.pump();

    expect(dueNow, 1);
    expect(nextSevenDays, 1);
    expect(allOpen, 1);
    expect(clear, 1);
  });

  testWidgets('payment run bill picker uses shared empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 560,
            height: 260,
            child: PaymentRunBillPickerPanel(
              bills: const [],
              selectedBillIds: const {},
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
              isPosting: false,
              onBillSelectionChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No open payable bills'), findsOneWidget);
  });

  testWidgets('payment run bill picker reports bill selection', (tester) async {
    String? selectedBillId;
    bool? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 640,
            height: 220,
            child: PaymentRunBillPickerPanel(
              bills: [
                Invoice(
                  id: 'bill-1',
                  invoiceNumber: 'BILL-001',
                  vendorName: 'Acme Supplies',
                  dueDate: DateTime(2026, 5, 31),
                  amount: 125,
                ),
              ],
              selectedBillIds: const {},
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
              isPosting: false,
              onBillSelectionChanged: (billId, isSelected) {
                selectedBillId = billId;
                selectedValue = isSelected;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(PaymentRunBillTile), findsOneWidget);
    expect(find.byType(AppCheckboxRow), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);

    await tester.tap(find.text('BILL-001'));
    await tester.pump();

    expect(selectedBillId, 'bill-1');
    expect(selectedValue, isTrue);
  });

  testWidgets('payment run bill tile uses reusable checkbox row', (
    tester,
  ) async {
    bool? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentRunBillTile(
              bill: Invoice(
                id: 'bill-1',
                invoiceNumber: 'BILL-001',
                vendorName: 'Acme Supplies',
                dueDate: DateTime(2026, 5, 30),
                amount: 125,
              ),
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
              isSelected: false,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppCheckboxRow), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);
    expect(find.text('Acme Supplies - May 30, 2026'), findsOneWidget);
    expect(find.text('\$125.00'), findsOneWidget);

    await tester.tap(find.text('BILL-001'));
    await tester.pump();

    expect(selected, isTrue);
  });
}
