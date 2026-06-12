import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_action.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_action_result_sheet.dart';

void main() {
  testWidgets('BillingInvoiceActionResultPanel shows collection result facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceActionResultPanel(
            result: _result(BillingInvoiceActionType.collectPayment),
            tenantName: 'Acme Corp',
            preferences: const BillingTenantPreferences(
              datePattern: 'yyyy-MM-dd',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payment Collection Started'), findsOneWidget);
    expect(find.text('The receivable workflow is now moving.'), findsOneWidget);
    expect(
      find.text('Payment collection started for inv-101.'),
      findsOneWidget,
    );
    expect(find.text('inv-101'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('2026-05-31'), findsOneWidget);
    expect(
      find.text('Review settlement, then reconcile when funds arrive.'),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('BillingInvoiceActionResultPanel adapts copy by action type', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceActionResultPanel(
            result: _result(BillingInvoiceActionType.sendReminder),
          ),
        ),
      ),
    );

    expect(find.text('Reminder Queued'), findsOneWidget);
    expect(find.text('The customer follow-up is ready.'), findsOneWidget);
    expect(
      find.text('Monitor replies and follow up if the balance stays open.'),
      findsOneWidget,
    );
    expect(find.text('Tenant'), findsNothing);
  });
}

BillingInvoiceActionResult _result(BillingInvoiceActionType type) {
  return BillingInvoiceActionResult(
    type: type,
    invoiceId: 'inv-101',
    message: switch (type) {
      BillingInvoiceActionType.collectPayment =>
        'Payment collection started for inv-101.',
      BillingInvoiceActionType.sendReminder => 'Reminder queued for inv-101.',
      BillingInvoiceActionType.download => 'Invoice inv-101 is ready.',
    },
    completedAt: DateTime(2026, 5, 31),
  );
}
