import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/states/invoice_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_run_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/payable_payment_run_dialog.dart';
import 'package:kaysir/widgets/ui/app_dialog_actions.dart';

void main() {
  testWidgets('payment run dialog composes reusable picker controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _paymentRunDialog(
        invoices: [
          Invoice(
            id: 'bill-1',
            vendorId: 'vendor-1',
            invoiceNumber: 'BILL-001',
            invoiceDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 5, 31),
            amount: 125,
            vendorName: 'Acme Supplies',
          ),
        ],
      ),
    );

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('AP Payment Run'), findsOneWidget);
    expect(find.byType(PaymentRunSummaryPanel), findsOneWidget);
    expect(find.byType(PaymentRunControls), findsOneWidget);
    expect(find.byType(PaymentRunQuickSelectBar), findsOneWidget);
    expect(find.byType(PaymentRunBillPickerPanel), findsOneWidget);
    expect(find.byType(PaymentRunBillTile), findsOneWidget);
    expect(find.byType(AppDialogActions), findsOneWidget);
    expect(find.text('BILL-001'), findsOneWidget);

    await tester.tap(find.text('All Open'));
    await tester.pump();

    final checkbox = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checkbox.value, isTrue);
  });
}

Widget _paymentRunDialog({required List<Invoice> invoices}) {
  return ProviderScope(
    overrides: [
      invoicesProvider.overrideWith((ref) => _SeededInvoices(invoices)),
    ],
    child: const MaterialApp(
      home: Scaffold(body: Center(child: PayablePaymentRunDialog())),
    ),
  );
}

class _SeededInvoices extends InvoicesNotifier {
  _SeededInvoices(List<Invoice> invoices) {
    state = InvoiceState(invoices: invoices);
  }
}
