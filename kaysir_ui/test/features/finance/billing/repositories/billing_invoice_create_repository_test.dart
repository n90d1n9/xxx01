import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_create_repository.dart';

void main() {
  test(
    'DemoBillingInvoiceCreateRepository resolves draft line item total',
    () async {
      final repository = DemoBillingInvoiceCreateRepository(
        latency: Duration.zero,
        clock: () => DateTime(2026, 5, 31),
      );
      final draft = BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 0,
        issueDate: DateTime(2026, 5, 31),
        lineItems: const [
          BillingInvoiceLineItem(
            id: 'seat-line',
            description: 'SaaS seats',
            quantity: 3,
            unitPrice: 100,
            taxRate: 0.1,
          ),
        ],
      );

      final invoice = await repository.createInvoice(draft);

      expect(invoice.amount, 330);
      expect(invoice.tenantId, 'tenant-a');
      expect(invoice.date, DateTime(2026, 5, 31));
    },
  );

  test('DemoBillingInvoiceCreateRepository honors draft tax mode', () async {
    final repository = DemoBillingInvoiceCreateRepository(
      latency: Duration.zero,
      clock: () => DateTime(2026, 5, 31),
    );
    final draft = BillingInvoiceDraft(
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

    final invoice = await repository.createInvoice(draft);

    expect(invoice.amount, 110);
  });
}
