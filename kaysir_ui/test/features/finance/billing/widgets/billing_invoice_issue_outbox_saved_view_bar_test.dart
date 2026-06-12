import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_saved_view_bar.dart';

void main() {
  testWidgets('BillingInvoiceIssueOutboxSavedViewBar selects a view', (
    tester,
  ) async {
    final ready = _entry(id: 'ready');
    final review = _entry(id: 'review');
    final readyView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'ready',
    );
    final reviewView = billingInvoiceIssueOutboxDefaultSavedViews.firstWhere(
      (view) => view.id == 'review',
    );
    BillingInvoiceIssueOutboxSavedView? selected = readyView;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingInvoiceIssueOutboxSavedViewBar(
            entries: [ready, review],
            retrySnapshots: {
              ready.idempotencyKey: _snapshot(
                BillingInvoiceIssueOutboxRetryReadiness.ready,
              ),
              review.idempotencyKey: _snapshot(
                BillingInvoiceIssueOutboxRetryReadiness.exhausted,
              ),
            },
            selectedView: selected,
            views: [readyView, reviewView],
            onSelected: (view) {
              selected = view;
            },
          ),
        ),
      ),
    );

    expect(find.text('Ready queue'), findsOneWidget);
    expect(find.text('Needs review'), findsOneWidget);

    await tester.tap(find.text('Needs review'));
    await tester.pumpAndSettle();

    expect(selected?.id, 'review');
  });
}

BillingInvoiceIssueOutboxEntry _entry({required String id}) {
  return BillingInvoiceIssueOutboxEntry(
    idempotencyKey: id,
    tenantId: 'tenant-a',
    draftFingerprint: 'fingerprint-$id',
    status: BillingInvoiceIssueOutboxStatus.queued,
    createdAt: DateTime(2026, 5, 31, 9),
    updatedAt: DateTime(2026, 5, 31, 9),
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
