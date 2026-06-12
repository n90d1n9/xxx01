import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/invoice.dart';
import '../models/receivable_reconciliation.dart';
import '../services/receivable_reconciliation_service.dart';
import 'accounting_core_provider.dart';
import 'customer_provider.dart';
import 'invoice_provider.dart';

final receivableReconciliationServiceProvider =
    Provider<ReceivableReconciliationService>((ref) {
      return const ReceivableReconciliationService();
    });

final allReceivableInvoicesProvider = Provider<List<Invoice>>((ref) {
  final invoices =
      ref
          .watch(invoicesProvider)
          .invoices
          .where((invoice) => invoice.customerId != null)
          .toList();

  invoices.sort((a, b) {
    final dateComparison = (a.dueDate ?? DateTime(9999)).compareTo(
      b.dueDate ?? DateTime(9999),
    );
    if (dateComparison != 0) {
      return dateComparison;
    }
    return (a.invoiceNumber ?? a.id).compareTo(b.invoiceNumber ?? b.id);
  });

  return invoices;
});

final receivableReconciliationProvider = Provider<ReceivableReconciliation>((
  ref,
) {
  final service = ref.watch(receivableReconciliationServiceProvider);
  final receivableAccounts = ref.watch(receivablePostingAccountsProvider);
  final customerNames = {
    for (final customer in ref.watch(customersProvider))
      customer.id: customer.name,
  };

  return service.reconcile(
    invoices: ref.watch(allReceivableInvoicesProvider),
    postings: ref.watch(postedLedgerProvider),
    accountsReceivable: receivableAccounts.accountsReceivable,
    customerNamesById: customerNames,
  );
});
