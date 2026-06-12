import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_payment_components.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('receivable payment balance panel renders invoice context', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: ReceivablePaymentBalancePanel(
              invoiceReference: 'INV-001',
              customerLabel: 'Customer cust-1',
              outstandingAmount: 750,
              currency: NumberFormat.simpleCurrency(decimalDigits: 2),
            ),
          ),
        ),
      ),
    );

    expect(find.text('INV-001'), findsOneWidget);
    expect(find.text('Customer cust-1'), findsOneWidget);
    expect(find.text(r'$750.00'), findsOneWidget);
    expect(find.text('Receivable'), findsOneWidget);
  });

  testWidgets('receivable payment method field reports selection changes', (
    tester,
  ) async {
    String? selectedMethod;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: ReceivablePaymentMethodField(
              method: 'bank_transfer',
              enabled: true,
              onChanged: (value) => selectedMethod = value,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);

    await tester.tap(find.text('Bank Transfer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Credit Card').last);
    await tester.pumpAndSettle();

    expect(selectedMethod, 'credit_card');
  });

  testWidgets('receivable payment date field reports taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: ReceivablePaymentDateField(
              paymentDate: DateTime(2026, 5, 31),
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppInfoRow), findsOneWidget);
    expect(find.text('Payment Date'), findsOneWidget);
    expect(find.text('05/31/2026'), findsOneWidget);

    await tester.tap(find.text('05/31/2026'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
