import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_saved_view.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_view_state.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_active_view_banner.dart';

void main() {
  testWidgets(
    'BillingInvoiceIssueOutboxActiveViewBanner renders the default view',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillingInvoiceIssueOutboxActiveViewBanner(
              viewState: const BillingInvoiceIssueOutboxViewState(),
              visibleCount: 3,
              totalCount: 3,
              onReset: () {},
            ),
          ),
        ),
      );

      expect(find.text('All queue'), findsOneWidget);
      expect(find.text('3 of 3 shown'), findsOneWidget);
      expect(find.byTooltip('Reset issue outbox view'), findsNothing);
    },
  );

  testWidgets(
    'BillingInvoiceIssueOutboxActiveViewBanner exposes reset for active views',
    (tester) async {
      var reset = false;
      final reviewView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
        (view) => view.id == 'review',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BillingInvoiceIssueOutboxActiveViewBanner(
              viewState: BillingInvoiceIssueOutboxViewState.fromSavedView(
                reviewView,
              ),
              visibleCount: 1,
              totalCount: 4,
              onReset: () {
                reset = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Needs review'), findsOneWidget);
      expect(find.text('1 of 4 shown'), findsOneWidget);

      await tester.tap(find.byTooltip('Reset issue outbox view'));
      await tester.pumpAndSettle();

      expect(reset, isTrue);
    },
  );
}
