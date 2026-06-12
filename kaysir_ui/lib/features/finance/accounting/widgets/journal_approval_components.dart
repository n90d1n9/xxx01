import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';

import '../accounting_core/models/journal_entry.dart';
import '../models/journal_approval.dart';
import '../models/journal_posting_trace.dart';
import '../services/journal_approval_service.dart';

/// Summary metrics for the journal approval queue.
class JournalApprovalSummaryStrip extends StatelessWidget {
  const JournalApprovalSummaryStrip({required this.summary, super.key});

  final JournalApprovalQueueSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricTile(
          label: 'Open',
          value: summary.openItems.toString(),
          icon: Icons.pending_actions_rounded,
        ),
        _MetricTile(
          label: 'Review',
          value: summary.pendingReview.toString(),
          icon: Icons.rate_review_rounded,
        ),
        _MetricTile(
          label: 'Approved',
          value: summary.approved.toString(),
          icon: Icons.verified_rounded,
        ),
        _MetricTile(
          label: 'Queue value',
          value: _formatCompactIdr(summary.totalAmount),
          icon: Icons.payments_rounded,
        ),
      ],
    );
  }
}

/// Search and status filter row for the journal approval screen.
class JournalApprovalToolbar extends StatelessWidget {
  const JournalApprovalToolbar({
    required this.controller,
    required this.status,
    required this.onQueryChanged,
    required this.onStatusChanged,
    required this.onCreateRequest,
    super.key,
  });

  final TextEditingController controller;
  final JournalApprovalStatus? status;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<JournalApprovalStatus?> onStatusChanged;
  final VoidCallback onCreateRequest;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final search = TextField(
          key: const ValueKey('journal-approval-search'),
          controller: controller,
          onChanged: onQueryChanged,
          decoration: const InputDecoration(
            labelText: 'Search journal, reference, owner',
            prefixIcon: Icon(Icons.search_rounded),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        );
        final filter = DropdownButtonFormField<JournalApprovalStatus?>(
          key: ValueKey('journal-approval-status-${status?.name ?? 'all'}'),
          initialValue: status,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All statuses', overflow: TextOverflow.ellipsis),
            ),
            for (final status in JournalApprovalStatus.values)
              DropdownMenuItem(
                value: status,
                child: Text(status.label, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onStatusChanged,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 10),
              filter,
              const SizedBox(height: 10),
              FilledButton.icon(
                key: const ValueKey('journal-approval-new-request'),
                onPressed: onCreateRequest,
                icon: const Icon(Icons.add_rounded),
                label: const Text('New journal'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: filter),
            const SizedBox(width: 12),
            FilledButton.icon(
              key: const ValueKey('journal-approval-new-request'),
              onPressed: onCreateRequest,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New journal'),
            ),
          ],
        );
      },
    );
  }
}

/// Review card for one journal approval request and its release actions.
class JournalApprovalRequestCard extends StatelessWidget {
  const JournalApprovalRequestCard({
    required this.request,
    required this.readiness,
    required this.postingTrace,
    required this.onApprove,
    required this.onReturn,
    required this.onResubmit,
    required this.onPost,
    required this.onRequestReversal,
    super.key,
  });

  final JournalApprovalRequest request;
  final JournalApprovalReadinessResult readiness;
  final JournalPostingTrace postingTrace;
  final VoidCallback? onApprove;
  final VoidCallback? onReturn;
  final VoidCallback? onResubmit;
  final VoidCallback? onPost;
  final VoidCallback? onRequestReversal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: ValueKey('journal-approval-card-${request.id}'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusChip(status: request.status),
                _RiskChip(risk: request.risk),
                _InfoChip(
                  icon: Icons.source_rounded,
                  label: request.draft.source.label,
                ),
                _InfoChip(
                  icon: Icons.payments_rounded,
                  label: _formatIdr(request.totalAmount),
                ),
                if (readiness.hasErrors)
                  _InfoChip(
                    icon: Icons.error_outline_rounded,
                    label: '${readiness.errorCount} blocker(s)',
                    isWarning: true,
                  ),
                if (request.hasReversalSchedule)
                  _InfoChip(
                    icon: Icons.event_repeat_rounded,
                    label: 'Reverse ${_formatShortDate(request.reversalDate!)}',
                  ),
                if (request.reversalRequested)
                  _InfoChip(
                    icon: Icons.sync_alt_rounded,
                    label: 'Reversal drafted',
                    color: colorScheme.tertiary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              request.draft.description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${request.draft.reference} - Prepared by ${request.preparerName} - '
              'Reviewer ${request.reviewerName}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            JournalApprovalLineTable(lines: request.draft.lines),
            const SizedBox(height: 12),
            JournalApprovalReadinessPanel(readiness: readiness),
            if (postingTrace.hasTrace) ...[
              const SizedBox(height: 10),
              JournalPostingTracePanel(trace: postingTrace),
            ],
            if ((request.returnReason ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _ReasonPanel(
                icon: Icons.assignment_return_rounded,
                label: 'Return note',
                value: request.returnReason!,
              ),
            ],
            if ((request.approvalNote ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _ReasonPanel(
                icon: Icons.verified_rounded,
                label: 'Approval note',
                value: request.approvalNote!,
              ),
            ],
            const SizedBox(height: 10),
            JournalApprovalAuditTrailPanel(events: request.auditTrail),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: ValueKey('journal-approval-approve-${request.id}'),
                  onPressed: onApprove,
                  icon: const Icon(Icons.verified_rounded),
                  label: const Text('Approve'),
                ),
                OutlinedButton.icon(
                  key: ValueKey('journal-approval-return-${request.id}'),
                  onPressed: onReturn,
                  icon: const Icon(Icons.assignment_return_rounded),
                  label: const Text('Return'),
                ),
                OutlinedButton.icon(
                  key: ValueKey('journal-approval-resubmit-${request.id}'),
                  onPressed: onResubmit,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Resubmit'),
                ),
                FilledButton.tonalIcon(
                  key: ValueKey('journal-approval-post-${request.id}'),
                  onPressed: onPost,
                  icon: const Icon(Icons.post_add_rounded),
                  label: const Text('Post'),
                ),
                if (request.status == JournalApprovalStatus.posted &&
                    !request.reversalRequested)
                  OutlinedButton.icon(
                    key: ValueKey('journal-approval-reverse-${request.id}'),
                    onPressed: onRequestReversal,
                    icon: const Icon(Icons.sync_alt_rounded),
                    label: const Text('Reverse'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact posting and reversal trace for a reviewed journal request.
class JournalPostingTracePanel extends StatelessWidget {
  const JournalPostingTracePanel({required this.trace, super.key});

  final JournalPostingTrace trace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rows = _traceRows();

    return DecoratedBox(
      key: ValueKey('journal-posting-trace-${trace.requestId}'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree_rounded,
                  size: 17,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Text(
                  'Posting trace',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  'Net ${_formatIdr(trace.netExposure)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color:
                        trace.isFullyReversed
                            ? colorScheme.tertiary
                            : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final row in rows) _TraceRow(row: row),
          ],
        ),
      ),
    );
  }

  List<_PostingTraceRowData> _traceRows() {
    return [
      if (trace.hasPosting)
        _PostingTraceRowData(
          icon:
              trace.postingFoundInLedger
                  ? Icons.task_alt_rounded
                  : Icons.find_in_page_rounded,
          label: 'GL posting',
          value: [
            trace.postingId,
            if (trace.postedAt != null) _formatAuditTime(trace.postedAt!),
            trace.postingFoundInLedger ? 'ledger matched' : 'ledger pending',
          ].whereType<String>().join(' - '),
        ),
      if (trace.hasOriginalLink)
        _PostingTraceRowData(
          icon: Icons.call_merge_rounded,
          label: 'Original journal',
          value: trace.originalReference ?? trace.originalRequestId!,
        ),
      if (trace.hasReversalLink)
        _PostingTraceRowData(
          icon: Icons.sync_alt_rounded,
          label: 'Reversal journal',
          value: [
            trace.reversalReference ?? trace.reversalRequestId,
            trace.reversalStatus?.label,
            if (trace.reversalPostingId != null)
              'posting ${trace.reversalPostingId}',
          ].whereType<String>().join(' - '),
        ),
    ];
  }
}

class _PostingTraceRowData {
  const _PostingTraceRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _TraceRow extends StatelessWidget {
  const _TraceRow({required this.row});

  final _PostingTraceRowData row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(row.icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 7),
          SizedBox(
            width: 104,
            child: Text(
              row.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              row.value,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact lifecycle timeline for one journal approval request.
class JournalApprovalAuditTrailPanel extends StatelessWidget {
  const JournalApprovalAuditTrailPanel({required this.events, super.key});

  final List<JournalApprovalAuditEvent> events;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestEvents = events.reversed.take(4).toList(growable: false);

    return DecoratedBox(
      key: const ValueKey('journal-approval-audit-trail'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.manage_history_rounded,
                  size: 17,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Text(
                  'Audit trail',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (latestEvents.isEmpty)
              Text(
                'No lifecycle events captured yet.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final event in latestEvents) _AuditTrailRow(event: event),
          ],
        ),
      ),
    );
  }
}

/// Compact debit and credit preview for a journal draft.
class JournalApprovalLineTable extends StatelessWidget {
  const JournalApprovalLineTable({required this.lines, super.key});

  final List<JournalLineDraft> lines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    line.accountName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 64,
                  child: Text(
                    line.side.label,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: Text(
                    _formatIdr(line.amount),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Readiness findings panel for approval and posting controls.
class JournalApprovalReadinessPanel extends StatelessWidget {
  const JournalApprovalReadinessPanel({required this.readiness, super.key});

  final JournalApprovalReadinessResult readiness;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final issues = readiness.issues;
    if (issues.isEmpty) {
      return _ReasonPanel(
        key: const ValueKey('journal-approval-ready-panel'),
        icon: Icons.task_alt_rounded,
        label: 'Readiness',
        value:
            readiness.canPost
                ? 'Approved journal is ready to post.'
                : 'Ready for approval.',
      );
    }

    return DecoratedBox(
      key: const ValueKey('journal-approval-issue-panel'),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${readiness.errorCount} blocker(s), '
              '${readiness.warningCount} warning(s)',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            for (final issue in issues.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      issue.isError
                          ? Icons.error_outline_rounded
                          : Icons.info_outline_rounded,
                      size: 16,
                      color:
                          issue.isError
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(issue.message)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for returning a journal approval request with a correction reason.
class JournalApprovalReturnDialog extends StatefulWidget {
  const JournalApprovalReturnDialog({super.key});

  @override
  State<JournalApprovalReturnDialog> createState() =>
      _JournalApprovalReturnDialogState();
}

class _JournalApprovalReturnDialogState
    extends State<JournalApprovalReturnDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Return journal'),
      content: TextField(
        key: const ValueKey('journal-approval-return-reason'),
        controller: _controller,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Correction reason',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('journal-approval-return-submit'),
          onPressed: () {
            final reason = _controller.text.trim();
            if (reason.isEmpty) return;
            Navigator.of(context).pop(reason);
          },
          child: const Text('Return'),
        ),
      ],
    );
  }
}

/// Dialog for choosing the accounting date of a reversing journal.
class JournalReversalRequestDialog extends StatefulWidget {
  const JournalReversalRequestDialog({
    required this.defaultDate,
    required this.minimumDate,
    super.key,
  });

  final DateTime defaultDate;
  final DateTime minimumDate;

  @override
  State<JournalReversalRequestDialog> createState() =>
      _JournalReversalRequestDialogState();
}

class _JournalReversalRequestDialogState
    extends State<JournalReversalRequestDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatInputDate(widget.defaultDate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create reversal'),
      content: TextField(
        key: const ValueKey('journal-reversal-date'),
        controller: _controller,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          labelText: 'Reversal date',
          helperText: 'Use yyyy-mm-dd',
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey('journal-reversal-submit'),
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _submit() {
    final value = _parseDate(_controller.text);
    if (value == null) {
      setState(() => _errorText = 'Enter a valid date.');
      return;
    }
    if (value.isBefore(_dateOnly(widget.minimumDate))) {
      setState(() {
        _errorText =
            'Date must be on or after ${_formatInputDate(widget.minimumDate)}.';
      });
      return;
    }

    Navigator.of(context).pop(value);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.primary, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditTrailRow extends StatelessWidget {
  const _AuditTrailRow({required this.event});

  final JournalApprovalAuditEvent event;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _auditActionIcon(event.action),
            size: 16,
            color: _auditActionColor(colorScheme, event.action),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.action.label} by ${event.actorName}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  [
                    _formatAuditTime(event.occurredAt),
                    if ((event.note ?? '').trim().isNotEmpty)
                      event.note!.trim(),
                  ].join(' - '),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final JournalApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (status) {
      JournalApprovalStatus.pendingReview => colorScheme.primary,
      JournalApprovalStatus.returned => colorScheme.error,
      JournalApprovalStatus.approved => colorScheme.tertiary,
      JournalApprovalStatus.posted => colorScheme.secondary,
    };

    return _InfoChip(
      icon: _statusIcon(status),
      label: status.label,
      color: color,
      isWarning: status == JournalApprovalStatus.returned,
    );
  }
}

class _RiskChip extends StatelessWidget {
  const _RiskChip({required this.risk});

  final JournalApprovalRisk risk;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (risk) {
      JournalApprovalRisk.low => colorScheme.secondary,
      JournalApprovalRisk.medium => colorScheme.tertiary,
      JournalApprovalRisk.high => colorScheme.error,
    };

    return _InfoChip(
      icon: Icons.shield_rounded,
      label: risk.label,
      color: color,
      isWarning: risk == JournalApprovalRisk.high,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor =
        color ?? (isWarning ? colorScheme.error : colorScheme.onSurfaceVariant);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: effectiveColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonPanel extends StatelessWidget {
  const _ReasonPanel({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _auditActionIcon(JournalApprovalAuditAction action) {
  switch (action) {
    case JournalApprovalAuditAction.submitted:
      return Icons.send_rounded;
    case JournalApprovalAuditAction.approved:
      return Icons.verified_rounded;
    case JournalApprovalAuditAction.returned:
      return Icons.assignment_return_rounded;
    case JournalApprovalAuditAction.resubmitted:
      return Icons.refresh_rounded;
    case JournalApprovalAuditAction.posted:
      return Icons.post_add_rounded;
    case JournalApprovalAuditAction.reversalRequested:
      return Icons.sync_alt_rounded;
  }
}

Color _auditActionColor(
  ColorScheme colorScheme,
  JournalApprovalAuditAction action,
) {
  switch (action) {
    case JournalApprovalAuditAction.submitted:
    case JournalApprovalAuditAction.resubmitted:
      return colorScheme.primary;
    case JournalApprovalAuditAction.approved:
    case JournalApprovalAuditAction.posted:
    case JournalApprovalAuditAction.reversalRequested:
      return colorScheme.tertiary;
    case JournalApprovalAuditAction.returned:
      return colorScheme.error;
  }
}

IconData _statusIcon(JournalApprovalStatus status) {
  switch (status) {
    case JournalApprovalStatus.pendingReview:
      return Icons.rate_review_rounded;
    case JournalApprovalStatus.returned:
      return Icons.assignment_return_rounded;
    case JournalApprovalStatus.approved:
      return Icons.verified_rounded;
    case JournalApprovalStatus.posted:
      return Icons.post_add_rounded;
  }
}

String _formatAuditTime(DateTime value) {
  return DateFormat('dd MMM yyyy HH:mm').format(value);
}

String _formatShortDate(DateTime value) {
  return DateFormat('dd MMM yyyy').format(value);
}

String _formatInputDate(DateTime value) {
  return DateFormat('yyyy-MM-dd').format(value);
}

DateTime? _parseDate(String value) {
  try {
    final parsed = DateFormat('yyyy-MM-dd').parseStrict(value.trim());
    return _dateOnly(parsed);
  } on FormatException {
    return null;
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _formatIdr(double value) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(value);
}

String _formatCompactIdr(double value) {
  if (value >= 1000000000) {
    return 'Rp ${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (value >= 1000000) {
    return 'Rp ${(value / 1000000).toStringAsFixed(1)}M';
  }
  return _formatIdr(value);
}

@Preview(name: 'Journal approval components')
Widget journalApprovalComponentsPreview() {
  final request = JournalApprovalRequest(
    id: 'preview',
    draft: JournalDraft(
      id: 'preview-je',
      date: DateTime(2026, 6, 10),
      reference: 'JE-PREVIEW',
      description: 'Accrue office rent',
      source: JournalSource.manualAdjustment,
      lines: const [
        JournalLineDraft(
          accountId: '8',
          accountName: 'Rent Expense',
          side: JournalSide.debit,
          amount: 12000000,
          memo: 'Rent accrual',
        ),
        JournalLineDraft(
          accountId: '4',
          accountName: 'Accounts Payable',
          side: JournalSide.credit,
          amount: 12000000,
          memo: 'Rent accrual',
        ),
      ],
    ),
    preparerName: 'Accounting staff',
    reviewerName: 'Controller',
    status: JournalApprovalStatus.pendingReview,
    submittedAt: DateTime(2026, 6, 10),
    dueAt: DateTime(2026, 6, 11),
    evidenceReference: 'AP-001',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: JournalApprovalRequestCard(
          request: request,
          readiness: const JournalApprovalReadinessResult(
            requestId: 'preview',
            status: JournalApprovalStatus.pendingReview,
            issues: [],
          ),
          postingTrace: JournalPostingTrace(
            requestId: 'preview',
            reference: 'JE-PREVIEW',
            amount: request.totalAmount,
            status: JournalApprovalStatus.pendingReview,
          ),
          onApprove: () {},
          onReturn: () {},
          onResubmit: null,
          onPost: null,
          onRequestReversal: null,
        ),
      ),
    ),
  );
}

@Preview(name: 'Journal posting trace panel')
Widget journalPostingTracePanelPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: JournalPostingTracePanel(
          trace: JournalPostingTrace(
            requestId: 'preview-posted',
            reference: 'JE-POSTED',
            amount: 12000000,
            status: JournalApprovalStatus.posted,
            postingId: 'posting-preview',
            postedAt: DateTime(2026, 6, 11, 10),
            postingFoundInLedger: true,
            reversalRequestId: 'approval-reversal-preview',
            reversalReference: 'JE-POSTED-REV',
            reversalStatus: JournalApprovalStatus.pendingReview,
            reversalAmount: 12000000,
          ),
        ),
      ),
    ),
  );
}

@Preview(name: 'Journal reversal dialog')
Widget journalReversalDialogPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: JournalReversalRequestDialog(
          defaultDate: DateTime(2026, 6, 12),
          minimumDate: DateTime(2026, 6, 10),
        ),
      ),
    ),
  );
}
