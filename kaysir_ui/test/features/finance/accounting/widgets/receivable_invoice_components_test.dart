import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/customer.dart';
import 'package:kaysir/features/finance/accounting/widgets/receivable_invoice_components.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('receivable customer field reports selection changes', (
    tester,
  ) async {
    var selected = 'customer-1';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceivableInvoiceCustomerField(
            customers: [
              _customer('customer-1', 'Acme Foods'),
              _customer('customer-2', 'Globex Retail'),
            ],
            selectedCustomerId: selected,
            enabled: true,
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.text('Acme Foods'), findsOneWidget);

    await tester.tap(find.text('Acme Foods'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Globex Retail').last);
    await tester.pumpAndSettle();

    expect(selected, 'customer-2');
  });

  testWidgets('receivable date field reports taps', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceivableInvoiceDateField(
            label: 'Issue Date',
            date: DateTime(2026, 5, 31),
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('Issue Date'), findsOneWidget);
    expect(find.text('05/31/2026'), findsOneWidget);

    await tester.tap(find.byType(ReceivableInvoiceDateField));

    expect(taps, 1);
  });

  testWidgets('receivable preview panel summarizes invoice terms', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReceivableInvoicePreviewPanel(
            customerName: 'Acme Foods',
            reference: 'INV-001',
            amount: 1250,
            issueDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 5, 31),
            currency: NumberFormat.currency(locale: 'en_US', symbol: r'$'),
          ),
        ),
      ),
    );

    expect(find.text('Receivable Preview'), findsOneWidget);
    expect(find.text('INV-001'), findsOneWidget);
    expect(find.text('Acme Foods'), findsOneWidget);
    expect(find.text(r'$1,250.00'), findsOneWidget);
    expect(find.text('Net 30 days'), findsOneWidget);
    expect(find.text('05/31/2026'), findsOneWidget);
    expect(find.byType(AppInfoRow), findsNWidgets(2));
  });
}

Customer _customer(String id, String name) {
  return Customer(id: id, name: name, email: '$id@example.test', phone: '555');
}
