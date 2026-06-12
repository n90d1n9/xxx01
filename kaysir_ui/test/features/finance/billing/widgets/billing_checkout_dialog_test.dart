import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_checkout.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_checkout_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_checkout_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_checkout_dialog.dart';

void main() {
  testWidgets('BillingCheckoutDialog submits checkout and closes', (
    tester,
  ) async {
    final repository = _FakeBillingCheckoutRepository();
    final container = ProviderContainer(
      overrides: [
        billingCheckoutRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    container.read(currentTenantProvider.notifier).state = const Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      preferences: BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
      ),
    );
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
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed:
                      () => showBillingCheckoutDialog(
                        context,
                        preferences: const BillingTenantPreferences(
                          currencySymbol: 'Rp ',
                          decimalDigits: 0,
                        ),
                      ),
                  child: const Text('Open checkout'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Purchase'), findsOneWidget);
    expect(find.text('Acme Corp'), findsOneWidget);
    expect(find.text('Premium Support'), findsOneWidget);
    expect(find.text('1 x Rp 30,000'), findsOneWidget);
    expect(find.text('Payment Summary'), findsOneWidget);
    expect(find.text('Subtotal'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(repository.requests, hasLength(1));
    expect(container.read(cartProvider), isEmpty);
    expect(find.text('Confirm Purchase'), findsNothing);
    expect(find.text('Payment Complete'), findsOneWidget);
    expect(find.text('receipt-1'), findsOneWidget);
    expect(find.text('Rp 30,000'), findsOneWidget);
  });
}

class _FakeBillingCheckoutRepository implements BillingCheckoutRepository {
  final requests = <BillingCheckoutRequest>[];

  @override
  Future<BillingCheckoutReceipt> submitCheckout(
    BillingCheckoutRequest request,
  ) async {
    requests.add(request);
    return BillingCheckoutReceipt(
      id: 'receipt-${requests.length}',
      tenantId: request.tenantId,
      tenantName: request.tenantName,
      total: request.total,
      itemCount: request.itemCount,
      createdAt: DateTime(2026, 5, 31),
    );
  }
}
