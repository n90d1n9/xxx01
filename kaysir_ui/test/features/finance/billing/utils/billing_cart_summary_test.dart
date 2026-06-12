import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cart_summary.dart';

void main() {
  test('summarizeBillingCart totals active lines with discounts and tax', () {
    final summary = summarizeBillingCart(const [
      BillingCartSummaryLine(
        id: 'plan',
        name: 'Business Plan',
        unitPrice: 100,
        quantity: 2,
      ),
      BillingCartSummaryLine(
        id: 'support',
        name: 'Support',
        unitPrice: 50,
        quantity: 1,
        taxable: false,
      ),
      BillingCartSummaryLine(
        id: 'ignored',
        name: 'Ignored',
        unitPrice: 1000,
        quantity: 0,
      ),
    ], policy: const BillingPricingPolicy(taxRate: 0.1, discountRate: 0.2));

    expect(summary.lineCount, 2);
    expect(summary.itemCount, 3);
    expect(summary.subtotal, 250);
    expect(summary.discount, 50);
    expect(summary.tax, 16);
    expect(summary.total, 216);
  });

  test('cart notifier exposes reusable billing summary', () {
    final notifier = CartNotifier();
    final product = Product(
      id: 'plan',
      name: 'Business Plan',
      price: 79.99,
      category: 'Subscription',
    );

    notifier.addToCart(product, 'tenant-1');
    notifier.addToCart(product, 'tenant-1');

    final summary = notifier.getSummary();

    expect(summary.lineCount, 1);
    expect(summary.itemCount, 2);
    expect(summary.total, closeTo(159.98, 0.001));
    expect(notifier.getItemCount(), 2);
    expect(notifier.getTotal(), closeTo(159.98, 0.001));
  });

  test('tenant cart providers isolate active tenant lines', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const plan = Product(
      id: 'plan',
      name: 'Business Plan',
      price: 79.99,
      category: 'Subscription',
    );
    const support = Product(
      id: 'support',
      name: 'Premium Support',
      price: 29.99,
      category: 'Service',
    );

    container.read(cartProvider.notifier).addToCart(plan, 'tenant-a');
    container.read(cartProvider.notifier).addToCart(plan, 'tenant-a');
    container.read(cartProvider.notifier).addToCart(support, 'tenant-b');

    final tenantItems = container.read(cartItemsForTenantProvider('tenant-a'));
    final tenantSummary = container.read(
      cartSummaryForTenantProvider('tenant-a'),
    );

    expect(tenantItems.map((item) => item.tenantId).toSet(), {'tenant-a'});
    expect(tenantSummary.itemCount, 2);
    expect(tenantSummary.total, closeTo(159.98, 0.001));
  });
}
