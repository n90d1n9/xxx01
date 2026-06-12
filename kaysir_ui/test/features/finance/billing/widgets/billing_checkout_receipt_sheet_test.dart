import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_checkout.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_checkout_receipt_sheet.dart';

void main() {
  testWidgets('BillingCheckoutReceiptPanel renders receipt facts', (
    tester,
  ) async {
    final receipt = BillingCheckoutReceipt(
      id: 'receipt-1',
      tenantId: 'tenant-a',
      tenantName: 'Acme Corp',
      total: 30000,
      itemCount: 2,
      createdAt: DateTime(2026, 5, 31),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingCheckoutReceiptPanel(
            receipt: receipt,
            preferences: const BillingTenantPreferences(
              currencySymbol: 'Rp ',
              decimalDigits: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Payment Complete'), findsOneWidget);
    expect(find.text('receipt-1'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Rp 30,000'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
