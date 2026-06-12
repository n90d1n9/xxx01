import '../models/billing_invoice.dart';
import '../models/billing_invoice_filter.dart';
import '../models/billing_invoice_status.dart';

List<BillingInvoice> mergeBillingInvoices(
  Iterable<BillingInvoice> invoices,
  Iterable<BillingInvoice> overlayInvoices,
) {
  return List.unmodifiable([
    ...invoices,
    ...unconfirmedBillingInvoiceOverlay(
      overlayInvoices,
      confirmedInvoices: invoices,
    ),
  ]);
}

List<BillingInvoice> unconfirmedBillingInvoiceOverlay(
  Iterable<BillingInvoice> overlayInvoices, {
  required Iterable<BillingInvoice> confirmedInvoices,
}) {
  final confirmedInvoiceIds = {
    for (final invoice in confirmedInvoices) invoice.id,
  };

  return List.unmodifiable(
    overlayInvoices.where(
      (invoice) => !confirmedInvoiceIds.contains(invoice.id),
    ),
  );
}

List<BillingInvoice> filterBillingInvoices(
  Iterable<BillingInvoice> invoices, {
  String query = '',
  BillingInvoiceStatus? status,
  BillingInvoiceSortOption sort = BillingInvoiceSortOption.newestFirst,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  final filtered =
      invoices.where((invoice) {
        final matchesStatus = status == null || invoice.status == status;
        final matchesQuery =
            normalizedQuery.isEmpty ||
            _invoiceSearchText(invoice).contains(normalizedQuery);

        return matchesStatus && matchesQuery;
      }).toList();

  filtered.sort((a, b) {
    final comparison = switch (sort) {
      BillingInvoiceSortOption.newestFirst => b.date.compareTo(a.date),
      BillingInvoiceSortOption.oldestFirst => a.date.compareTo(b.date),
      BillingInvoiceSortOption.amountHighToLow => b.amount.compareTo(a.amount),
      BillingInvoiceSortOption.amountLowToHigh => a.amount.compareTo(b.amount),
    };

    if (comparison != 0) return comparison;
    return a.id.compareTo(b.id);
  });

  return List.unmodifiable(filtered);
}

String _invoiceSearchText(BillingInvoice invoice) {
  final dateKey = [
    invoice.date.year.toString().padLeft(4, '0'),
    invoice.date.month.toString().padLeft(2, '0'),
    invoice.date.day.toString().padLeft(2, '0'),
  ].join('-');

  return [
    invoice.id,
    invoice.tenantId,
    invoice.status.label,
    invoice.amount.toStringAsFixed(2),
    dateKey,
  ].join(' ').toLowerCase();
}
