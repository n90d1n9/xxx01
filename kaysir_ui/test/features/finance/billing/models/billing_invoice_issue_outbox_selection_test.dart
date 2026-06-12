import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_selection.dart';

void main() {
  test('BillingInvoiceIssueOutboxSelection toggles and clears keys', () {
    const empty = BillingInvoiceIssueOutboxSelection();

    final selected = empty.toggle('issue-a').toggle('issue-b');

    expect(selected.count, 2);
    expect(selected.contains('issue-a'), isTrue);
    expect(selected.toggle('issue-a').selectedKeys, {'issue-b'});
    expect(selected.clear().isEmpty, isTrue);
    expect(empty.toggle(' ').isEmpty, isTrue);
  });

  test('BillingInvoiceIssueOutboxSelection compares keys as a set', () {
    expect(
      BillingInvoiceIssueOutboxSelection.of(['issue-b', 'issue-a']),
      BillingInvoiceIssueOutboxSelection.of(['issue-a', 'issue-b']),
    );
    expect(
      BillingInvoiceIssueOutboxSelection.of(['issue-a']).hashCode,
      BillingInvoiceIssueOutboxSelection.of(['issue-a']).hashCode,
    );
  });

  test('BillingInvoiceIssueOutboxSelection derives retry-ready entries', () {
    final ready = _entry('ready');
    final waiting = _entry('waiting');
    final exhausted = _entry('exhausted');
    final entries = [ready, waiting, exhausted];
    final retrySnapshots = {
      ready.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.ready,
      ),
      waiting.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.waiting,
      ),
      exhausted.idempotencyKey: _snapshot(
        BillingInvoiceIssueOutboxRetryReadiness.exhausted,
      ),
    };

    final allReady = const BillingInvoiceIssueOutboxSelection()
        .selectRetryReady(entries, retrySnapshots: retrySnapshots);
    final selectedReady = BillingInvoiceIssueOutboxSelection.of([
      ready.idempotencyKey,
      waiting.idempotencyKey,
      'missing',
    ]).selectedRetryReadyEntries(entries, retrySnapshots: retrySnapshots);

    expect(allReady.selectedKeys, {ready.idempotencyKey});
    expect(selectedReady, [ready]);
  });
}

BillingInvoiceIssueOutboxEntry _entry(String idempotencyKey) {
  final now = DateTime(2026, 5, 31, 9);

  return BillingInvoiceIssueOutboxEntry(
    idempotencyKey: idempotencyKey,
    tenantId: 'tenant-a',
    draftFingerprint: 'draft-$idempotencyKey',
    status: BillingInvoiceIssueOutboxStatus.queued,
    createdAt: now,
    updatedAt: now,
    attemptCount: 0,
  );
}

BillingInvoiceIssueOutboxRetrySnapshot _snapshot(
  BillingInvoiceIssueOutboxRetryReadiness readiness,
) {
  return BillingInvoiceIssueOutboxRetrySnapshot(
    readiness: readiness,
    attemptsRemaining: 3,
    evaluatedAt: DateTime(2026, 5, 31, 10),
  );
}
