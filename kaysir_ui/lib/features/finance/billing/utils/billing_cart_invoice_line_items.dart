import '../models/billing_cart_item.dart';
import '../models/billing_business_domain_profile.dart';
import '../models/billing_invoice_line_item.dart';
import '../models/billing_invoice_line_item_adapter.dart';

BillingInvoiceLineItem billingCartItemToInvoiceLineItem(
  CartItem item, {
  BillingBusinessDomainProfile? profile,
  String domain = 'commerce',
  String sourceType = 'cart_item',
  bool taxable = true,
  double taxRate = 0,
}) {
  final effectiveDomain = profile?.domain ?? domain;
  final effectiveSourceType = profile?.defaultSourceType ?? sourceType;
  final effectiveTaxable = profile?.taxable ?? taxable;
  final effectiveTaxRate = profile?.taxRate ?? taxRate;

  return BillingInvoiceLineItem(
    id: 'cart-${item.tenantId}-${item.product.id}',
    description: item.product.name,
    quantity: item.quantity.toDouble(),
    unitPrice: item.product.price,
    unitLabel: 'item',
    taxable: effectiveTaxable,
    taxRate: effectiveTaxRate,
    source: BillingInvoiceLineItemSource(
      domain: effectiveDomain,
      type: effectiveSourceType,
      id: item.product.id,
      attributes: {
        'tenantId': item.tenantId,
        'category': item.product.category,
      },
    ),
  );
}

List<BillingInvoiceLineItem> billingCartItemsToInvoiceLineItems(
  Iterable<CartItem> items, {
  BillingBusinessDomainProfile? profile,
  String domain = 'commerce',
  String sourceType = 'cart_item',
  bool taxable = true,
  double taxRate = 0,
}) {
  return List.unmodifiable(
    items.map(
      (item) => billingCartItemToInvoiceLineItem(
        item,
        profile: profile,
        domain: domain,
        sourceType: sourceType,
        taxable: taxable,
        taxRate: taxRate,
      ),
    ),
  );
}

BillingInvoiceLineItemAdapter billingCartLineItemAdapter({
  BillingBusinessDomainProfile? profile,
  String domain = 'commerce',
  String sourceType = 'cart_item',
  bool taxable = true,
  double taxRate = 0,
}) {
  final effectiveDomain = profile?.domain ?? domain;
  final effectiveSourceType = profile?.defaultSourceType ?? sourceType;

  return BillingInvoiceLineItemAdapter(
    domain: effectiveDomain,
    type: effectiveSourceType,
    canAdapt: (value) => value is CartItem,
    toLineItem:
        (value) => billingCartItemToInvoiceLineItem(
          value as CartItem,
          profile: profile,
          domain: domain,
          sourceType: sourceType,
          taxable: taxable,
          taxRate: taxRate,
        ),
  );
}

BillingInvoiceLineItemAdapterRegistry billingCartLineItemAdapterRegistry({
  BillingBusinessDomainProfile? profile,
  String domain = 'commerce',
  String sourceType = 'cart_item',
  bool taxable = true,
  double taxRate = 0,
}) {
  return BillingInvoiceLineItemAdapterRegistry(
    adapters: [
      billingCartLineItemAdapter(
        profile: profile,
        domain: domain,
        sourceType: sourceType,
        taxable: taxable,
        taxRate: taxRate,
      ),
    ],
  );
}
