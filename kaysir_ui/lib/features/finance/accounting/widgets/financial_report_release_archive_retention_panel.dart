import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/financial_report_release_archive_retention.dart';
import 'financial_report_release_signoff_shared.dart';
import 'financial_report_responsive_grid_components.dart';
import 'financial_report_tinted_surface_components.dart';

class FinancialReportReleaseArchiveRetentionPanel extends StatelessWidget {
  const FinancialReportReleaseArchiveRetentionPanel({
    required this.summary,
    this.onReview,
    this.onRequestDisposalReview,
    super.key,
  });

  final FinancialReportReleaseArchiveRetentionSummary summary;
  final VoidCallback? onReview;
  final VoidCallback? onRequestDisposalReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(summary.status, colorScheme);

    return FinancialReportReleaseSignOffSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final title = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FinancialReportReleaseSignOffIcon(
                    icon: Icons.policy_rounded,
                    color: color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Archive Retention Monitor',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          summary.nextAction,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FinancialReportReleaseSignOffBadge(
                    label: summary.status.label,
                    color: color,
                  ),
                  if (summary.hasArchive)
                    OutlinedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.fact_check_rounded, size: 18),
                      label: const Text('Mark reviewed'),
                    ),
                  if (_canRequestDisposalReview(summary))
                    OutlinedButton.icon(
                      onPressed: onRequestDisposalReview,
                      icon: const Icon(Icons.rule_folder_rounded, size: 18),
                      label: const Text('Disposal review'),
                    ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), actions],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 12),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FinancialReportReleaseSignOffBadge(
                label: 'As of ${_date(summary.asOf)}',
                color: colorScheme.primary,
              ),
              FinancialReportReleaseSignOffBadge(
                label:
                    summary.retainUntil == null
                        ? 'No deadline'
                        : 'Retain until ${_date(summary.retainUntil!)}',
                color: colorScheme.secondary,
              ),
              FinancialReportReleaseSignOffBadge(
                label: '${summary.reviewWindowDays}d review window',
                color: Colors.blueGrey,
              ),
              if (summary.lastReviewAt != null)
                FinancialReportReleaseSignOffBadge(
                  label: 'Last ${_date(summary.lastReviewAt!)}',
                  color: Colors.teal.shade700,
                ),
            ],
          ),
          if (summary.checkpoints.isNotEmpty) ...[
            const SizedBox(height: 12),
            FinancialReportResponsiveWrapGrid<
              FinancialReportReleaseArchiveRetentionCheckpoint
            >(
              items: summary.checkpoints,
              breakpoints: const [
                FinancialReportResponsiveGridBreakpoint(
                  minWidth: 680,
                  columns: 3,
                ),
              ],
              itemBuilder:
                  (_, checkpoint) =>
                      _RetentionCheckpointTile(checkpoint: checkpoint),
            ),
          ],
        ],
      ),
    );
  }
}

class FinancialReportReleaseArchiveRetentionActionInput {
  final String note;

  const FinancialReportReleaseArchiveRetentionActionInput({required this.note});
}

class FinancialReportReleaseArchiveRetentionActionDialog
    extends StatefulWidget {
  const FinancialReportReleaseArchiveRetentionActionDialog({
    required this.title,
    required this.actionLabel,
    this.initialNote = '',
    super.key,
  });

  final String title;
  final String actionLabel;
  final String initialNote;

  @override
  State<FinancialReportReleaseArchiveRetentionActionDialog> createState() =>
      _FinancialReportReleaseArchiveRetentionActionDialogState();
}

class _FinancialReportReleaseArchiveRetentionActionDialogState
    extends State<FinancialReportReleaseArchiveRetentionActionDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _noteController,
          minLines: 3,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Review note',
            prefixIcon: Icon(Icons.notes_rounded),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop(
              FinancialReportReleaseArchiveRetentionActionInput(
                note: _noteController.text,
              ),
            );
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

class _RetentionCheckpointTile extends StatelessWidget {
  const _RetentionCheckpointTile({required this.checkpoint});

  final FinancialReportReleaseArchiveRetentionCheckpoint checkpoint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(checkpoint.status, colorScheme);

    return FinancialReportTintedSurface(
      color: color,
      minHeight: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(checkpoint.status), color: color, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  checkpoint.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            checkpoint.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            checkpoint.detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(
  FinancialReportReleaseArchiveRetentionStatus status,
  ColorScheme colorScheme,
) {
  switch (status) {
    case FinancialReportReleaseArchiveRetentionStatus.notArchived:
      return colorScheme.error;
    case FinancialReportReleaseArchiveRetentionStatus.active:
      return Colors.teal.shade700;
    case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
      return colorScheme.tertiary;
    case FinancialReportReleaseArchiveRetentionStatus.expired:
      return colorScheme.error;
  }
}

IconData _statusIcon(FinancialReportReleaseArchiveRetentionStatus status) {
  switch (status) {
    case FinancialReportReleaseArchiveRetentionStatus.notArchived:
      return Icons.archive_outlined;
    case FinancialReportReleaseArchiveRetentionStatus.active:
      return Icons.verified_user_rounded;
    case FinancialReportReleaseArchiveRetentionStatus.reviewDue:
      return Icons.event_repeat_rounded;
    case FinancialReportReleaseArchiveRetentionStatus.expired:
      return Icons.warning_rounded;
  }
}

String _date(DateTime date) {
  return DateFormat('MMM d, yyyy').format(date);
}

bool _canRequestDisposalReview(
  FinancialReportReleaseArchiveRetentionSummary summary,
) {
  if (!summary.hasArchive) {
    return false;
  }
  return summary.status ==
          FinancialReportReleaseArchiveRetentionStatus.expired ||
      summary.status == FinancialReportReleaseArchiveRetentionStatus.reviewDue;
}
