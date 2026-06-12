import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_line_item_summary.dart';

void main() {
  test('summarizeBillingInvoiceLineItems totals mixed domain lines', () {
    final summary = summarizeBillingInvoiceLineItems([
      BillingInvoiceLineItem(
        id: 'coffee-beans',
        description: 'Retail coffee beans',
        quantity: 2,
        unitPrice: 100,
        discountAmount: 10,
        taxRate: 0.1,
        source: BillingInvoiceLineItemSource(
          domain: 'commerce',
          type: 'product',
          id: 'sku-coffee',
        ),
      ),
      BillingInvoiceLineItem(
        id: 'foundation-milestone',
        description: 'Foundation milestone',
        quantity: 1,
        unitPrice: 50,
        taxable: false,
        source: BillingInvoiceLineItemSource(
          domain: 'construction',
          type: 'milestone',
          id: 'phase-1',
        ),
      ),
      const BillingInvoiceLineItem(
        id: 'ignored',
        description: 'Ignored zero quantity line',
        quantity: 0,
        unitPrice: 1000,
      ),
    ]);

    expect(summary.lineCount, 2);
    expect(summary.quantity, 3);
    expect(summary.subtotal, 250);
    expect(summary.discount, 10);
    expect(summary.netSubtotal, 240);
    expect(summary.taxableSubtotal, 190);
    expect(summary.tax, 19);
    expect(summary.total, 259);
  });

  test(
    'summarizeBillingInvoiceLineItems supports inclusive and exempt tax',
    () {
      const lineItems = [
        BillingInvoiceLineItem(
          id: 'saas-seats',
          description: 'SaaS seats',
          quantity: 1,
          unitPrice: 110,
          taxRate: 0.1,
          unitLabel: 'seat',
        ),
      ];

      final inclusive = summarizeBillingInvoiceLineItems(
        lineItems,
        taxMode: BillingInvoiceTaxMode.inclusive,
      );
      final exempt = summarizeBillingInvoiceLineItems(
        lineItems,
        taxMode: BillingInvoiceTaxMode.exempt,
      );

      expect(inclusive.tax, closeTo(10, 0.001));
      expect(inclusive.total, 110);
      expect(exempt.tax, 0);
      expect(exempt.total, 110);
    },
  );

  test(
    'billingInvoiceDraftTotal falls back to amount or resolves line items',
    () {
      final amountOnly = BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 700,
        issueDate: DateTime(2026, 5, 31),
      );
      final lineItemDraft = BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 0,
        issueDate: DateTime(2026, 5, 31),
        lineItems: const [
          BillingInvoiceLineItem(
            id: 'subscription',
            description: 'Subscription seats',
            quantity: 2,
            unitPrice: 100,
            taxRate: 0.1,
          ),
        ],
      );

      expect(billingInvoiceDraftTotal(amountOnly), 700);
      expect(lineItemDraft.isValid, isTrue);
      expect(billingInvoiceDraftTotal(lineItemDraft), 220);
    },
  );

  test('billingInvoiceDraftTotal uses the draft tax mode by default', () {
    final inclusiveDraft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
      taxMode: BillingInvoiceTaxMode.inclusive,
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'subscription',
          description: 'Subscription seats',
          quantity: 1,
          unitPrice: 110,
          taxRate: 0.1,
        ),
      ],
    );

    expect(billingInvoiceDraftTotal(inclusiveDraft), 110);
    expect(
      billingInvoiceDraftTotal(
        inclusiveDraft,
        taxMode: BillingInvoiceTaxMode.exclusive,
      ),
      121,
    );
  });
}
