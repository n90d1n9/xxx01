import '../models/billing_invoice_issue_command.dart';
import '../models/billing_invoice_issue_outbox_entry.dart';

abstract class BillingInvoiceIssueOutboxRepository {
  Future<BillingInvoiceIssueOutboxEntry> enqueue(
    BillingInvoiceIssueCommand command,
  );

  Future<BillingInvoiceIssueOutboxEntry> markSyncing(String idempotencyKey);

  Future<BillingInvoiceIssueOutboxEntry> markSynced(
    String idempotencyKey, {
    required String remoteInvoiceId,
  });

  Future<BillingInvoiceIssueOutboxEntry> markFailed(
    String idempotencyKey, {
    required Object error,
  });

  Future<BillingInvoiceIssueOutboxEntry?> findByIdempotencyKey(
    String idempotencyKey,
  );

  Future<List<BillingInvoiceIssueOutboxEntry>> fetchEntries({
    String? tenantId,
    Set<BillingInvoiceIssueOutboxStatus>? statuses,
  });
}

class InMemoryBillingInvoiceIssueOutboxRepository
    implements BillingInvoiceIssueOutboxRepository {
  final DateTime Function() clock;
  final Map<String, BillingInvoiceIssueOutboxEntry> _entries = {};

  InMemoryBillingInvoiceIssueOutboxRepository({DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  @override
  Future<BillingInvoiceIssueOutboxEntry> enqueue(
    BillingInvoiceIssueCommand command,
  ) async {
    final existing = _entries[command.idempotencyKey];
    if (existing != null) {
      if (existing.draftFingerprint != command.draftFingerprint) {
        throw StateError(
          'Invoice issue outbox key already belongs to a different draft.',
        );
      }

      return existing;
    }

    final entry = BillingInvoiceIssueOutboxEntry.fromCommand(
      command,
      createdAt: clock(),
    );
    _entries[entry.idempotencyKey] = entry;
    return entry;
  }

  @override
  Future<BillingInvoiceIssueOutboxEntry?> findByIdempotencyKey(
    String idempotencyKey,
  ) async {
    return _entries[idempotencyKey];
  }

  @override
  Future<List<BillingInvoiceIssueOutboxEntry>> fetchEntries({
    String? tenantId,
    Set<BillingInvoiceIssueOutboxStatus>? statuses,
  }) async {
    final entries =
        _entries.values.where((entry) {
            final tenantMatches =
                tenantId == null ||
                tenantId.isEmpty ||
                entry.tenantId == tenantId;
            final statusMatches =
                statuses == null || statuses.contains(entry.status);

            return tenantMatches && statusMatches;
          }).toList()
          ..sort((a, b) {
            final createdComparison = a.createdAt.compareTo(b.createdAt);
            if (createdComparison != 0) return createdComparison;
            return a.idempotencyKey.compareTo(b.idempotencyKey);
          });

    return List.unmodifiable(entries);
  }

  @override
  Future<BillingInvoiceIssueOutboxEntry> markFailed(
    String idempotencyKey, {
    required Object error,
  }) async {
    return _update(
      idempotencyKey,
      (entry) => entry.markFailed(error: error, updatedAt: clock()),
    );
  }

  @override
  Future<BillingInvoiceIssueOutboxEntry> markSynced(
    String idempotencyKey, {
    required String remoteInvoiceId,
  }) async {
    return _update(
      idempotencyKey,
      (entry) => entry.markSynced(
        remoteInvoiceId: remoteInvoiceId,
        updatedAt: clock(),
      ),
    );
  }

  @override
  Future<BillingInvoiceIssueOutboxEntry> markSyncing(
    String idempotencyKey,
  ) async {
    return _update(
      idempotencyKey,
      (entry) => entry.markSyncing(updatedAt: clock()),
    );
  }

  BillingInvoiceIssueOutboxEntry _update(
    String idempotencyKey,
    BillingInvoiceIssueOutboxEntry Function(
      BillingInvoiceIssueOutboxEntry entry,
    )
    update,
  ) {
    final existing = _entries[idempotencyKey];
    if (existing == null) {
      throw StateError('Invoice issue outbox entry was not found.');
    }

    final updated = update(existing);
    _entries[idempotencyKey] = updated;
    return updated;
  }
}
