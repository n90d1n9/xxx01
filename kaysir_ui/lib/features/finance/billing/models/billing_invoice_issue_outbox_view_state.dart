import 'billing_invoice_issue_outbox_filter.dart';
import 'billing_invoice_issue_outbox_saved_view.dart';
import 'billing_invoice_issue_outbox_sort.dart';

class BillingInvoiceIssueOutboxViewState {
  final BillingInvoiceIssueOutboxFilter filter;
  final BillingInvoiceIssueOutboxSortOption sortOption;

  const BillingInvoiceIssueOutboxViewState({
    this.filter = const BillingInvoiceIssueOutboxFilter(),
    this.sortOption = BillingInvoiceIssueOutboxSortOption.retryPriority,
  });

  factory BillingInvoiceIssueOutboxViewState.fromSavedView(
    BillingInvoiceIssueOutboxSavedView view,
  ) {
    return BillingInvoiceIssueOutboxViewState(
      filter: view.filter,
      sortOption: view.sortOption,
    );
  }

  BillingInvoiceIssueOutboxSavedView? get savedView {
    return findBillingInvoiceIssueOutboxSavedView(
      filter: filter,
      sortOption: sortOption,
    );
  }

  bool get isDefault {
    return this == const BillingInvoiceIssueOutboxViewState();
  }

  String get activeLabel {
    return savedView?.label ?? 'Custom view';
  }

  BillingInvoiceIssueOutboxViewState copyWith({
    BillingInvoiceIssueOutboxFilter? filter,
    BillingInvoiceIssueOutboxSortOption? sortOption,
  }) {
    return BillingInvoiceIssueOutboxViewState(
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  BillingInvoiceIssueOutboxViewState withFilter(
    BillingInvoiceIssueOutboxFilter filter,
  ) {
    return copyWith(filter: filter);
  }

  BillingInvoiceIssueOutboxViewState withSortOption(
    BillingInvoiceIssueOutboxSortOption sortOption,
  ) {
    return copyWith(sortOption: sortOption);
  }

  BillingInvoiceIssueOutboxViewState withSavedView(
    BillingInvoiceIssueOutboxSavedView view,
  ) {
    return BillingInvoiceIssueOutboxViewState.fromSavedView(view);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BillingInvoiceIssueOutboxViewState &&
            other.filter == filter &&
            other.sortOption == sortOption;
  }

  @override
  int get hashCode => Object.hash(filter, sortOption);
}
