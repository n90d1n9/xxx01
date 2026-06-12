import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/models/vendor.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_provider.dart';
import 'package:kaysir/features/finance/accounting/states/paymen_proc_provider.dart';
import 'package:kaysir/features/finance/accounting/states/vendor_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/vendor_statement_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/vendor_statement_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('vendor statement dialog composes modern statement widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _vendorStatementDialog(
        vendors: [_vendor()],
        invoices: [
          Invoice(
            id: 'bill-1',
            vendorId: 'vendor-1',
            invoiceNumber: 'BILL-001',
            invoiceDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 5, 31),
            amount: 1000,
            description: 'Office supplies',
            vendorName: 'Acme Supplies',
          ),
        ],
        payments: [
          Payment(
            id: 'pay-1',
            invoiceId: 'bill-1',
            amount: 250,
            paymentDate: DateTime(2026, 5, 15),
            reference: 'PAY-001',
          ),
        ],
      ),
    );

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Vendor Statement'), findsOneWidget);
    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.byType(VendorStatementSummaryGrid), findsOneWidget);
    expect(find.byType(VendorStatementLineList), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('Acme Supplies'), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);
    expect(find.text('PAY-001'), findsOneWidget);
    expect(find.textContaining(r'Balance $750.00'), findsOneWidget);
  });

  testWidgets('vendor statement dialog shows empty state without vendors', (
    tester,
  ) async {
    await tester.pumpWidget(
      _vendorStatementDialog(
        vendors: const [],
        invoices: const [],
        payments: const [],
      ),
    );

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No vendors configured'), findsOneWidget);
    expect(find.byType(VendorStatementSummaryGrid), findsNothing);
  });
}

Widget _vendorStatementDialog({
  required List<Vendor> vendors,
  required List<Invoice> invoices,
  required List<Payment> payments,
}) {
  return ProviderScope(
    overrides: [
      vendorsProvider.overrideWith((ref) => _SeededVendors(vendors)),
      invoicesProvider.overrideWith((ref) => _SeededInvoices(invoices)),
      paymentsProvider.overrideWith((ref) => _SeededPayments(payments)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: VendorStatementDialog())),
    ),
  );
}

Vendor _vendor() {
  return Vendor(id: 'vendor-1', name: 'Acme Supplies', email: 'ap@acme.test');
}

class _SeededVendors extends VendorsNotifier {
  _SeededVendors(List<Vendor> vendors) {
    state = vendors;
  }
}

class _SeededInvoices extends InvoicesNotifier {
  _SeededInvoices(List<Invoice> invoices) {
    state = InvoiceState(invoices: invoices);
  }
}

class _SeededPayments extends PaymentsNotifier {
  _SeededPayments(List<Payment> payments) {
    state = payments;
  }
}
