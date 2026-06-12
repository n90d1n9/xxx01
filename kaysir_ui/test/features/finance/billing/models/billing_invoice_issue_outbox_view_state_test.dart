import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_saved_view.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sort.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_view_state.dart';

void main() {
  test('BillingInvoiceIssueOutboxViewState resolves the active saved view', () {
    const state = BillingInvoiceIssueOutboxViewState();

    expect(state.savedView?.id, 'all');
    expect(state.activeLabel, 'All queue');
    expect(state.isDefault, isTrue);

    final waitingView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'waiting',
    );
    final waitingState = state.withSavedView(waitingView);

    expect(waitingState.filter, waitingView.filter);
    expect(waitingState.sortOption, waitingView.sortOption);
    expect(waitingState.savedView?.id, 'waiting');
    expect(waitingState.activeLabel, 'Waiting');
    expect(waitingState.isDefault, isFalse);
  });

  test(
    'BillingInvoiceIssueOutboxViewState supports manual filter and sort',
    () {
      const state = BillingInvoiceIssueOutboxViewState();

      final manualState = state
          .withFilter(
            const BillingInvoiceIssueOutboxFilter(
              readiness: BillingInvoiceIssueOutboxReadinessFilter.waiting,
            ),
          )
          .withSortOption(BillingInvoiceIssueOutboxSortOption.retryPriority);

      expect(manualState.savedView, isNull);
      expect(
        manualState.filter.readiness,
        BillingInvoiceIssueOutboxReadinessFilter.waiting,
      );
      expect(
        manualState.sortOption,
        BillingInvoiceIssueOutboxSortOption.retryPriority,
      );
      expect(manualState.activeLabel, 'Custom view');
      expect(manualState.isDefault, isFalse);
    },
  );
}
