import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item_adapter.dart';

void main() {
  test('registry adapts domain values into invoice line items', () {
    final registry = BillingInvoiceLineItemAdapterRegistry(
      adapters: [
        BillingInvoiceLineItemAdapter(
          domain: 'construction',
          type: 'milestone',
          canAdapt: (value) => value is _Milestone,
          toLineItem: (value) {
            final milestone = value as _Milestone;
            return BillingInvoiceLineItem(
              id: milestone.id,
              description: milestone.name,
              quantity: 1,
              unitPrice: milestone.amount,
              unitLabel: 'milestone',
              source: BillingInvoiceLineItemSource(
                domain: 'construction',
                type: 'milestone',
                id: milestone.id,
              ),
            );
          },
        ),
      ],
    );

    final lineItem = registry.adapt(
      const _Milestone('phase-1', 'Foundation phase', 12000),
      domain: 'Construction',
      type: 'Milestone',
    );

    expect(lineItem.id, 'phase-1');
    expect(lineItem.unitLabel, 'milestone');
    expect(lineItem.source?.domain, 'construction');
    expect(lineItem.netSubtotal, 12000);
  });

  test('registry rejects missing duplicate and invalid adapters', () {
    final adapter = BillingInvoiceLineItemAdapter(
      domain: 'digital',
      type: 'subscription',
      canAdapt: (value) => value is _Subscription,
      toLineItem:
          (_) => const BillingInvoiceLineItem(
            id: '',
            description: '',
            quantity: 0,
            unitPrice: 0,
          ),
    );

    expect(
      () => BillingInvoiceLineItemAdapterRegistry(adapters: [adapter, adapter]),
      throwsStateError,
    );
    expect(
      () => BillingInvoiceLineItemAdapterRegistry(
        adapters: [adapter],
      ).adapt(const _Subscription()),
      throwsStateError,
    );
    expect(
      () =>
          BillingInvoiceLineItemAdapterRegistry().adapt(const _Subscription()),
      throwsStateError,
    );
  });
}

class _Milestone {
  final String id;
  final String name;
  final double amount;

  const _Milestone(this.id, this.name, this.amount);
}

class _Subscription {
  const _Subscription();
}
