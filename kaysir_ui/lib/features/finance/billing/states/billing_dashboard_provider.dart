import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_dashboard_stats.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_filter.dart';
import '../models/billing_invoice_sync_state.dart';
import '../models/billing_tenant_account.dart';
import '../repositories/billing_dashboard_repository.dart';
import '../utils/billing_dashboard_stats_overlay.dart';
import '../utils/billing_invoice_collection.dart';

final selectedBillingTenantIdProvider = StateProvider<String>((ref) => '');

final billingDashboardRepositoryProvider = Provider<BillingDashboardRepository>(
  (ref) => const DemoBillingDashboardRepository(),
);

final billingInvoiceFilterProvider =
    StateProvider.family<BillingInvoiceFilter, String>(
      (ref, tenantId) => const BillingInvoiceFilter(),
    );

final locallyCreatedBillingInvoicesProvider =
    StateProvider.family<List<BillingInvoice>, String>((ref, tenantId) {
      return const [];
    });

final billingTenantsProvider = FutureProvider<List<BillingTenantAccount>>((
  ref,
) async {
  return ref.watch(billingDashboardRepositoryProvider).fetchTenants();
});

final remoteBillingInvoicesProvider =
    FutureProvider.family<List<BillingInvoice>, String>((ref, tenantId) async {
      return ref
          .watch(billingDashboardRepositoryProvider)
          .fetchInvoices(tenantId);
    });

final billingInvoicesProvider =
    FutureProvider.family<List<BillingInvoice>, String>((ref, tenantId) async {
      final localInvoices = ref.watch(
        locallyCreatedBillingInvoicesProvider(tenantId),
      );
      final invoices = await ref.watch(
        remoteBillingInvoicesProvider(tenantId).future,
      );

      return mergeBillingInvoices(invoices, localInvoices);
    });

final billingDashboardStatsProvider =
    FutureProvider.family<BillingDashboardStats, String>((ref, tenantId) async {
      final localInvoices = ref.watch(
        locallyCreatedBillingInvoicesProvider(tenantId),
      );
      final confirmedInvoices = await ref.watch(
        remoteBillingInvoicesProvider(tenantId).future,
      );
      final stats = await ref
          .watch(billingDashboardRepositoryProvider)
          .fetchStats(tenantId);
      final unconfirmedInvoices = unconfirmedBillingInvoiceOverlay(
        localInvoices,
        confirmedInvoices: confirmedInvoices,
      );

      return overlayBillingDashboardStats(stats, invoices: unconfirmedInvoices);
    });

final billingInvoiceSyncStateProvider = Provider.family<
  AsyncValue<Map<String, BillingInvoiceSyncState>>,
  String
>((ref, tenantId) {
  final localInvoices = ref.watch(
    locallyCreatedBillingInvoicesProvider(tenantId),
  );
  final remoteInvoicesAsync = ref.watch(
    remoteBillingInvoicesProvider(tenantId),
  );

  return remoteInvoicesAsync.whenData((remoteInvoices) {
    final remoteInvoiceIds = {for (final invoice in remoteInvoices) invoice.id};

    return {
      for (final invoice in localInvoices)
        invoice.id:
            remoteInvoiceIds.contains(invoice.id)
                ? BillingInvoiceSyncState.confirmed
                : BillingInvoiceSyncState.localOnly,
    };
  });
});

final filteredBillingInvoicesProvider =
    Provider.family<AsyncValue<List<BillingInvoice>>, String>((ref, tenantId) {
      final invoicesAsync = ref.watch(billingInvoicesProvider(tenantId));
      final filter = ref.watch(billingInvoiceFilterProvider(tenantId));

      return invoicesAsync.whenData(
        (invoices) => filterBillingInvoices(
          invoices,
          query: filter.query,
          status: filter.status,
          sort: filter.sort,
        ),
      );
    });
