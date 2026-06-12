import 'billing_invoice_issue_outbox_entry.dart';

class BillingInvoiceIssueOutboxSyncSummary {
  final int inspectedCount;
  final int remainingCount;
  final int deferredCount;
  final int exhaustedCount;
  final List<BillingInvoiceIssueOutboxEntry> syncedEntries;
  final List<BillingInvoiceIssueOutboxEntry> failedEntries;

  BillingInvoiceIssueOutboxSyncSummary({
    required this.inspectedCount,
    required this.remainingCount,
    this.deferredCount = 0,
    this.exhaustedCount = 0,
    Iterable<BillingInvoiceIssueOutboxEntry> syncedEntries = const [],
    Iterable<BillingInvoiceIssueOutboxEntry> failedEntries = const [],
  }) : syncedEntries = List.unmodifiable(syncedEntries),
       failedEntries = List.unmodifiable(failedEntries);

  int get attemptedCount => syncedEntries.length + failedEntries.length;

  int get syncedCount => syncedEntries.length;

  int get failedCount => failedEntries.length;

  bool get hasFailures => failedEntries.isNotEmpty;

  bool get hasMore => remainingCount > 0;

  bool get hasBlockedEntries => deferredCount > 0 || exhaustedCount > 0;

  bool get didWork => attemptedCount > 0;

  List<String> get remoteInvoiceIds {
    return List.unmodifiable(
      syncedEntries.map((entry) => entry.remoteInvoiceId).whereType<String>(),
    );
  }
}
