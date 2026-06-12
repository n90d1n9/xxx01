import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/customer.dart';
import 'package:kaysir/features/finance/accounting/widgets/add_invoice_dialog.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_invoice_components.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';

void main() {
  testWidgets('add invoice dialog composes reusable receivable widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(920, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_invoiceDialog(customers: [_customer()]));

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Create Customer Invoice'), findsOneWidget);
    expect(find.byType(ReceivableInvoiceCustomerField), findsOneWidget);
    expect(find.byType(ReceivableInvoiceDateField), findsNWidgets(2));
    expect(find.byType(ReceivableInvoicePreviewPanel), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('Acme Foods'), findsWidgets);
    expect(find.textContaining('INV-'), findsWidgets);

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '350');
    await tester.pump();

    expect(find.text(r'$350.00'), findsOneWidget);
    expect(find.text('Net 30 days'), findsOneWidget);
  });

  testWidgets('add invoice dialog validates amount before creating', (
    tester,
  ) async {
    await tester.pumpWidget(_invoiceDialog(customers: [_customer()]));

    await tester.tap(find.text('Create Invoice'));
    await tester.pump();

    expect(find.text('Please enter an amount'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '-5');
    await tester.tap(find.text('Create Invoice'));
    await tester.pump();

    expect(find.text('Amount must be greater than zero'), findsOneWidget);
  });

  testWidgets('add invoice dialog shows setup state without customers', (
    tester,
  ) async {
    await tester.pumpWidget(_invoiceDialog(customers: const []));

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('Customer setup incomplete'), findsOneWidget);
    expect(
      find.text('Add a customer record before creating receivable invoices.'),
      findsOneWidget,
    );
    expect(find.byType(ReceivableInvoiceCustomerField), findsNothing);
    expect(find.byType(ReceivableInvoicePreviewPanel), findsNothing);
  });
}

Widget _invoiceDialog({required List<Customer> customers}) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: AddInvoiceDialog(customers: customers)),
      ),
    ),
  );
}

Customer _customer() {
  return Customer(
    id: 'customer-1',
    name: 'Acme Foods',
    email: 'billing@acme.test',
    phone: '555-0100',
  );
}
