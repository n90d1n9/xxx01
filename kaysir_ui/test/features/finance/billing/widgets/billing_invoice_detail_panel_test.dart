import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_action.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_detail_panel.dart';

void main() {
  testWidgets('BillingInvoiceDetailPanel shows formatted invoice facts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceDetailPanel(
            invoice: _invoice(),
            tenantName: 'Acme Corp',
            preferences: const BillingTenantPreferences(
              currencySymbol: 'Rp ',
              decimalDigits: 0,
              datePattern: 'yyyy-MM-dd',
              paymentTermsDays: 14,
              taxMode: BillingTaxMode.inclusive,
            ),
            activityNow: DateTime(2026, 6, 20),
          ),
        ),
      ),
    );

    expect(find.text('Invoice #inv-pending'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Rp 2,000'), findsOneWidget);
    expect(find.text('2026-06-10'), findsAtLeastNWidgets(1));
    expect(find.text('2026-06-24'), findsAtLeastNWidgets(1));
    expect(find.text('14 days'), findsOneWidget);
    expect(find.text('Inclusive'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Payment due soon'), findsOneWidget);
    expect(find.text('Collect Payment'), findsOneWidget);
  });

  testWidgets(
    'BillingInvoiceDetailPanel disables payment for closed invoices',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillingInvoiceDetailPanel(
              invoice: _invoice(status: BillingInvoiceStatus.paid),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Payment Closed'),
      );
      expect(button.onPressed, isNull);
    },
  );

  testWidgets('BillingInvoiceDetailPanel emits selected invoice actions', (
    tester,
  ) async {
    BillingInvoiceActionType? selectedType;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceDetailPanel(
            invoice: _invoice(),
            onActionSelected: (action) {
              selectedType = action.type;
            },
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Send Reminder'));
    await tester.tap(find.text('Send Reminder'));
    await tester.pump();

    expect(selectedType, BillingInvoiceActionType.sendReminder);
  });
}

BillingInvoice _invoice({
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: 'inv-pending',
    tenantId: 'tenant-test',
    amount: 2000,
    date: DateTime(2026, 6, 10),
    status: status,
  );
}
