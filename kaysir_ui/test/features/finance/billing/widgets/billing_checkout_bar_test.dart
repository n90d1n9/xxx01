import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_checkout_bar.dart';

void main() {
  testWidgets('BillingCheckoutBar formats total with tenant preferences', (
    tester,
  ) async {
    var checkoutCount = 0;
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(cartProvider.notifier)
        .addToCart(
          const Product(
            id: 'support',
            name: 'Premium Support',
            price: 30000,
            category: 'Service',
          ),
          'tenant-a',
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BillingCheckoutBar(
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
    );

    expect(find.text('Rp 30,000'), findsOneWidget);
    expect(find.text('Checkout (1)'), findsOneWidget);

    await tester.tap(find.text('Checkout (1)'));
    await tester.pump();

    expect(checkoutCount, 1);
  });
}
