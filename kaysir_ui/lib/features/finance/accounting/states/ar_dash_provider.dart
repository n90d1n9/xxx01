import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../helper/ar_dash_data.dart';
import 'customer_provider.dart';
import 'invoice_provider.dart';
import 'paymen_proc_provider.dart';

final arDashboardProvider = Provider<ARDashboardData>((ref) {
  final customers = ref.watch(customersProvider);
  final invoices =
      ref
          .watch(invoicesProvider)
          .invoices
          .where(
            (invoice) => invoice.customerId != null && invoice.dueDate != null,
          )
          .toList();
  final payments = ref.watch(paymentsProvider);

  return ARDashboardData(
    customers: customers,
    invoices: invoices,
    payments: payments,
  );
});
