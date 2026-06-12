import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice.dart';
import '../models/billing_invoice_sync_state.dart';
import '../models/billing_tenant_preferences.dart';
import '../states/billing_dashboard_provider.dart';
import 'billing_invoice_empty_state.dart';
import 'billing_invoice_tile.dart';

class BillingInvoiceSliverList extends ConsumerWidget {
  final String tenantId;
  final BillingTenantPreferences preferences;
  final ValueChanged<String>? onInvoiceSelected;
  final ValueChanged<BillingInvoice>? onInvoiceTap;

  const BillingInvoiceSliverList({
    super.key,
    required this.tenantId,
    this.preferences = const BillingTenantPreferences(),
    this.onInvoiceSelected,
    this.onInvoiceTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(filteredBillingInvoicesProvider(tenantId));
    final syncStatesAsync = ref.watch(
      billingInvoiceSyncStateProvider(tenantId),
    );

    return invoicesAsync.when(
      loading:
          () => const SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (err, stack) => const SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: Center(child: Text('Error loading invoices')),
            ),
          ),
      data: (invoices) {
        if (invoices.isEmpty) {
          return const SliverToBoxAdapter(child: BillingInvoiceEmptyState());
        }

        return SliverList.builder(
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            final syncState =
                syncStatesAsync.asData?.value[invoice.id] ??
                BillingInvoiceSyncState.confirmed;

            return BillingInvoiceTile(
              invoice: invoice,
              preferences: preferences,
              syncState: syncState,
              onTap: () {
                onInvoiceSelected?.call(invoice.id);
                onInvoiceTap?.call(invoice);
              },
            );
          },
        );
      },
    );
  }
}
