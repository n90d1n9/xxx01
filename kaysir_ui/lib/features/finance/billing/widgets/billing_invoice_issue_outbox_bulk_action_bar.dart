import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_retry_snapshot.dart';
import '../models/billing_invoice_issue_outbox_selection.dart';

class BillingInvoiceIssueOutboxBulkActionBar extends StatelessWidget {
  final List<BillingInvoiceIssueOutboxEntry> visibleEntries;
  final Map<String, BillingInvoiceIssueOutboxRetrySnapshot> retrySnapshots;
  final BillingInvoiceIssueOutboxSelection selection;
  final bool isSyncing;
  final ValueChanged<BillingInvoiceIssueOutboxSelection> onSelectionChanged;
  final ValueChanged<Set<String>> onRetrySelected;

  const BillingInvoiceIssueOutboxBulkActionBar({
    super.key,
    required this.visibleEntries,
    required this.retrySnapshots,
    required this.selection,
    required this.isSyncing,
    required this.onSelectionChanged,
    required this.onRetrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedVisibleEntries = selection.selectedEntries(visibleEntries);
    final selectedReadyEntries = selection.selectedRetryReadyEntries(
      visibleEntries,
      retrySnapshots: retrySnapshots,
    );
    final readyVisibleCount =
        visibleEntries
            .where(
              (entry) =>
                  retrySnapshots[entry.idempotencyKey]?.canAttemptNow == true,
            )
            .length;
    final selectedReadyIds =
        selectedReadyEntries.map((entry) => entry.idempotencyKey).toSet();
    final canRetry = selectedReadyIds.isNotEmpty && !isSyncing;

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.checklist_outlined,
            size: 17,
            color: Color(0xFF475569),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${selectedVisibleEntries.length} selected'
              ' • ${selectedReadyEntries.length} ready',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Select retry-ready commands',
            onPressed:
                readyVisibleCount == 0
                    ? null
                    : () => onSelectionChanged(
                      selection.selectRetryReady(
                        visibleEntries,
                        retrySnapshots: retrySnapshots,
                      ),
                    ),
            icon: const Icon(Icons.select_all_outlined, size: 18),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            tooltip: 'Clear selected commands',
            onPressed:
                selection.isEmpty
                    ? null
                    : () => onSelectionChanged(selection.clear()),
            icon: const Icon(Icons.clear_outlined, size: 18),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
          ),
          IconButton.filled(
            tooltip: 'Retry selected commands',
            onPressed:
                canRetry ? () => onRetrySelected(selectedReadyIds) : null,
            icon:
                isSyncing
                    ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.sync_outlined, size: 17),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              disabledForegroundColor: const Color(0xFF94A3B8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
