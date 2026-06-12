import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_action.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_action_bar.dart';

void main() {
  testWidgets('BillingInvoiceActionBar emits selected actions', (tester) async {
    BillingInvoiceActionType? selectedType;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceActionBar(
            actions: const [
              BillingInvoiceAction(
                type: BillingInvoiceActionType.collectPayment,
                label: 'Collect Payment',
                style: BillingInvoiceActionStyle.primary,
              ),
              BillingInvoiceAction(
                type: BillingInvoiceActionType.download,
                label: 'Download',
                style: BillingInvoiceActionStyle.secondary,
              ),
            ],
            onActionSelected: (action) {
              selectedType = action.type;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Download'));
    await tester.pump();

    expect(selectedType, BillingInvoiceActionType.download);
  });

  testWidgets('BillingInvoiceActionBar disables inactive actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingInvoiceActionBar(
            actions: [
              BillingInvoiceAction(
                type: BillingInvoiceActionType.collectPayment,
                label: 'Payment Closed',
                style: BillingInvoiceActionStyle.primary,
                enabled: false,
              ),
            ],
          ),
        ),
      ),
    );

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Payment Closed'),
    );
    expect(button.onPressed, isNull);
  });
}
