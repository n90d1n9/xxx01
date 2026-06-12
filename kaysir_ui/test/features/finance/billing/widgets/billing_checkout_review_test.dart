import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_cart_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cart_summary.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_checkout_review.dart';

void main() {
  testWidgets('BillingCheckoutReview renders tenant items and summary', (
    tester,
  ) async {
    const preferences = BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
    );
    const items = [
      CartItem(
        product: Product(
          id: 'coffee',
          name: 'Coffee Bundle',
          price: 25000,
          category: 'Beverage',
        ),
        quantity: 2,
        tenantId: 'tenant-a',
      ),
    ];
    final summary = summarizeBillingCart(
      items.map(
        (item) => BillingCartSummaryLine(
          id: item.product.id,
          name: item.product.name,
          unitPrice: item.product.price,
          quantity: item.quantity,
        ),
      ),
      policy: const BillingPricingPolicy(taxRate: 0.1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingCheckoutReview(
            tenantName: 'Kopi Sore',
            cartItems: items,
            summary: summary,
            preferences: preferences,
          ),
        ),
      ),
    );

    expect(find.text('Kopi Sore'), findsOneWidget);
    expect(find.text('Selected items'), findsOneWidget);
    expect(find.text('Coffee Bundle'), findsOneWidget);
    expect(find.text('2 x Rp 25,000'), findsOneWidget);
    expect(find.text('Rp 50,000'), findsWidgets);
    expect(find.text('Payment Summary'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Rp 55,000'), findsOneWidget);
  });

  testWidgets('BillingCheckoutReview renders empty item state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingCheckoutReview(
            tenantName: 'Acme Corp',
            cartItems: [],
            summary: BillingCartSummary(
              lineCount: 0,
              itemCount: 0,
              subtotal: 0,
              discount: 0,
              tax: 0,
              total: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('No items selected'), findsOneWidget);
    expect(find.text('Payment Summary'), findsOneWidget);
  });

  testWidgets('BillingCheckoutReview adapts to compact widths', (tester) async {
    const preferences = BillingTenantPreferences(
      currencySymbol: 'Rp ',
      decimalDigits: 0,
    );
    const items = [
      CartItem(
        product: Product(
          id: 'long-name',
          name: 'Very Long Product Bundle For Mobile Checkout Review',
          price: 125000,
          category: 'Service',
        ),
        quantity: 3,
        tenantId: 'tenant-a',
      ),
    ];
    final summary = summarizeBillingCart(
      items.map(
        (item) => BillingCartSummaryLine(
          id: item.product.id,
          name: item.product.name,
          unitPrice: item.product.price,
          quantity: item.quantity,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: BillingCheckoutReview(
                tenantName: 'Compact Tenant',
                cartItems: items,
                summary: summary,
                preferences: preferences,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Compact Tenant'), findsOneWidget);
    expect(
      find.text('Very Long Product Bundle For Mobile Checkout Review'),
      findsOneWidget,
    );
    expect(find.text('Rp 375,000'), findsWidgets);
  });
}
