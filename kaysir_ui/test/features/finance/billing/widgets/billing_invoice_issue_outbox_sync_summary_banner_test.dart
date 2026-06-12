import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_sync_summary.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_sync_summary_banner.dart';

void main() {
  testWidgets('BillingInvoiceIssueOutboxSyncSummaryBanner renders success', (
    tester,
  ) async {
    final summary = BillingInvoiceIssueOutboxSyncSummary(
      inspectedCount: 1,
      remainingCount: 0,
      syncedEntries: [_entry().markSynced(remoteInvoiceId: 'remote-a')],
    );

    await _pumpBanner(tester, summary);

    expect(find.text('Sync complete'), findsOneWidget);
    expect(find.text('1 issue commands synced.'), findsOneWidget);
    expect(find.text('1 synced'), findsOneWidget);
    expect(find.text('0 failed'), findsOneWidget);
  });

  testWidgets(
    'BillingInvoiceIssueOutboxSyncSummaryBanner renders failure summary',
    (tester) async {
      final failedEntry = _entry().copyWith(
        status: BillingInvoiceIssueOutboxStatus.failed,
        lastError: 'offline',
      );
      final summary = BillingInvoiceIssueOutboxSyncSummary(
        inspectedCount: 2,
        remainingCount: 1,
        deferredCount: 1,
        exhaustedCount: 1,
        syncedEntries: [_entry().markSynced(remoteInvoiceId: 'remote-a')],
        failedEntries: [failedEntry],
      );

      await _pumpBanner(tester, summary);

      expect(find.text('Sync needs attention'), findsOneWidget);
      expect(
        find.text('1 issue commands failed while 1 synced.'),
        findsOneWidget,
      );
      expect(find.text('1 failed'), findsOneWidget);
      expect(find.text('1 waiting'), findsOneWidget);
      expect(find.text('1 review'), findsOneWidget);
      expect(find.text('1 remaining'), findsOneWidget);
    },
  );
}

Future<void> _pumpBanner(
  WidgetTester tester,
  BillingInvoiceIssueOutboxSyncSummary summary,
) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BillingInvoiceIssueOutboxSyncSummaryBanner(summary: summary),
        ),
      ),
    ),
  );
}

BillingInvoiceIssueOutboxEntry _entry() {
  return BillingInvoiceIssueOutboxEntry.fromCommand(
    buildBillingInvoiceIssueCommand(
      BillingInvoiceDraft(
        tenantId: 'tenant-a',
        amount: 100,
        issueDate: DateTime(2026, 5, 31),
      ),
    ),
    createdAt: DateTime(2026, 5, 31, 9),
  );
}
