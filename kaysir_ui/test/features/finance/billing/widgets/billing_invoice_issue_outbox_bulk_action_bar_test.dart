import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_entry.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_retry_snapshot.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_issue_outbox_selection.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_invoice_issue_outbox_bulk_action_bar.dart';

void main() {
  testWidgets(
    'BillingInvoiceIssueOutboxBulkActionBar selects retry-ready commands',
    (tester) async {
      final ready = _entry('ready');
      final waiting = _entry('waiting');
      BillingInvoiceIssueOutboxSelection? changedSelection;

      await _pumpBar(
        tester,
        visibleEntries: [ready, waiting],
        retrySnapshots: {
          ready.idempotencyKey: _snapshot(
            BillingInvoiceIssueOutboxRetryReadiness.ready,
          ),
          waiting.idempotencyKey: _snapshot(
            BillingInvoiceIssueOutboxRetryReadiness.waiting,
          ),
        },
        selection: const BillingInvoiceIssueOutboxSelection(),
        onSelectionChanged: (selection) => changedSelection = selection,
      );

      await tester.tap(find.byTooltip('Select retry-ready commands'));
      await tester.pumpAndSettle();

      expect(changedSelection?.selectedKeys, {ready.idempotencyKey});
    },
  );

  testWidgets(
    'BillingInvoiceIssueOutboxBulkActionBar retries selected ready commands',
    (tester) async {
      final ready = _entry('ready');
      final waiting = _entry('waiting');
      Set<String>? retriedKeys;

      await _pumpBar(
        tester,
        visibleEntries: [ready, waiting],
        retrySnapshots: {
          ready.idempotencyKey: _snapshot(
            BillingInvoiceIssueOutboxRetryReadiness.ready,
          ),
          waiting.idempotencyKey: _snapshot(
            BillingInvoiceIssueOutboxRetryReadiness.waiting,
          ),
        },
        selection: BillingInvoiceIssueOutboxSelection.of([
          ready.idempotencyKey,
          waiting.idempotencyKey,
        ]),
        onRetrySelected: (keys) => retriedKeys = keys,
      );

      await tester.tap(find.byTooltip('Retry selected commands'));
      await tester.pumpAndSettle();

      expect(retriedKeys, {ready.idempotencyKey});
    },
  );
}

Future<void> _pumpBar(
  WidgetTester tester, {
  required List<BillingInvoiceIssueOutboxEntry> visibleEntries,
  required Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots,
  required BillingInvoiceIssueOutboxSelection selection,
  ValueChanged<BillingInvoiceIssueOutboxSelection>? onSelectionChanged,
  ValueChanged<Set<String>>? onRetrySelected,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: BillingInvoiceIssueOutboxBulkActionBar(
              visibleEntries: visibleEntries,
              retrySnapshots: retrySnapshots,
              selection: selection,
              isSyncing: false,
              onSelectionChanged: onSelectionChanged ?? (_) {},
              onRetrySelected: onRetrySelected ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

BillingInvoiceIssueOutboxEntry _entry(String idempotencyKey) {
  final now = DateTime(2026, 5, 31, 9);

  return BillingInvoiceIssueOutboxEntry(
    idempotencyKey: idempotencyKey,
    tenantId: 'tenant-a',
    draftFingerprint: 'draft-$idempotencyKey',
    status: BillingInvoiceIssueOutboxStatus.queued,
    createdAt: now,
    updatedAt: now,
    attemptCount: 0,
  );
}

BillingInvoiceIssueOutboxRetrySnapshot _snapshot(
  BillingInvoiceIssueOutboxRetryReadiness readiness,
) {
  return BillingInvoiceIssueOutboxRetrySnapshot(
    readiness: readiness,
    attemptsRemaining: 3,
    evaluatedAt: DateTime(2026, 5, 31, 10),
  );
}
