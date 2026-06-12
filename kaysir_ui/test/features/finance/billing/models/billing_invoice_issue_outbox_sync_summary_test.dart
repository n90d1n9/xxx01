import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sync_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test('BillingInvoiceIssueOutboxSyncSummary exposes batch metrics', () {
    final syncedEntry = BillingInvoiceIssueOutboxEntry.fromCommand(
      buildBillingInvoiceIssueCommand(
        BillingInvoiceDraft(
          tenantId: 'tenant-a',
          amount: 100,
          issueDate: DateTime(2026, 5, 31),
        ),
      ),
      createdAt: DateTime(2026, 5, 31),
    ).markSynced(remoteInvoiceId: 'inv-remote');
    final failedEntry = syncedEntry.copyWith(
      idempotencyKey: 'issue-failed',
      status: BillingInvoiceIssueOutboxStatus.failed,
      remoteInvoiceId: null,
      lastError: 'offline',
    );

    final summary = BillingInvoiceIssueOutboxSyncSummary(
      inspectedCount: 2,
      remainingCount: 1,
      deferredCount: 1,
      exhaustedCount: 1,
      syncedEntries: [syncedEntry],
      failedEntries: [failedEntry],
    );

    expect(summary.attemptedCount, 2);
    expect(summary.syncedCount, 1);
    expect(summary.failedCount, 1);
    expect(summary.hasFailures, isTrue);
    expect(summary.hasMore, isTrue);
    expect(summary.hasBlockedEntries, isTrue);
    expect(summary.didWork, isTrue);
    expect(summary.remoteInvoiceIds, ['inv-remote']);
    expect(
      () => summary.syncedEntries.add(syncedEntry),
      throwsUnsupportedError,
    );
  });
}
