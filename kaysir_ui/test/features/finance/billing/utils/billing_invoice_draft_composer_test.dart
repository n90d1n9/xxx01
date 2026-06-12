import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_cart_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_profiles.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cart_invoice_line_items.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_draft_composer.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_line_item_summary.dart';

void main() {
  test('composeBillingInvoiceDraft creates profile-aware line item drafts', () {
    final profile = digitalSubscriptionBillingDomainProfile(
      taxRate: 0.1,
      taxMode: BillingInvoiceTaxMode.inclusive,
    );

    final draft = composeBillingInvoiceDraft(
      tenantId: 'tenant-a',
      issueDate: DateTime(2026, 5, 31),
      profile: profile,
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'plan-pro',
          description: 'Pro plan',
          quantity: 1,
          unitPrice: 110,
          taxRate: 0.1,
        ),
      ],
    );

    expect(draft.amount, 110);
    expect(draft.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(draft.lineItems, hasLength(1));
    expect(billingInvoiceDraftTotal(draft), 110);
  });

  test('composeBillingInvoiceDraft preserves amount-only drafts', () {
    final draft = composeBillingInvoiceDraft(
      tenantId: 'tenant-a',
      issueDate: DateTime(2026, 5, 31),
      amount: 900,
    );

    expect(draft.amount, 900);
    expect(draft.lineItems, isEmpty);
    expect(draft.taxMode, BillingInvoiceTaxMode.exclusive);
    expect(billingInvoiceDraftTotal(draft), 900);
  });

  test('composeBillingInvoiceDraftFromValues adapts domain values', () {
    final profile = digitalSubscriptionBillingDomainProfile(
      taxRate: 0.1,
      taxMode: BillingInvoiceTaxMode.inclusive,
    );
    const cartItem = CartItem(
      product: Product(
        id: 'plan-pro',
        name: 'Pro plan',
        price: 110,
        category: 'Subscription',
      ),
      quantity: 2,
      tenantId: 'tenant-a',
    );

    final draft = composeBillingInvoiceDraftFromValues(
      tenantId: 'tenant-a',
      issueDate: DateTime(2026, 5, 31),
      values: const [cartItem],
      profile: profile,
      adapterRegistry: billingCartLineItemAdapterRegistry(profile: profile),
    );

    expect(draft.amount, 220);
    expect(draft.taxMode, BillingInvoiceTaxMode.inclusive);
    expect(draft.lineItems.single.source?.domain, 'digital');
    expect(draft.lineItems.single.source?.type, 'subscription');
    expect(draft.lineItems.single.taxRate, 0.1);
  });
}
