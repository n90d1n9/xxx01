import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_tax_mode.dart';

void main() {
  test('BillingInvoiceDraft validates tenant and amount', () {
    final draft = BillingInvoiceDraft(
      tenantId: '',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
    );

    expect(draft.isValid, isFalse);
    expect(draft.validationErrors, [
      'Choose a tenant before creating an invoice.',
      'Enter an invoice amount greater than zero.',
    ]);
  });

  test('BillingInvoiceDraft copyWith preserves stable values', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 1000,
      issueDate: DateTime(2026, 5, 31),
    );

    final updated = draft.copyWith(amount: 2500);

    expect(updated.tenantId, 'tenant-a');
    expect(updated.amount, 2500);
    expect(updated.issueDate, DateTime(2026, 5, 31));
    expect(updated.lineItems, isEmpty);
    expect(updated.taxMode, BillingInvoiceTaxMode.exclusive);
    expect(updated.isValid, isTrue);
  });

  test('BillingInvoiceDraft can be driven by reusable line items', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'project-milestone',
          description: 'Project milestone',
          quantity: 1,
          unitPrice: 5000,
        ),
      ],
    );

    final updated = draft.copyWith(
      lineItems: [
        ...draft.lineItems,
        const BillingInvoiceLineItem(
          id: 'support-retainer',
          description: 'Support retainer',
          quantity: 1,
          unitPrice: 750,
        ),
      ],
    );

    expect(draft.hasLineItems, isTrue);
    expect(draft.isValid, isTrue);
    expect(updated.lineItems.map((lineItem) => lineItem.id), [
      'project-milestone',
      'support-retainer',
    ]);
    expect(
      () => draft.lineItems.add(updated.lineItems.last),
      throwsUnsupportedError,
    );
  });

  test('BillingInvoiceDraft preserves tax mode through copyWith', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 110,
      issueDate: DateTime(2026, 5, 31),
      taxMode: BillingInvoiceTaxMode.inclusive,
    );

    final updated = draft.copyWith(amount: 220);

    expect(updated.amount, 220);
    expect(updated.taxMode, BillingInvoiceTaxMode.inclusive);
  });
}
