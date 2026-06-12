import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_invoice_issue_outbox_repository.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';

void main() {
  test(
    'InMemoryBillingInvoiceIssueOutboxRepository enqueues idempotently',
    () async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final command = buildBillingInvoiceIssueCommand(
        BillingInvoiceDraft(
          tenantId: 'tenant-a',
          amount: 100,
          issueDate: DateTime(2026, 5, 31),
        ),
        requestedAt: DateTime(2026, 5, 31, 9),
      );

      final firstEntry = await repository.enqueue(command);
      final secondEntry = await repository.enqueue(command);

      expect(firstEntry.idempotencyKey, command.idempotencyKey);
      expect(secondEntry, same(firstEntry));
      expect(await repository.fetchEntries(tenantId: 'tenant-a'), [firstEntry]);
    },
  );

  test(
    'InMemoryBillingInvoiceIssueOutboxRepository tracks sync attempts',
    () async {
      var now = DateTime(2026, 5, 31, 9);
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => now,
      );
      final command = buildBillingInvoiceIssueCommand(
        BillingInvoiceDraft(
          tenantId: 'tenant-a',
          amount: 100,
          issueDate: DateTime(2026, 5, 31),
        ),
        requestedAt: DateTime(2026, 5, 31, 9),
      );
      await repository.enqueue(command);

      now = DateTime(2026, 5, 31, 9, 1);
      final syncing = await repository.markSyncing(command.idempotencyKey);
      now = DateTime(2026, 5, 31, 9, 2);
      final failed = await repository.markFailed(
        command.idempotencyKey,
        error: 'timeout',
      );

      expect(syncing.status, BillingInvoiceIssueOutboxStatus.syncing);
      expect(syncing.attemptCount, 1);
      expect(failed.status, BillingInvoiceIssueOutboxStatus.failed);
      expect(failed.lastError, 'timeout');
      expect(
        await repository.fetchEntries(
          tenantId: 'tenant-a',
          statuses: {BillingInvoiceIssueOutboxStatus.failed},
        ),
        [failed],
      );
    },
  );

  test(
    'InMemoryBillingInvoiceIssueOutboxRepository marks remote sync success',
    () async {
      final repository = InMemoryBillingInvoiceIssueOutboxRepository(
        clock: () => DateTime(2026, 5, 31, 9),
      );
      final command = buildBillingInvoiceIssueCommand(
        BillingInvoiceDraft(
          tenantId: 'tenant-a',
          amount: 100,
          issueDate: DateTime(2026, 5, 31),
        ),
        requestedAt: DateTime(2026, 5, 31, 9),
      );
      await repository.enqueue(command);
      await repository.markSyncing(command.idempotencyKey);

      final synced = await repository.markSynced(
        command.idempotencyKey,
        remoteInvoiceId: 'inv-remote',
      );

      expect(synced.status, BillingInvoiceIssueOutboxStatus.synced);
      expect(synced.remoteInvoiceId, 'inv-remote');
      expect(
        await repository.findByIdempotencyKey(command.idempotencyKey),
        synced,
      );
    },
  );
}
