import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sort.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_sort_menu.dart';

void main() {
  testWidgets('BillingInvoiceIssueOutboxSortMenu changes sort option', (
    tester,
  ) async {
    var selected = BillingInvoiceIssueOutboxSortOption.retryPriority;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: BillingInvoiceIssueOutboxSortMenu(
              value: selected,
              onChanged: (value) {
                selected = value;
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Sort issue outbox'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Newest'));
    await tester.pumpAndSettle();

    expect(selected, BillingInvoiceIssueOutboxSortOption.createdNewestFirst);
  });
}
