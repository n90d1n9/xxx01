import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/billing_invoice_issue_outbox_entry.dart';
import '../models/billing_invoice_issue_outbox_retry_snapshot.dart';

class BillingInvoiceIssueOutboxEntryTile extends StatelessWidget {
  final BillingInvoiceIssueOutboxEntry entry;
  final BillingInvoiceIssueOutboxRetrySnapshot? retrySnapshot;

  const BillingInvoiceIssueOutboxEntryTile({
    super.key,
    required this.entry,
    this.retrySnapshot,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _IssueOutboxEntryVisuals.fromStatus(entry.status);
    final payload = entry.payload;
    final total = payload['total'];
    final lineCount = payload['lineCount'];
    final channel = payload['channel'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        collapsedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: visuals.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(visuals.icon, color: visuals.foregroundColor, size: 21),
        ),
        title: Text(
          entry.idempotencyKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              BillingInvoiceIssueOutboxStatusBadge(status: entry.status),
              if (retrySnapshot != null)
                BillingInvoiceIssueOutboxRetryBadge(snapshot: retrySnapshot!),
              _MiniFact(label: 'Attempts', value: '${entry.attemptCount}'),
              if (channel != null)
                _MiniFact(label: 'Channel', value: '$channel'),
              if (total != null) _MiniFact(label: 'Total', value: '$total'),
              if (lineCount != null)
                _MiniFact(label: 'Lines', value: '$lineCount'),
            ],
          ),
        ),
        children: [
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),
          _EntryFact(label: 'Tenant', value: entry.tenantId),
          _EntryFact(
            label: 'Created',
            value: entry.createdAt.toIso8601String(),
          ),
          _EntryFact(
            label: 'Updated',
            value: entry.updatedAt.toIso8601String(),
          ),
          _EntryFact(label: 'Fingerprint', value: entry.draftFingerprint),
          if (retrySnapshot != null) ...[
            _EntryFact(
              label: 'Retry status',
              value: _retryStatusText(retrySnapshot!),
            ),
            _EntryFact(
              label: 'Attempts left',
              value: '${retrySnapshot!.attemptsRemaining}',
            ),
            if (retrySnapshot!.nextAttemptAt != null)
              _EntryFact(
                label: 'Next retry',
                value: retrySnapshot!.nextAttemptAt!.toIso8601String(),
              ),
          ],
          if (entry.remoteInvoiceId != null)
            _EntryFact(label: 'Remote invoice', value: entry.remoteInvoiceId!),
          if (entry.lastError != null)
            _EntryFact(label: 'Last error', value: entry.lastError!),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.data_object_outlined,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Payload',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SelectableText(
                  const JsonEncoder.withIndent('  ').convert(entry.payload),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 12,
                    fontFeatures: [FontFeature.tabularFigures()],
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BillingInvoiceIssueOutboxRetryBadge extends StatelessWidget {
  final BillingInvoiceIssueOutboxRetrySnapshot snapshot;

  const BillingInvoiceIssueOutboxRetryBadge({
    super.key,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final visuals = _IssueOutboxRetryVisuals.fromReadiness(snapshot.readiness);

    return Tooltip(
      message: _retryTooltip(snapshot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: visuals.backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: visuals.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visuals.icon, color: visuals.foregroundColor, size: 14),
            const SizedBox(width: 4),
            Text(
              visuals.label,
              style: TextStyle(
                color: visuals.foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingInvoiceIssueOutboxStatusBadge extends StatelessWidget {
  final BillingInvoiceIssueOutboxStatus status;

  const BillingInvoiceIssueOutboxStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final visuals = _IssueOutboxEntryVisuals.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: visuals.backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visuals.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(visuals.icon, color: visuals.foregroundColor, size: 14),
          const SizedBox(width: 4),
          Text(
            visuals.label,
            style: TextStyle(
              color: visuals.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueOutboxRetryVisuals {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _IssueOutboxRetryVisuals({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _IssueOutboxRetryVisuals.fromReadiness(
    BillingInvoiceIssueOutboxRetryReadiness readiness,
  ) {
    switch (readiness) {
      case BillingInvoiceIssueOutboxRetryReadiness.ready:
        return const _IssueOutboxRetryVisuals(
          label: 'Ready now',
          icon: Icons.flash_on_outlined,
          foregroundColor: Color(0xFF047857),
          backgroundColor: Color(0xFFD1FAE5),
          borderColor: Color(0xFFA7F3D0),
        );
      case BillingInvoiceIssueOutboxRetryReadiness.waiting:
        return const _IssueOutboxRetryVisuals(
          label: 'Waiting',
          icon: Icons.schedule_outlined,
          foregroundColor: Color(0xFFB45309),
          backgroundColor: Color(0xFFFEF3C7),
          borderColor: Color(0xFFFDE68A),
        );
      case BillingInvoiceIssueOutboxRetryReadiness.exhausted:
        return const _IssueOutboxRetryVisuals(
          label: 'Review',
          icon: Icons.report_problem_outlined,
          foregroundColor: Color(0xFFB91C1C),
          backgroundColor: Color(0xFFFEE2E2),
          borderColor: Color(0xFFFECACA),
        );
      case BillingInvoiceIssueOutboxRetryReadiness.inFlight:
        return const _IssueOutboxRetryVisuals(
          label: 'In flight',
          icon: Icons.sync_outlined,
          foregroundColor: Color(0xFF7C3AED),
          backgroundColor: Color(0xFFEDE9FE),
          borderColor: Color(0xFFDDD6FE),
        );
      case BillingInvoiceIssueOutboxRetryReadiness.synced:
        return const _IssueOutboxRetryVisuals(
          label: 'Done',
          icon: Icons.cloud_done_outlined,
          foregroundColor: Color(0xFF047857),
          backgroundColor: Color(0xFFD1FAE5),
          borderColor: Color(0xFFA7F3D0),
        );
    }
  }
}

class _MiniFact extends StatelessWidget {
  final String label;
  final String value;

  const _MiniFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _retryStatusText(BillingInvoiceIssueOutboxRetrySnapshot snapshot) {
  switch (snapshot.readiness) {
    case BillingInvoiceIssueOutboxRetryReadiness.ready:
      return 'Ready now';
    case BillingInvoiceIssueOutboxRetryReadiness.waiting:
      return 'Waiting ${_formatDuration(snapshot.waitDuration)}';
    case BillingInvoiceIssueOutboxRetryReadiness.exhausted:
      return 'Manual review needed';
    case BillingInvoiceIssueOutboxRetryReadiness.inFlight:
      return 'Sync in progress';
    case BillingInvoiceIssueOutboxRetryReadiness.synced:
      return 'Synced';
  }
}

String _retryTooltip(BillingInvoiceIssueOutboxRetrySnapshot snapshot) {
  switch (snapshot.readiness) {
    case BillingInvoiceIssueOutboxRetryReadiness.ready:
      return '${snapshot.attemptsRemaining} attempts remaining';
    case BillingInvoiceIssueOutboxRetryReadiness.waiting:
      return 'Next retry in ${_formatDuration(snapshot.waitDuration)}';
    case BillingInvoiceIssueOutboxRetryReadiness.exhausted:
      return 'Retry attempts are exhausted';
    case BillingInvoiceIssueOutboxRetryReadiness.inFlight:
      return 'Issue command is currently syncing';
    case BillingInvoiceIssueOutboxRetryReadiness.synced:
      return 'Issue command has synced';
  }
}

String _formatDuration(Duration duration) {
  if (duration.inMinutes >= 1) return '${duration.inMinutes}m';
  if (duration.inSeconds >= 1) return '${duration.inSeconds}s';
  return 'now';
}

class _EntryFact extends StatelessWidget {
  final String label;
  final String value;

  const _EntryFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueOutboxEntryVisuals {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _IssueOutboxEntryVisuals({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _IssueOutboxEntryVisuals.fromStatus(
    BillingInvoiceIssueOutboxStatus status,
  ) {
    switch (status) {
      case BillingInvoiceIssueOutboxStatus.queued:
        return const _IssueOutboxEntryVisuals(
          label: 'Queued',
          icon: Icons.schedule_send_outlined,
          foregroundColor: Color(0xFF1D4ED8),
          backgroundColor: Color(0xFFDBEAFE),
          borderColor: Color(0xFFBFDBFE),
        );
      case BillingInvoiceIssueOutboxStatus.syncing:
        return const _IssueOutboxEntryVisuals(
          label: 'Syncing',
          icon: Icons.sync_outlined,
          foregroundColor: Color(0xFF7C3AED),
          backgroundColor: Color(0xFFEDE9FE),
          borderColor: Color(0xFFDDD6FE),
        );
      case BillingInvoiceIssueOutboxStatus.synced:
        return const _IssueOutboxEntryVisuals(
          label: 'Synced',
          icon: Icons.cloud_done_outlined,
          foregroundColor: Color(0xFF047857),
          backgroundColor: Color(0xFFD1FAE5),
          borderColor: Color(0xFFA7F3D0),
        );
      case BillingInvoiceIssueOutboxStatus.failed:
        return const _IssueOutboxEntryVisuals(
          label: 'Failed',
          icon: Icons.error_outline,
          foregroundColor: Color(0xFFB91C1C),
          backgroundColor: Color(0xFFFEE2E2),
          borderColor: Color(0xFFFECACA),
        );
    }
  }
}
