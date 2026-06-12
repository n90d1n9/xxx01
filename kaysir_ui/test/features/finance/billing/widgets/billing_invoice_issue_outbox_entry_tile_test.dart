import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_line_item.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_issue_command.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_entry_tile.dart';

void main() {
  testWidgets('BillingInvoiceIssueOutboxEntryTile renders command metadata', (
    tester,
  ) async {
    final entry = _entry(channel: 'api');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BillingInvoiceIssueOutboxEntryTile(
              entry: entry,
              retrySnapshot: BillingInvoiceIssueOutboxRetrySnapshot.evaluate(
                entry,
                now: DateTime(2026, 5, 31, 9, 1),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text(entry.idempotencyKey), findsOneWidget);
    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Ready now'), findsOneWidget);
    expect(find.text('Attempts 0'), findsOneWidget);
    expect(find.text('Channel api'), findsOneWidget);
    expect(find.text('Lines 1'), findsOneWidget);
    expect(find.textContaining('Total'), findsOneWidget);

    await tester.tap(find.text(entry.idempotencyKey));
    await tester.pumpAndSettle();

    expect(find.text('Tenant'), findsOneWidget);
    expect(find.text('tenant-a'), findsOneWidget);
    expect(find.text('Fingerprint'), findsOneWidget);
    expect(find.text(entry.draftFingerprint), findsOneWidget);
    expect(find.text('Retry status'), findsOneWidget);
    expect(find.text('Attempts left'), findsOneWidget);
    expect(find.text('Payload'), findsOneWidget);
    expect(find.textContaining('"tenantId": "tenant-a"'), findsOneWidget);
  });

  testWidgets('BillingInvoiceIssueOutboxEntryTile renders failure details', (
    tester,
  ) async {
    final entry = _entry()
        .markSyncing(updatedAt: DateTime(2026, 5, 31, 9, 2))
        .markFailed(
          error: 'network unavailable',
          updatedAt: DateTime(2026, 5, 31, 9, 3),
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BillingInvoiceIssueOutboxEntryTile(entry: entry),
          ),
        ),
      ),
    );

    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Attempts 1'), findsOneWidget);

    await tester.tap(find.text(entry.idempotencyKey));
    await tester.pumpAndSettle();

    expect(find.text('Last error'), findsOneWidget);
    expect(find.text('network unavailable'), findsOneWidget);
  });
}

BillingInvoiceIssueOutboxEntry _entry({String channel = 'manual'}) {
  final command = buildBillingInvoiceIssueCommand(
    BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 0,
      issueDate: DateTime(2026, 5, 31),
      lineItems: const [
        BillingInvoiceLineItem(
          id: 'plan-pro',
          description: 'Pro plan',
          quantity: 2,
          unitPrice: 50,
          taxRate: 0.1,
        ),
      ],
    ),
    requestedAt: DateTime(2026, 5, 31, 9),
    channel: channel,
  );

  return BillingInvoiceIssueOutboxEntry.fromCommand(
    command,
    createdAt: DateTime(2026, 5, 31, 9, 1),
  );
}
