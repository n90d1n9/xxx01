import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/billing_invoice.dart';
import '../models/billing_invoice_draft.dart';
import '../models/billing_invoice_issue_policy.dart';
import '../models/billing_invoice_tax_mode.dart';
import '../repositories/billing_invoice_create_repository.dart';
import '../utils/billing_invoice_collection.dart';
import '../utils/billing_invoice_issue_command.dart';
import 'billing_business_domain_profile_provider.dart';
import 'billing_dashboard_provider.dart';
import 'billing_invoice_issue_outbox_provider.dart';

final billingInvoiceCreateRepositoryProvider =
    Provider<BillingInvoiceCreateRepository>(
      (ref) => const DemoBillingInvoiceCreateRepository(),
    );

final billingInvoiceCreateControllerProvider = StateNotifierProvider<
  BillingInvoiceCreateController,
  AsyncValue<BillingInvoice?>
>((ref) {
  return BillingInvoiceCreateController(ref);
});

class BillingInvoiceCreateController
    extends StateNotifier<AsyncValue<BillingInvoice?>> {
  final Ref ref;

  BillingInvoiceCreateController(this.ref) : super(const AsyncData(null));

  Future<BillingInvoice> createInvoiceFromDomainValues({
    required String tenantId,
    required DateTime issueDate,
    required Iterable<Object> values,
    required String domain,
    String? sourceType,
    double amount = 0,
    BillingInvoiceTaxMode? taxMode,
  }) {
    final composition = ref
        .read(billingDomainInvoiceDraftComposerProvider)
        .prepareFromValues(
          tenantId: tenantId,
          issueDate: issueDate,
          values: values,
          domain: domain,
          sourceType: sourceType,
          amount: amount,
          taxMode: taxMode,
        );

    return createInvoice(
      composition.draft,
      issuePolicy: composition.issuePolicy,
    );
  }

  Future<BillingInvoice> createInvoice(
    BillingInvoiceDraft draft, {
    BillingInvoiceIssuePolicy? issuePolicy,
  }) async {
    draft.ensureValid();
    final command = buildBillingInvoiceIssueCommand(
      draft,
      issuePolicy: issuePolicy,
    );
    state = const AsyncLoading();

    try {
      final outboxRepository = ref.read(
        billingInvoiceIssueOutboxRepositoryProvider,
      );
      await outboxRepository.enqueue(command);
      await outboxRepository.markSyncing(command.idempotencyKey);
      _refreshOutbox(command.tenantId);

      final invoice = await ref
          .read(billingInvoiceCreateRepositoryProvider)
          .createInvoice(draft, issueCommand: command);
      await outboxRepository.markSynced(
        command.idempotencyKey,
        remoteInvoiceId: invoice.id,
      );
      _refreshOutbox(command.tenantId);
      _trackCreatedInvoice(invoice);
      ref.invalidate(billingInvoicesProvider(invoice.tenantId));
      ref.invalidate(billingDashboardStatsProvider(invoice.tenantId));
      state = AsyncData(invoice);
      return invoice;
    } catch (error, stackTrace) {
      await _markOutboxFailed(command.idempotencyKey, command.tenantId, error);
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }

  void _trackCreatedInvoice(BillingInvoice invoice) {
    final notifier = ref.read(
      locallyCreatedBillingInvoicesProvider(invoice.tenantId).notifier,
    );
    notifier.state = mergeBillingInvoices(notifier.state, [invoice]);
  }

  Future<void> _markOutboxFailed(
    String idempotencyKey,
    String tenantId,
    Object error,
  ) async {
    try {
      await ref
          .read(billingInvoiceIssueOutboxRepositoryProvider)
          .markFailed(idempotencyKey, error: error);
    } catch (_) {
      // A failed enqueue should surface as the original create error.
    } finally {
      _refreshOutbox(tenantId);
    }
  }

  void _refreshOutbox(String tenantId) {
    ref.invalidate(billingInvoiceIssueOutboxEntriesProvider(tenantId));
  }
}
