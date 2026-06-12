import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';

void main() {
  test('BillingInvoiceLineItemSource keeps domain metadata immutable', () {
    final source = BillingInvoiceLineItemSource(
      domain: 'commerce',
      type: 'product',
      id: 'sku-espresso',
      attributes: const {'channel': 'marketplace'},
    );

    expect(source.isValid, isTrue);
    expect(source.attributes, {'channel': 'marketplace'});
    expect(
      () => source.attributes['channel'] = 'walk-in',
      throwsUnsupportedError,
    );
  });

  test('BillingInvoiceLineItem calculates reusable line totals', () {
    const lineItem = BillingInvoiceLineItem(
      id: 'seat-line',
      description: 'Team subscription seats',
      quantity: 5,
      unitPrice: 20,
      discountAmount: 15,
      taxRate: 0.11,
      unitLabel: 'seat',
    );

    expect(lineItem.subtotal, 100);
    expect(lineItem.discount, 15);
    expect(lineItem.netSubtotal, 85);
    expect(lineItem.isValid, isTrue);
  });

  test('BillingInvoiceLineItem validates source and service period data', () {
    final lineItem = BillingInvoiceLineItem(
      id: '',
      description: '',
      quantity: 0,
      unitPrice: -1,
      discountAmount: -1,
      taxRate: 1.5,
      source: BillingInvoiceLineItemSource(domain: '', type: '', id: ''),
      servicePeriodStart: DateTime(2026, 6),
      servicePeriodEnd: DateTime(2026, 5),
    );

    expect(lineItem.isValid, isFalse);
    expect(lineItem.validationErrors, [
      'Line item id is required.',
      'Line item description is required.',
      'Line item quantity must be greater than zero.',
      'Line item unit price cannot be negative.',
      'Line item discount cannot be negative.',
      'Line item tax rate must be between 0 and 1.',
      'Line item service period end cannot be before its start.',
      'Line item source domain is required.',
      'Line item source type is required.',
      'Line item source id is required.',
    ]);
  });
}
