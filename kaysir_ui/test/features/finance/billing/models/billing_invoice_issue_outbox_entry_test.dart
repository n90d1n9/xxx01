import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test('BillingInvoiceIssueOutboxEntry snapshots command payloads', () {
    final command = buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 0,
        issueDate: DateTime(2026, 5, 31),
        lineItems: const [
          BillingInvoiceLineItem(
            id: 'retainer',
            description: 'Monthly retainer',
            quantity: 1,
            unitPrice: 500,
            taxRate: 0.1,
          ),
        ],
      ),
      requestedAt: DateTime(2026, 5, 31, 9),
      channel: 'api',
      attributes: const {'source': 'offline-draft'},
    );
    final entry = BillingInvoiceIssueOutboxEntry.fromCommand(
      command,
      createdAt: DateTime(2026, 5, 31, 9, 1),
    );

    expect(entry.idempotencyKey, command.idempotencyKey);
    expect(entry.tenantId, 'tenant-a');
    expect(entry.draftFingerprint, command.draftFingerprint);
    expect(entry.status, BillingInvoiceIssueOutboxStatus.queued);
    expect(entry.attemptCount, 0);
    expect(entry.canRetry, isTrue);
    expect(entry.payload['total'], 550);
    expect(entry.payload['attributes'], {'source': 'offline-draft'});
    expect(() => entry.payload['total'] = 0, throwsUnsupportedError);
  });

  test('BillingInvoiceIssueOutboxEntry records sync lifecycle', () {
    final command = buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 100,
        issueDate: DateTime(2026, 5, 31),
      ),
      requestedAt: DateTime(2026, 5, 31, 9),
    );
    final queued = BillingInvoiceIssueOutboxEntry.fromCommand(
      command,
      createdAt: DateTime(2026, 5, 31, 9, 1),
    );

    final syncing = queued.markSyncing(updatedAt: DateTime(2026, 5, 31, 9, 2));
    final failed = syncing.markFailed(
      error: StateError('network unavailable'),
      updatedAt: DateTime(2026, 5, 31, 9, 3),
    );
    final synced = syncing.markSynced(
      remoteInvoiceId: 'inv-remote',
      updatedAt: DateTime(2026, 5, 31, 9, 4),
    );

    expect(syncing.status, BillingInvoiceIssueOutboxStatus.syncing);
    expect(syncing.attemptCount, 1);
    expect(syncing.canRetry, isFalse);
    expect(failed.status, BillingInvoiceIssueOutboxStatus.failed);
    expect(failed.canRetry, isTrue);
    expect(failed.lastError, contains('network unavailable'));
    expect(synced.status, BillingInvoiceIssueOutboxStatus.synced);
    expect(synced.isTerminal, isTrue);
    expect(synced.remoteInvoiceId, 'inv-remote');
    expect(synced.lastError, isNull);
  });

  test('BillingInvoiceIssueOutboxEntry restores from persistence records', () {
    final command = buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 100,
        issueDate: DateTime(2026, 5, 31),
      ),
      requestedAt: DateTime(2026, 5, 31, 9),
    );
    final entry = BillingInvoiceIssueOutboxEntry.fromCommand(
      command,
      createdAt: DateTime(2026, 5, 31, 9, 1),
    ).markFailed(error: 'offline', updatedAt: DateTime(2026, 5, 31, 9, 2));

    final restored = BillingInvoiceIssueOutboxEntry.fromRecord(
      entry.toRecord(),
    );

    expect(restored.idempotencyKey, entry.idempotencyKey);
    expect(restored.status, BillingInvoiceIssueOutboxStatus.failed);
    expect(restored.updatedAt, DateTime(2026, 5, 31, 9, 2));
    expect(restored.lastError, 'offline');
    expect(restored.payload['draftFingerprint'], command.draftFingerprint);
  });
}
