import 'billing_invoice_issue_outbox_entry.dart';
import 'billing_invoice_issue_outbox_filter.dart';
import 'billing_invoice_issue_outbox_retry_snapshot.dart';
import 'billing_invoice_issue_outbox_sort.dart';

class BillingInvoiceIssueOutboxSavedView {
  final String id;
  final String label;
  final String description;
  final BillingInvoiceIssueOutboxFilter filter;
  final BillingInvoiceIssueOutboxSortOption sortOption;

  const BillingInvoiceIssueOutboxSavedView({
    required this.id,
    required this.label,
    required this.description,
    required this.filter,
    required this.sortOption,
  });

  bool matches({
    required BillingInvoiceIssueOutboxFilter filter,
    required BillingInvoiceIssueOutboxSortOption sortOption,
  }) {
    return this.filter == filter && this.sortOption == sortOption;
  }

  int count(
    Iterable<BillingInvoiceIssueOutboxEntry> entries, {
    required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  }) {
    return filter.apply(entries, retrySnapshots: retrySnapshots).length;
  }

  List<BillingInvoiceIssueOutboxEntry> apply(
    Iterable<BillingInvoiceIssueOutboxEntry> entries, {
    required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  }) {
    return sortBillingInvoiceIssueOutboxEntries(
      filter.apply(entries, retrySnapshots: retrySnapshots),
      retrySnapshots: retrySnapshots,
      option: sortOption,
    );
  }
}

const billingInvoiceIssueOutboxDefaultSavedViews =
    <BillingInvoiceIssueOutboxSavedView>[
      BillingInvoiceIssueOutboxSavedView(
        id: 'all',
        label: 'All queue',
        description: 'Everything',
        filter: BillingInvoiceIssueOutboxFilter(),
        sortOption: BillingInvoiceIssueOutboxSortOption.retryPriority,
      ),
      BillingInvoiceIssueOutboxSavedView(
        id: 'ready',
        label: 'Ready queue',
        description: 'Can sync now',
        filter: BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.ready,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.retryPriority,
      ),
      BillingInvoiceIssueOutboxSavedView(
        id: 'waiting',
        label: 'Waiting',
        description: 'Backoff queue',
        filter: BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.waiting,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.updatedNewestFirst,
      ),
      BillingInvoiceIssueOutboxSavedView(
        id: 'review',
        label: 'Needs review',
        description: 'Attempts spent',
        filter: BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.review,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.retryPriority,
      ),
      BillingInvoiceIssueOutboxSavedView(
        id: 'active',
        label: 'In flight',
        description: 'Syncing now',
        filter: BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.inFlight,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.updatedNewestFirst,
      ),
      BillingInvoiceIssueOutboxSavedView(
        id: 'done',
        label: 'Done',
        description: 'Synced',
        filter: BillingInvoiceIssueOutboxFilter(
          readiness: BillingInvoiceIssueOutboxReadinessFilter.synced,
        ),
        sortOption: BillingInvoiceIssueOutboxSortOption.updatedNewestFirst,
      ),
    ];

BillingInvoiceIssueOutboxSavedView? findBillingInvoiceIssueOutboxSavedView({
  required BillingInvoiceIssueOutboxFilter filter,
  required BillingInvoiceIssueOutboxSortOption sortOption,
  Iterable<BillingInvoiceIssueOutboxSavedView> views =
      billingInvoiceIssueOutboxDefaultSavedViews,
}) {
  for (final view in views) {
    if (view.matches(filter: filter, sortOption: sortOption)) {
      return view;
    }
  }

  return null;
}
