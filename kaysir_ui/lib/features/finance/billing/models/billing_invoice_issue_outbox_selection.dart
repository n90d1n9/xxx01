import 'billing_invoice_issue_outbox_entry.dart';
import 'billing_invoice_issue_outbox_retry_snapshot.dart';

class BillingInvoiceIssueOutboxSelection {
  final Set<String> selectedKeys;

  const BillingInvoiceIssueOutboxSelection({this.selectedKeys = const {}});

  factory BillingInvoiceIssueOutboxSelection.of(Iterable<String> keys) {
    return BillingInvoiceIssueOutboxSelection(
      selectedKeys: Set.unmodifiable(
        keys.where((key) => key.trim().isNotEmpty),
      ),
    );
  }

  bool get isEmpty => selectedKeys.isEmpty;

  bool get isNotEmpty => selectedKeys.isNotEmpty;

  int get count => selectedKeys.length;

  bool contains(String idempotencyKey) {
    return selectedKeys.contains(idempotencyKey);
  }

  BillingInvoiceIssueOutboxSelection clear() {
    return const BillingInvoiceIssueOutboxSelection();
  }

  BillingInvoiceIssueOutboxSelection toggle(String idempotencyKey) {
    final next = {...selectedKeys};
    if (!next.add(idempotencyKey)) {
      next.remove(idempotencyKey);
    }

    return BillingInvoiceIssueOutboxSelection.of(next);
  }

  BillingInvoiceIssueOutboxSelection selectKeys(Iterable<String> keys) {
    return BillingInvoiceIssueOutboxSelection.of(keys);
  }

  BillingInvoiceIssueOutboxSelection selectRetryReady(
    Iterable<BillingInvoiceIssueOutboxEntry> entries, {
    required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  }) {
    return selectKeys(
      entries
          .where(
            (entry) =>
                retrySnapshots[entry.idempotencyKey]?.canAttemptNow == true,
          )
          .map((entry) => entry.idempotencyKey),
    );
  }

  List<BillingInvoiceIssueOutboxEntry> selectedEntries(
    Iterable<BillingInvoiceIssueOutboxEntry> entries,
  ) {
    return entries
        .where((entry) => selectedKeys.contains(entry.idempotencyKey))
        .toList(growable: false);
  }

  List<BillingInvoiceIssueOutboxEntry> selectedRetryReadyEntries(
    Iterable<BillingInvoiceIssueOutboxEntry> entries, {
    required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  }) {
    return selectedEntries(entries)
        .where(
          (entry) =>
              retrySnapshots[entry.idempotencyKey]?.canAttemptNow == true,
        )
        .toList(growable: false);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingInvoiceIssueOutboxSelection &&
            _setEquals(other.selectedKeys, selectedKeys);
  }

  @override
  int get hashCode {
    return Object.hashAll(selectedKeys.toList()..sort());
  }
}

bool _setEquals(Set<String> first, Set<String> second) {
  if (first.length != second.length) return false;

  for (final value in first) {
    if (!second.contains(value)) return false;
  }

  return true;
}
