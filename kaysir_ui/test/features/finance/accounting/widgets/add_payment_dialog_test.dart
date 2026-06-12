import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/widgets/add_payment_dialog.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_payment_components.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  testWidgets('add payment dialog composes reusable receivable widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_paymentDialog(invoice: _invoice()));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Record Payment INV-001'), findsOneWidget);
    expect(find.byType(ReceivablePaymentBalancePanel), findsOneWidget);
    expect(find.byType(ReceivablePaymentMethodField), findsOneWidget);
    expect(find.byType(ReceivablePaymentDateField), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('Customer cust-1'), findsWidgets);
    expect(find.text(r'$750.00'), findsOneWidget);
    expect(find.text('RCPT-INV-001'), findsOneWidget);
  });

  testWidgets('add payment dialog validates overpayments', (tester) async {
    await tester.pumpWidget(_paymentDialog(invoice: _invoice()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Payment Amount'),
      '900',
    );
    await tester.tap(find.text('Post Payment'));
    await tester.pump();

    expect(
      find.text('Amount cannot exceed outstanding balance'),
      findsOneWidget,
    );
  });
}

Widget _paymentDialog({required Invoice invoice}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: AddPaymentDialog(invoice: invoice, outstandingAmount: 750),
        ),
      ),
    ),
  );
}

Invoice _invoice() {
  return Invoice(
    id: 'invoice-1',
    customerId: 'cust-1',
    reference: 'INV-001',
    issueDate: DateTime(2026, 5, 1),
    dueDate: DateTime(2026, 5, 31),
    amount: 1000,
    status: InvoiceStatus.partiallyPaid,
  );
}
