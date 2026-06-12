import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_collection.dart';

void main() {
  test(
    'mergeBillingInvoices keeps confirmed invoices ahead of local overlays',
    () {
      final merged = mergeBillingInvoices(
        [
          _invoice(id: 'inv-001', amount: 100),
          _invoice(id: 'inv-002', amount: 200),
        ],
        [
          _invoice(id: 'inv-002', amount: 250),
          _invoice(id: 'inv-003', amount: 300),
        ],
      );

      expect(merged.map((invoice) => invoice.id), [
        'inv-001',
        'inv-002',
        'inv-003',
      ]);
      expect(
        merged.firstWhere((invoice) => invoice.id == 'inv-002').amount,
        200,
      );
    },
  );

  test('unconfirmedBillingInvoiceOverlay removes confirmed invoice ids', () {
    final unconfirmed = unconfirmedBillingInvoiceOverlay(
      [
        _invoice(id: 'inv-001', amount: 100),
        _invoice(id: 'inv-local', amount: 400),
      ],
      confirmedInvoices: [_invoice(id: 'inv-001', amount: 100)],
    );

    expect(unconfirmed.map((invoice) => invoice.id), ['inv-local']);
  });

  test('filterBillingInvoices searches invoice ids and status labels', () {
    final invoices = _invoices();

    final byId = filterBillingInvoices(invoices, query: '003');
    final byStatus = filterBillingInvoices(invoices, query: 'overdue');

    expect(byId.map((invoice) => invoice.id), ['inv-003']);
    expect(byStatus.map((invoice) => invoice.id), ['inv-002']);
  });

  test('filterBillingInvoices filters by status and sorts by amount', () {
    final invoices = _invoices();

    final filtered = filterBillingInvoices(
      invoices,
      status: BillingInvoiceStatus.pending,
      sort: BillingInvoiceSortOption.amountHighToLow,
    );

    expect(filtered.map((invoice) => invoice.id), ['inv-003', 'inv-001']);
  });

  test('filterBillingInvoices defaults to newest first', () {
    final invoices = _invoices();

    final filtered = filterBillingInvoices(invoices);

    expect(filtered.map((invoice) => invoice.id), [
      'inv-003',
      'inv-002',
      'inv-001',
    ]);
  });
}

List<BillingInvoice> _invoices() {
  return [
    _invoice(id: 'inv-001', amount: 120, date: DateTime(2026, 1)),
    _invoice(
      id: 'inv-002',
      amount: 480,
      date: DateTime(2026, 2),
      status: BillingInvoiceStatus.overdue,
    ),
    _invoice(id: 'inv-003', amount: 960, date: DateTime(2026, 3)),
  ];
}

BillingInvoice _invoice({
  required String id,
  required double amount,
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: date ?? DateTime(2026, 1),
    status: status,
  );
}
