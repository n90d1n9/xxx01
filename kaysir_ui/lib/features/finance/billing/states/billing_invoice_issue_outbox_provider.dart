import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_health.dart';
import '../models/billing_invoice_issue_outbox_retry_policy.dart';
import '../models/billing_invoice_issue_outbox_selection.dart';
import '../models/billing_invoice_issue_outbox_sync_summary.dart';
import '../models/billing_invoice_issue_outbox_view_state.dart';
import '../repositories/billing_invoice_issue_outbox_repository.dart';
import '../repositories/billing_invoice_issue_outbox_sync_client.dart';
import '../utils/billing_invoice_issue_outbox_health.dart';
import '../utils/billing_invoice_issue_outbox_sync.dart';

final billingInvoiceIssueOutboxRepositoryProvider =
    Provider<BillingInvoiceIssueOutboxRepository>(
      (ref) => InMemoryBillingInvoiceIssueOutboxRepository(),
    );

final billingInvoiceIssueOutboxSyncClientProvider =
    Provider<BillingInvoiceIssueOutboxSyncClient>(
      (ref) => const DemoBillingInvoiceIssueOutboxSyncClient(),
    );

final billingInvoiceIssueOutboxRetryPolicyProvider =
    Provider<BillingInvoiceIssueOutboxRetryPolicy>(
      (ref) => const BillingInvoiceIssueOutboxRetryPolicy(),
    );

final billingInvoiceIssueOutboxClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final billingInvoiceIssueOutboxViewStateProvider =
    StateProvider.family<BillingInvoiceIssueOutboxViewState, String>(
      (ref, tenantId) => const BillingInvoiceIssueOutboxViewState(),
    );

final billingInvoiceIssueOutboxSelectionProvider =
    StateProvider.family<BillingInvoiceIssueOutboxSelection, String>(
      (ref, tenantId) => const BillingInvoiceIssueOutboxSelection(),
    );

final billingInvoiceIssueOutboxEntriesProvider =
    FutureProvider.family<List<BillingInvoiceIssueOutboxEntry>, String>((
      ref,
      tenantId,
    ) {
      return ref
          .watch(billingInvoiceIssueOutboxRepositoryProvider)
          .fetchEntries(tenantId: tenantId);
    });

final billingInvoiceIssueOutboxHealthProvider =
    FutureProvider.family<BillingInvoiceIssueOutboxHealth, String>((
      ref,
      tenantId,
    ) async {
      final entries = await ref.watch(
        billingInvoiceIssueOutboxEntriesProvider(tenantId).future,
      );

      return summarizeBillingInvoiceIssueOutbox(
        entries,
        retryPolicy: ref.watch(billingInvoiceIssueOutboxRetryPolicyProvider),
        now: ref.watch(billingInvoiceIssueOutboxClockProvider)(),
      );
    });

final billingInvoiceIssueOutboxSyncControllerProvider = StateNotifierProvider<
  BillingInvoiceIssueOutboxSyncController,
  AsyncValue<BillingInvoiceIssueOutboxSyncSummary?>
>((ref) {
  return BillingInvoiceIssueOutboxSyncController(ref);
});

class BillingInvoiceIssueOutboxSyncController
    extends StateNotifier<AsyncValue<BillingInvoiceIssueOutboxSyncSummary?>> {
  final Ref ref;

  BillingInvoiceIssueOutboxSyncController(this.ref)
    : super(const AsyncData(null));

  Future<BillingInvoiceIssueOutboxSyncSummary> sync({
    String? tenantId,
    Set<String>? idempotencyKeys,
    int limit = 20,
    BillingInvoiceIssueOutboxRetryPolicy? retryPolicy,
  }) async {
    state = const AsyncLoading();

    try {
      final summary = await syncBillingInvoiceIssueOutbox(
        outboxRepository: ref.read(billingInvoiceIssueOutboxRepositoryProvider),
        syncClient: ref.read(billingInvoiceIssueOutboxSyncClientProvider),
        tenantId: tenantId,
        idempotencyKeys: idempotencyKeys,
        limit: limit,
        retryPolicy:
            retryPolicy ??
            ref.read(billingInvoiceIssueOutboxRetryPolicyProvider),
        now: ref.read(billingInvoiceIssueOutboxClockProvider)(),
      );
      _refreshTenantOutbox(tenantId);
      state = AsyncData(summary);
      return summary;
    } catch (error, stackTrace) {
      _refreshTenantOutbox(tenantId);
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }

  void _refreshTenantOutbox(String? tenantId) {
    if (tenantId == null || tenantId.isEmpty) return;
    ref.invalidate(billingInvoiceIssueOutboxEntriesProvider(tenantId));
    ref.invalidate(billingInvoiceIssueOutboxHealthProvider(tenantId));
  }
}
