import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_cart_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cart_invoice_line_items.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_line_item_summary.dart';

void main() {
  test('billingCartItemToInvoiceLineItem maps commerce data to core lines', () {
    const item = CartItem(
      product: Product(
        id: 'sku-beans',
        name: 'Coffee beans',
        price: 45,
        category: 'Grocery',
      ),
      quantity: 2,
      tenantId: 'tenant-a',
    );

    final lineItem = billingCartItemToInvoiceLineItem(item, taxRate: 0.1);

    expect(lineItem.id, 'cart-tenant-a-sku-beans');
    expect(lineItem.description, 'Coffee beans');
    expect(lineItem.quantity, 2);
    expect(lineItem.unitPrice, 45);
    expect(lineItem.source?.domain, 'commerce');
    expect(lineItem.source?.type, 'cart_item');
    expect(lineItem.source?.attributes, {
      'tenantId': 'tenant-a',
      'category': 'Grocery',
    });

    final summary = summarizeBillingInvoiceLineItems([lineItem]);
    expect(summary.total, 99);
  });

  test(
    'cart adapter registry converts cart items through the registry seam',
    () {
      const item = CartItem(
        product: Product(
          id: 'hosting',
          name: 'Website hosting',
          price: 30,
          category: 'Digital',
        ),
        quantity: 3,
        tenantId: 'tenant-a',
      );

      final registry = billingCartLineItemAdapterRegistry(
        domain: 'digital',
        sourceType: 'subscription',
        taxRate: 0.11,
      );
      final lineItems = registry.adaptAll([item], domain: 'digital');

      expect(lineItems, hasLength(1));
      expect(lineItems.single.source?.domain, 'digital');
      expect(lineItems.single.source?.type, 'subscription');
      expect(
        summarizeBillingInvoiceLineItems(lineItems).total,
        closeTo(99.9, 0.001),
      );
    },
  );

  test('cart adapter accepts reusable business domain profiles', () {
    const item = CartItem(
      product: Product(
        id: 'plan-pro',
        name: 'Pro plan',
        price: 110,
        category: 'Subscription',
      ),
      quantity: 1,
      tenantId: 'tenant-a',
    );
    final profile = digitalSubscriptionBillingDomainProfile(
      taxRate: 0.1,
      taxMode: BillingInvoiceTaxMode.inclusive,
    );

    final lineItems = billingCartItemsToInvoiceLineItems(const [
      item,
    ], profile: profile);
    final summary = summarizeBillingInvoiceLineItems(
      lineItems,
      taxMode: profile.taxMode,
    );

    expect(lineItems.single.source?.domain, 'digital');
    expect(lineItems.single.source?.type, 'subscription');
    expect(summary.tax, closeTo(10, 0.001));
    expect(summary.total, 110);
  });
}
