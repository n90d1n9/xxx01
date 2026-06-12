import 'billing_invoice_status.dart';

enum BillingInvoiceSortOption {
  newestFirst,
  oldestFirst,
  amountHighToLow,
  amountLowToHigh,
}

extension BillingInvoiceSortOptionX on BillingInvoiceSortOption {
  String get label {
    switch (this) {
      case BillingInvoiceSortOption.newestFirst:
        return 'Newest first';
      case BillingInvoiceSortOption.oldestFirst:
        return 'Oldest first';
      case BillingInvoiceSortOption.amountHighToLow:
        return 'Amount high to low';
      case BillingInvoiceSortOption.amountLowToHigh:
        return 'Amount low to high';
    }
  }
}

class BillingInvoiceFilter {
  final String query;
  final BillingInvoiceStatus? status;
  final BillingInvoiceSortOption sort;

  const BillingInvoiceFilter({
    this.query = '',
    this.status,
    this.sort = BillingInvoiceSortOption.newestFirst,
  });

  bool get hasActiveFilters {
    return query.trim().isNotEmpty ||
        status != null ||
        sort != BillingInvoiceSortOption.newestFirst;
  }

  BillingInvoiceFilter withQuery(String value) {
    return BillingInvoiceFilter(query: value, status: status, sort: sort);
  }

  BillingInvoiceFilter withStatus(BillingInvoiceStatus? value) {
    return BillingInvoiceFilter(query: query, status: value, sort: sort);
  }

  BillingInvoiceFilter withSort(BillingInvoiceSortOption value) {
    return BillingInvoiceFilter(query: query, status: status, sort: value);
  }

  BillingInvoiceFilter reset() {
    return const BillingInvoiceFilter();
  }
}
