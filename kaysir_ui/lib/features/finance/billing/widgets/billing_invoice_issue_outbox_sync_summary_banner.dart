import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_sync_summary.dart';

class BillingInvoiceIssueOutboxSyncSummaryBanner extends StatelessWidget {
  final BillingInvoiceIssueOutboxSyncSummary summary;

  const BillingInvoiceIssueOutboxSyncSummaryBanner({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _IssueOutboxSyncSummaryTone.fromSummary(summary);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(tone.icon, color: tone.foregroundColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tone.title,
                      style: TextStyle(
                        color: tone.foregroundColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tone.message,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryPill(
                label: 'inspected',
                value: summary.inspectedCount,
                color: const Color(0xFF475569),
              ),
              _SummaryPill(
                label: 'synced',
                value: summary.syncedCount,
                color: const Color(0xFF047857),
              ),
              _SummaryPill(
                label: 'failed',
                value: summary.failedCount,
                color: const Color(0xFFB91C1C),
              ),
              _SummaryPill(
                label: 'waiting',
                value: summary.deferredCount,
                color: const Color(0xFFB45309),
              ),
              _SummaryPill(
                label: 'review',
                value: summary.exhaustedCount,
                color: const Color(0xFFB91C1C),
              ),
              if (summary.remainingCount > 0)
                _SummaryPill(
                  label: 'remaining',
                  value: summary.remainingCount,
                  color: const Color(0xFF2563EB),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IssueOutboxSyncSummaryTone {
  final String title;
  final String message;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _IssueOutboxSyncSummaryTone({
    required this.title,
    required this.message,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _IssueOutboxSyncSummaryTone.fromSummary(
    BillingInvoiceIssueOutboxSyncSummary summary,
  ) {
    if (summary.hasFailures) {
      return _IssueOutboxSyncSummaryTone(
        title: 'Sync needs attention',
        message:
            '${summary.failedCount} issue commands failed while '
            '${summary.syncedCount} synced.',
        icon: Icons.error_outline,
        foregroundColor: const Color(0xFFB91C1C),
        backgroundColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFECACA),
      );
    }

    if (summary.didWork) {
      return _IssueOutboxSyncSummaryTone(
        title: summary.hasMore ? 'Batch synced' : 'Sync complete',
        message:
            '${summary.syncedCount} issue commands synced'
            '${summary.hasMore ? ', more ready commands remain.' : '.'}',
        icon: Icons.cloud_done_outlined,
        foregroundColor: const Color(0xFF047857),
        backgroundColor: const Color(0xFFECFDF5),
        borderColor: const Color(0xFFA7F3D0),
      );
    }

    if (summary.hasBlockedEntries) {
      return _IssueOutboxSyncSummaryTone(
        title: 'No commands retried',
        message: 'The current queue is waiting or needs manual review.',
        icon: Icons.schedule_outlined,
        foregroundColor: const Color(0xFFB45309),
        backgroundColor: const Color(0xFFFFFBEB),
        borderColor: const Color(0xFFFDE68A),
      );
    }

    return const _IssueOutboxSyncSummaryTone(
      title: 'No eligible commands',
      message: 'There were no ready issue commands to sync.',
      icon: Icons.inbox_outlined,
      foregroundColor: Color(0xFF475569),
      backgroundColor: Color(0xFFF8FAFC),
      borderColor: Color(0xFFE2E8F0),
    );
  }
}
