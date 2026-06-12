import 'billing_invoice_issue_outbox_entry.dart';
import 'billing_invoice_issue_outbox_retry_snapshot.dart';

enum BillingInvoiceIssueOutboxReadinessFilter {
  all,
  ready,
  waiting,
  review,
  inFlight,
  synced,
}

class BillingInvoiceIssueOutboxFilter {
  final BillingInvoiceIssueOutboxStatus? status;
  final BillingInvoiceIssueOutboxReadinessFilter readiness;

  const BillingInvoiceIssueOutboxFilter({
    this.status,
    this.readiness = BillingInvoiceIssueOutboxReadinessFilter.all,
  });

  bool get isDefault {
    return status == null &&
        readiness == BillingInvoiceIssueOutboxReadinessFilter.all;
  }

  BillingInvoiceIssueOutboxFilter copyWith({
    Object? status = _unset,
    BillingInvoiceIssueOutboxReadinessFilter? readiness,
  }) {
    return BillingInvoiceIssueOutboxFilter(
      status:
          identical(status, _unset)
              ? this.status
              : status as BillingInvoiceIssueOutboxStatus?,
      readiness: readiness ?? this.readiness,
    );
  }

  BillingInvoiceIssueOutboxFilter withStatus(
    BillingInvoiceIssueOutboxStatus? status,
  ) {
    return copyWith(status: status);
  }

  BillingInvoiceIssueOutboxFilter withReadiness(
    BillingInvoiceIssueOutboxReadinessFilter readiness,
  ) {
    return copyWith(readiness: readiness);
  }

  bool matches(
    BillingInvoiceIssueOutboxEntry entry, {
    required BillingInvoiceIssueOutboxRetrySnapshot retrySnapshot,
  }) {
    if (status != null && entry.status != status) return false;
    if (readiness == BillingInvoiceIssueOutboxReadinessFilter.all) {
      return true;
    }

    return readiness.matches(retrySnapshot.readiness);
  }

  List<BillingInvoiceIssueOutboxEntry> apply(
    Iterable<BillingInvoiceIssueOutboxEntry> entries, {
    required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  }) {
    return entries
        .where((entry) {
          final retrySnapshot = retrySnapshots[entry.idempotencyKey];
          if (retrySnapshot == null) return false;
          return matches(entry, retrySnapshot: retrySnapshot);
        })
        .toList(growable: false);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingInvoiceIssueOutboxFilter &&
            other.status == status &&
            other.readiness == readiness;
  }

  @override
  int get hashCode => Object.hash(status, readiness);
}

extension BillingInvoiceIssueOutboxReadinessFilterLabel
    on BillingInvoiceIssueOutboxReadinessFilter {
  String get label {
    switch (this) {
      case BillingInvoiceIssueOutboxReadinessFilter.all:
        return 'All';
      case BillingInvoiceIssueOutboxReadinessFilter.ready:
        return 'Ready';
      case BillingInvoiceIssueOutboxReadinessFilter.waiting:
        return 'Waiting';
      case BillingInvoiceIssueOutboxReadinessFilter.review:
        return 'Review';
      case BillingInvoiceIssueOutboxReadinessFilter.inFlight:
        return 'In flight';
      case BillingInvoiceIssueOutboxReadinessFilter.synced:
        return 'Done';
    }
  }

  bool matches(BillingInvoiceIssueOutboxRetryReadiness readiness) {
    return switch (this) {
      BillingInvoiceIssueOutboxReadinessFilter.all => true,
      BillingInvoiceIssueOutboxReadinessFilter.ready =>
        readiness == BillingInvoiceIssueOutboxRetryReadiness.ready,
      BillingInvoiceIssueOutboxReadinessFilter.waiting =>
        readiness == BillingInvoiceIssueOutboxRetryReadiness.waiting,
      BillingInvoiceIssueOutboxReadinessFilter.review =>
        readiness == BillingInvoiceIssueOutboxRetryReadiness.exhausted,
      BillingInvoiceIssueOutboxReadinessFilter.inFlight =>
        readiness == BillingInvoiceIssueOutboxRetryReadiness.inFlight,
      BillingInvoiceIssueOutboxReadinessFilter.synced =>
        readiness == BillingInvoiceIssueOutboxRetryReadiness.synced,
    };
  }
}

String billingInvoiceIssueOutboxStatusLabel(
  BillingInvoiceIssueOutboxStatus status,
) {
  return switch (status) {
    BillingInvoiceIssueOutboxStatus.queued => 'Queued',
    BillingInvoiceIssueOutboxStatus.syncing => 'Syncing',
    BillingInvoiceIssueOutboxStatus.synced => 'Synced',
    BillingInvoiceIssueOutboxStatus.failed => 'Failed',
  };
}

const _unset = Object();
