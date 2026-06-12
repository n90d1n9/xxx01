import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/invoice.dart';
import 'invoice_provider.dart';
import 'customer_provider.dart';

final selectedFilterProvider = StateProvider<String>((ref) => 'all');
final receivableStatusFilterProvider = StateProvider<String>((ref) => 'all');
final receivableSearchProvider = StateProvider<String>((ref) => '');
final receivableSortProvider = StateProvider<ReceivableSort>(
  (ref) => ReceivableSort.dueDateAsc,
);

enum ReceivableSort { dueDateAsc, dueDateDesc, amountDesc, customerName }

final filteredInvoicesProvider = Provider<AsyncValue<List<Invoice>>>((ref) {
  final invoices = ref.watch(invoicesProvider).invoices;
  final customers = ref.watch(customersProvider);
  final filter = ref.watch(receivableStatusFilterProvider);
  final searchTerm = ref.watch(receivableSearchProvider).trim().toLowerCase();
  final sort = ref.watch(receivableSortProvider);

  final customerById = {
    for (final customer in customers) customer.id: customer,
  };

  final filtered =
      invoices.where((invoice) {
        if (invoice.customerId == null || invoice.dueDate == null) {
          return false;
        }

        final statusMatches = switch (filter) {
          'paid' => invoice.status == InvoiceStatus.paid,
          'partial' => invoice.status == InvoiceStatus.partiallyPaid,
          'pending' => invoice.status == InvoiceStatus.pending,
          'overdue' =>
            invoice.isOverdue || invoice.status == InvoiceStatus.overdue,
          _ => true,
        };

        if (!statusMatches) {
          return false;
        }

        if (searchTerm.isEmpty) {
          return true;
        }

        final customer = customerById[invoice.customerId];
        final searchableText =
            [
              invoice.id,
              invoice.invoiceNumber,
              invoice.reference,
              invoice.description,
              customer?.name,
              customer?.email,
              customer?.phone,
            ].whereType<String>().join(' ').toLowerCase();

        return searchableText.contains(searchTerm);
      }).toList();

  filtered.sort((a, b) {
    final aCustomer = customerById[a.customerId]?.name ?? '';
    final bCustomer = customerById[b.customerId]?.name ?? '';

    return switch (sort) {
      ReceivableSort.dueDateAsc => a.dueDate!.compareTo(b.dueDate!),
      ReceivableSort.dueDateDesc => b.dueDate!.compareTo(a.dueDate!),
      ReceivableSort.amountDesc => b.remainingAmount.compareTo(
        a.remainingAmount,
      ),
      ReceivableSort.customerName => aCustomer.compareTo(bCustomer),
    };
  });

  return AsyncValue.data(filtered);
});

// Filter provider for invoices
final invoiceFilterProvider = StateProvider<InvoiceFilter>((ref) {
  return InvoiceFilter();
});

class InvoiceFilter {
  final InvoiceStatus? status;
  final String? vendorId;
  final bool showOverdueOnly;
  final String? agingBucketId;

  InvoiceFilter({
    this.status,
    this.vendorId,
    this.showOverdueOnly = false,
    this.agingBucketId,
  });

  InvoiceFilter copyWith({
    InvoiceStatus? status,
    String? vendorId,
    bool? showOverdueOnly,
    String? agingBucketId,
  }) {
    return InvoiceFilter(
      status: status ?? this.status,
      vendorId: vendorId ?? this.vendorId,
      showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
      agingBucketId: agingBucketId ?? this.agingBucketId,
    );
  }

  InvoiceFilter withAgingBucket(String? bucketId) {
    return InvoiceFilter(
      status: status,
      vendorId: vendorId,
      showOverdueOnly: showOverdueOnly,
      agingBucketId: bucketId,
    );
  }
}

/* 
// Filtered invoices provider
final filteredInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices = ref.watch(invoicesProvider);
  final filter = ref.watch(invoiceFilterProvider);

  return invoices.where((invoice) {
    if (filter.status != null && invoice.status != filter.status) {
      return false;
    }
    if (filter.vendorId != null && invoice.vendorId != filter.vendorId) {
      return false;
    }
    if (filter.showOverdueOnly && invoice.status != InvoiceStatus.overdue) {
      return false;
    }
    return true;
  }).toList();
}); */
