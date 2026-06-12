import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cart_summary.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_order_summary.dart';

void main() {
  testWidgets('BillingOrderSummary renders subtotal discounts tax and total', (
    tester,
  ) async {
    final summary = summarizeBillingCart(const [
      BillingCartSummaryLine(
        id: 'plan',
        name: 'Business Plan',
        unitPrice: 100,
        quantity: 2,
      ),
    ], policy: const BillingPricingPolicy(taxRate: 0.1, discountRate: 0.25));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingOrderSummary(
            summary: summary,
            preferences: const BillingTenantPreferences(
              currencySymbol: 'Rp ',
              decimalDigits: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Rp 200'), findsOneWidget);
    expect(find.text('-Rp 50'), findsOneWidget);
    expect(find.text('Rp 15'), findsOneWidget);
    expect(find.text('Rp 165'), findsOneWidget);
  });
}
