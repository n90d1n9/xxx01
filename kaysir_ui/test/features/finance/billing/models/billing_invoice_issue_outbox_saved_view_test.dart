import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_saved_view.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sort.dart';

void main() {
  test('BillingInvoiceIssueOutboxSavedView counts and applies presets', () {
    final ready = _entry(id: 'ready');
    final waiting = _entry(id: 'waiting', updatedAt: DateTime(2026, 5, 31, 10));
    final review = _entry(id: 'review');
    final entries = [waiting, review, ready];
    final snapshots = {
      ready.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.ready,
      ),
      waiting.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.waiting,
      ),
      review.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.exhausted,
      ),
    };

    final readyView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'ready',
    );
    final waitingView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'waiting',
    );

    expect(readyView.count(entries, retrySnapshots: snapshots), 1);
    expect(readyView.apply(entries, retrySnapshots: snapshots), [ready]);
    expect(waitingView.count(entries, retrySnapshots: snapshots), 1);
    expect(waitingView.apply(entries, retrySnapshots: snapshots), [waiting]);
  });

  test('findBillingInvoiceIssueOutboxSavedView resolves matching presets', () {
    expect(
      findBillingInvoiceIssueOutboxSavedView(
        filter: const BillingInvoiceIssueOutboxFilter(),
        sortOption: BillingInvoiceIssueOutboxSortOption.retryPriority,
      )?.id,
      'all',
    );
    expect(
      findBillingInvoiceIssueOutboxSavedView(
        filter: const BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.waiting,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.updatedNewestFirst,
      )?.id,
      'waiting',
    );
    expect(
      findBillingInvoiceIssueOutboxSavedView(
        filter: const BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.waiting,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.retryPriority,
      ),
      isNull,
    );
  });
}

BillingInvoiceIssueOutboxEntry _entry({
  required String id,
  DateTime? updatedAt,
}) {
  final createdAt = DateTime(2026, 5, 31, 9);

  return BillingInvoiceIssueOutboxEntry(
    idempotencyKey: id,
    tenantId: 'tenant-a',
    draftFingerprint: 'fingerprint-$id',
    status: BillingInvoiceIssueOutboxStatus.queued,
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
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
