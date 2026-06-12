import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sort.dart';

void main() {
  test('sortBillingInvoiceIssueOutboxEntries prioritizes retry readiness', () {
    final ready = _entry(id: 'ready');
    final waiting = _entry(id: 'waiting');
    final review = _entry(id: 'review');
    final inFlight = _entry(id: 'in-flight');
    final synced = _entry(id: 'synced');
    final entries = [synced, inFlight, review, waiting, ready];

    final sorted = sortBillingInvoiceIssueOutboxEntries(
      entries,
      retrySnapshots: {
        ready.idempotencyKey: _snapshot(
          BillingInvoiceIssueOutboxRetryReadiness.ready,
        ),
        waiting.idempotencyKey: _snapshot(
          BillingInvoiceIssueOutboxRetryReadiness.waiting,
        ),
        review.idempotencyKey: _snapshot(
          BillingInvoiceIssueOutboxRetryReadiness.exhausted,
        ),
        inFlight.idempotencyKey: _snapshot(
          BillingInvoiceIssueOutboxRetryReadiness.inFlight,
        ),
        synced.idempotencyKey: _snapshot(
          BillingInvoiceIssueOutboxRetryReadiness.synced,
        ),
      },
    );

    expect(sorted, [ready, waiting, review, inFlight, synced]);
    expect(entries, [synced, inFlight, review, waiting, ready]);
  });

  test('sortBillingInvoiceIssueOutboxEntries sorts by creation time', () {
    final oldest = _entry(id: 'oldest', createdAt: DateTime(2026, 5, 31, 9));
    final middle = _entry(id: 'middle', createdAt: DateTime(2026, 5, 31, 10));
    final newest = _entry(id: 'newest', createdAt: DateTime(2026, 5, 31, 11));
    final entries = [middle, newest, oldest];

    expect(
      sortBillingInvoiceIssueOutboxEntries(
        entries,
        retrySnapshots: const {},
        option: BillingInvoiceIssueOutboxSortOption.createdOldestFirst,
      ),
      [oldest, middle, newest],
    );
    expect(
      sortBillingInvoiceIssueOutboxEntries(
        entries,
        retrySnapshots: const {},
        option: BillingInvoiceIssueOutboxSortOption.createdNewestFirst,
      ),
      [newest, middle, oldest],
    );
  });

  test('sortBillingInvoiceIssueOutboxEntries sorts by recent update', () {
    final stale = _entry(id: 'stale', updatedAt: DateTime(2026, 5, 31, 9));
    final active = _entry(id: 'active', updatedAt: DateTime(2026, 5, 31, 11));
    final settled = _entry(id: 'settled', updatedAt: DateTime(2026, 5, 31, 10));

    expect(
      sortBillingInvoiceIssueOutboxEntries(
        [stale, active, settled],
        retrySnapshots: const {},
        option: BillingInvoiceIssueOutboxSortOption.updatedNewestFirst,
      ),
      [active, settled, stale],
    );
  });
}

BillingInvoiceIssueOutboxEntry _entry({
  required String id,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final resolvedCreatedAt = createdAt ?? DateTime(2026, 5, 31, 9);

  return BillingInvoiceIssueOutboxEntry(
    idempotencyKey: id,
    tenantId: 'tenant-a',
    draftFingerprint: 'fingerprint-$id',
    status: BillingInvoiceIssueOutboxStatus.queued,
    createdAt: resolvedCreatedAt,
    updatedAt: updatedAt ?? resolvedCreatedAt,
    attemptCount: 0,
  );
}

BillingInvoiceIssueOutboxRetrySnapshot _snapshot(
  BillingInvoiceIssueOutboxRetryReadiness readiness,
) {
  return BillingInvoiceIssueOutboxRetrySnapshot(
    readiness: readiness,
    attemptsRemaining: 1,
    evaluatedAt: DateTime(2026, 5, 31, 10),
  );
}
