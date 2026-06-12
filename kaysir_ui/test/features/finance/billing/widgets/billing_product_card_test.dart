import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_card.dart';

void main() {
  testWidgets('BillingProductCard formats price with tenant preferences', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const product = Product(
      id: 'coffee',
      name: 'Coffee Bundle',
      price: 25000,
      category: 'Beverage',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 280,
              child: BillingProductCard(
                product: product,
                tenantId: 'tenant-a',
                preferences: const BillingTenantPreferences(
                  currencySymbol: 'Rp ',
                  decimalDigits: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Coffee Bundle'), findsOneWidget);
    expect(find.text('Rp 25,000'), findsOneWidget);

    await tester.tap(find.byTooltip('Add item'));
    await tester.pump();

    final cartItems = container.read(cartItemsForTenantProvider('tenant-a'));
    expect(cartItems, hasLength(1));
    expect(cartItems.single.product.id, 'coffee');
  });
}
