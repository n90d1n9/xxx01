import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_cart_panel.dart';

void main() {
  testWidgets('BillingCartPanel renders cart actions and clears tenant cart', (
    tester,
  ) async {
    var checkoutCount = 0;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const product = Product(
      id: 'plan',
      name: 'Business Plan',
      price: 25000,
      category: 'Subscription',
    );

    container.read(cartProvider.notifier).addToCart(product, 'tenant-a');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 520,
              child: BillingCartPanel(
                tenantId: 'tenant-a',
                preferences: const BillingTenantPreferences(
                  currencySymbol: 'Rp ',
                  decimalDigits: 0,
                ),
                onCheckout: () {
                  checkoutCount++;
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Business Plan'), findsOneWidget);
    expect(find.text('Rp 25,000 per unit'), findsOneWidget);
    expect(find.text('Cart Summary'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsOneWidget);

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pump();

    expect(checkoutCount, 1);

    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(container.read(cartItemsForTenantProvider('tenant-a')), isEmpty);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
