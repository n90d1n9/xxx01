import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/payable_reconciliation.dart';
import '../services/payable_reconciliation_service.dart';
import 'accounting_core_provider.dart';
import 'invoice_provider.dart';

final payableReconciliationServiceProvider =
    Provider<PayableReconciliationService>((ref) {
      return const PayableReconciliationService();
    });

final payableReconciliationProvider = Provider<PayableReconciliation>((ref) {
  final service = ref.watch(payableReconciliationServiceProvider);
  final payableAccounts = ref.watch(payablePostingAccountsProvider);

  return service.reconcile(
    bills: ref.watch(allPayableInvoicesProvider),
    postings: ref.watch(postedLedgerProvider),
    accountsPayable: payableAccounts.accountsPayable,
  );
});
