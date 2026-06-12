import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/customer.dart';
import '../models/invoice.dart';
import 'customer_provider.dart';
import 'invoice_provider.dart';

enum CustomerRiskFilter { all, overdue, openBalance, clear }

enum CustomerSort { balanceDesc, overdueDesc, nameAsc, invoiceCountDesc }

final customerSearchProvider = StateProvider<String>((ref) => '');
final customerRiskFilterProvider = StateProvider<CustomerRiskFilter>(
  (ref) => CustomerRiskFilter.all,
);
final customerSortProvider = StateProvider<CustomerSort>(
  (ref) => CustomerSort.balanceDesc,
);

class CustomerAccountSummary {
  final Customer customer;
  final List<Invoice> invoices;

  const CustomerAccountSummary({
    required this.customer,
    required this.invoices,
  });

  double get totalBalance =>
      invoices.fold(0.0, (sum, invoice) => sum + invoice.remainingAmount);

  double get overdueBalance => invoices
      .where((invoice) => invoice.isOverdue)
      .fold(0.0, (sum, invoice) => sum + invoice.remainingAmount);

  int get openInvoiceCount =>
      invoices.where((invoice) => invoice.remainingAmount > 0).length;

  int get overdueInvoiceCount =>
      invoices.where((invoice) => invoice.isOverdue).length;

  bool get hasOpenBalance => totalBalance > 0;

  bool get hasOverdue => overdueBalance > 0;

  DateTime? get nextDueDate {
    final openDueDates =
        invoices
            .where(
              (invoice) =>
                  invoice.remainingAmount > 0 && invoice.dueDate != null,
            )
            .map((invoice) => invoice.dueDate!)
            .toList()
          ..sort();

    return openDueDates.isEmpty ? null : openDueDates.first;
  }
}

final customerAccountSummariesProvider = Provider<
  AsyncValue<List<CustomerAccountSummary>>
>((ref) {
  final customersAsync = ref.watch(customersProvider3);
  final invoices =
      ref
          .watch(invoicesProvider)
          .invoices
          .where(
            (invoice) => invoice.customerId != null && invoice.dueDate != null,
          )
          .toList();
  final searchTerm = ref.watch(customerSearchProvider).trim().toLowerCase();
  final riskFilter = ref.watch(customerRiskFilterProvider);
  final sort = ref.watch(customerSortProvider);

  return customersAsync.whenData((customers) {
    final uniqueCustomers = <String, Customer>{};
    for (final customer in customers) {
      uniqueCustomers.putIfAbsent(customer.id, () => customer);
    }

    final summaries =
        uniqueCustomers.values
            .map((customer) {
              final customerInvoices =
                  invoices
                      .where((invoice) => invoice.customerId == customer.id)
                      .toList();
              return CustomerAccountSummary(
                customer: customer,
                invoices: customerInvoices,
              );
            })
            .where((summary) {
              final matchesRisk = switch (riskFilter) {
                CustomerRiskFilter.overdue => summary.hasOverdue,
                CustomerRiskFilter.openBalance => summary.hasOpenBalance,
                CustomerRiskFilter.clear => !summary.hasOpenBalance,
                CustomerRiskFilter.all => true,
              };

              if (!matchesRisk) {
                return false;
              }

              if (searchTerm.isEmpty) {
                return true;
              }

              final searchableText =
                  [
                    summary.customer.name,
                    summary.customer.email,
                    summary.customer.phone,
                  ].join(' ').toLowerCase();

              return searchableText.contains(searchTerm);
            })
            .toList();

    summaries.sort((a, b) {
      return switch (sort) {
        CustomerSort.balanceDesc => b.totalBalance.compareTo(a.totalBalance),
        CustomerSort.overdueDesc => b.overdueBalance.compareTo(
          a.overdueBalance,
        ),
        CustomerSort.nameAsc => a.customer.name.compareTo(b.customer.name),
        CustomerSort.invoiceCountDesc => b.openInvoiceCount.compareTo(
          a.openInvoiceCount,
        ),
      };
    });

    return summaries;
  });
});
