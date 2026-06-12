import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  testWidgets('payable payment dialog composes reusable posting widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_paymentDialog(bill: _bill()));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Pay Bill BILL-001'), findsOneWidget);
    expect(find.byType(PayablePaymentBalancePanel), findsOneWidget);
    expect(find.byType(PayablePaymentMethodField), findsOneWidget);
    expect(find.byType(PayablePaymentDateField), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('Acme Supplies'), findsWidgets);
    expect(find.text(r'$750.00'), findsOneWidget);
    expect(find.text('PAY-BILL-001'), findsOneWidget);
  });

  testWidgets('payable payment dialog validates overpayments', (tester) async {
    await tester.pumpWidget(_paymentDialog(bill: _bill()));

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

Widget _paymentDialog({required Invoice bill}) {
  return ProviderScope(
    overrides: [
      invoicesProvider.overrideWith((ref) => _SeededInvoices([bill])),
    ],
    child: MaterialApp(
      home: Scaffold(body: Center(child: PayablePaymentDialog(bill: bill))),
    ),
  );
}

Invoice _bill() {
  return Invoice(
    id: 'bill-1',
    vendorId: 'vendor-1',
    vendorName: 'Acme Supplies',
    invoiceNumber: 'BILL-001',
    invoiceDate: DateTime(2026, 5, 1),
    dueDate: DateTime(2026, 5, 31),
    amount: 1000,
    payments: [
      Payment(
        id: 'payment-1',
        invoiceId: 'bill-1',
        amount: 250,
        paymentDate: DateTime(2026, 5, 10),
      ),
    ],
  );
}

class _SeededInvoices extends InvoicesNotifier {
  _SeededInvoices(List<Invoice> invoices) {
    state = InvoiceState(invoices: invoices);
  }
}
