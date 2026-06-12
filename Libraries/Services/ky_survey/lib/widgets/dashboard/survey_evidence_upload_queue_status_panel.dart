import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_upload_queue_insights.dart';
import '../../logic/survey_evidence_upload_queue.dart';
import 'survey_dashboard_shared.dart';

class SurveyEvidenceUploadQueueStatusPanel extends StatelessWidget {
  final SurveyEvidenceUploadQueueInsights insights;
  final VoidCallback? onRunDueUploads;
  final VoidCallback? onMaintainQueue;
  final VoidCallback? onRequeueFailedUploads;
  final String runDueUploadsLabel;
  final String maintainQueueLabel;
  final String requeueFailedUploadsLabel;
  final int visibleEntryLimit;

  const SurveyEvidenceUploadQueueStatusPanel({
    super.key,
    required this.insights,
    this.onRunDueUploads,
    this.onMaintainQueue,
    this.onRequeueFailedUploads,
    this.runDueUploadsLabel = 'Run due',
    this.maintainQueueLabel = 'Maintain',
    this.requeueFailedUploadsLabel = 'Requeue failed',
    this.visibleEntryLimit = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.queue.isEmpty) {
      return const SurveyEmptyState(
        icon: Icons.cloud_done_outlined,
        title: 'No queued uploads',
        subtitle: 'Evidence uploads will appear here after they are queued.',
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _healthColor(colorScheme);
    final entries = _focusEntries;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 14,
              runSpacing: 12,
              children: [
                _QueueHealthHeader(
                  color: color,
                  icon: _healthIcon,
                  title: insights.healthLabel,
                  subtitle: insights.summaryLabel,
                ),
                _QueueActionBar(
                  insights: insights,
                  onRunDueUploads: onRunDueUploads,
                  onMaintainQueue: onMaintainQueue,
                  onRequeueFailedUploads: onRequeueFailedUploads,
                  runDueUploadsLabel: runDueUploadsLabel,
                  maintainQueueLabel: maintainQueueLabel,
                  requeueFailedUploadsLabel: requeueFailedUploadsLabel,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _QueueStatStrip(insights: insights),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: colorScheme.outlineVariant, height: 1),
              const SizedBox(height: 4),
              for (final entry in entries)
                _QueueEntryRow(entry: entry, now: insights.now),
            ],
          ],
        ),
      ),
    );
  }

  List<SurveyEvidenceUploadQueueEntry> get _focusEntries {
    final entries = <SurveyEvidenceUploadQueueEntry>[
      ...insights.failedEntries,
      ...insights.staleUploadingEntries,
      ...insights.dueEntries,
      ...insights.waitingEntries,
    ];
    final seenIds = <String>{};
    final uniqueEntries = <SurveyEvidenceUploadQueueEntry>[];

    for (final entry in entries) {
      if (seenIds.add(entry.id)) {
        uniqueEntries.add(entry);
      }
      if (uniqueEntries.length >= visibleEntryLimit) {
        break;
      }
    }

    return uniqueEntries;
  }

  IconData get _healthIcon {
    switch (insights.health) {
      case SurveyEvidenceUploadQueueHealth.empty:
        return Icons.cloud_done_outlined;
      case SurveyEvidenceUploadQueueHealth.ready:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceUploadQueueHealth.waiting:
        return Icons.schedule_outlined;
      case SurveyEvidenceUploadQueueHealth.uploading:
        return Icons.sync_outlined;
      case SurveyEvidenceUploadQueueHealth.needsAttention:
        return Icons.warning_amber_outlined;
      case SurveyEvidenceUploadQueueHealth.complete:
        return Icons.task_alt_outlined;
    }
  }

  Color _healthColor(ColorScheme colorScheme) {
    switch (insights.health) {
      case SurveyEvidenceUploadQueueHealth.empty:
      case SurveyEvidenceUploadQueueHealth.waiting:
        return colorScheme.onSurfaceVariant;
      case SurveyEvidenceUploadQueueHealth.ready:
      case SurveyEvidenceUploadQueueHealth.uploading:
        return colorScheme.tertiary;
      case SurveyEvidenceUploadQueueHealth.needsAttention:
        return colorScheme.error;
      case SurveyEvidenceUploadQueueHealth.complete:
        return colorScheme.primary;
    }
  }
}

class _QueueHealthHeader extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _QueueHealthHeader({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QueueActionBar extends StatelessWidget {
  final SurveyEvidenceUploadQueueInsights insights;
  final VoidCallback? onRunDueUploads;
  final VoidCallback? onMaintainQueue;
  final VoidCallback? onRequeueFailedUploads;
  final String runDueUploadsLabel;
  final String maintainQueueLabel;
  final String requeueFailedUploadsLabel;

  const _QueueActionBar({
    required this.insights,
    required this.onRunDueUploads,
    required this.onMaintainQueue,
    required this.onRequeueFailedUploads,
    required this.runDueUploadsLabel,
    required this.maintainQueueLabel,
    required this.requeueFailedUploadsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onRunDueUploads != null && insights.dueCount > 0)
          FilledButton.icon(
            icon: const Icon(Icons.cloud_upload_outlined, size: 18),
            label: Text(runDueUploadsLabel),
            onPressed: onRunDueUploads,
          ),
        if (onRequeueFailedUploads != null && insights.failedCount > 0)
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh_outlined, size: 18),
            label: Text(requeueFailedUploadsLabel),
            onPressed: onRequeueFailedUploads,
          ),
        if (onMaintainQueue != null)
          OutlinedButton.icon(
            icon: const Icon(Icons.tune_outlined, size: 18),
            label: Text(maintainQueueLabel),
            onPressed: onMaintainQueue,
          ),
      ],
    );
  }
}

class _QueueStatStrip extends StatelessWidget {
  final SurveyEvidenceUploadQueueInsights insights;

  const _QueueStatStrip({required this.insights});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _QueueStatChip(label: 'Due', value: insights.dueCount.toString()),
        _QueueStatChip(
          label: 'Waiting',
          value: insights.waitingCount.toString(),
        ),
        _QueueStatChip(
          label: 'Uploading',
          value: insights.uploadingCount.toString(),
        ),
        _QueueStatChip(label: 'Failed', value: insights.failedCount.toString()),
        _QueueStatChip(
          label: 'Complete',
          value: insights.terminalCount.toString(),
        ),
        if (insights.nextWakeAt != null)
          _QueueStatChip(label: 'Next retry', value: _nextWakeLabel),
      ],
    );
  }

  String get _nextWakeLabel {
    final wait = insights.waitUntilNextWake;
    if (wait == null) {
      return '-';
    }
    if (wait == Duration.zero) {
      return 'now';
    }
    if (wait.inHours > 0) {
      return '${wait.inHours}h';
    }
    return '${wait.inMinutes}m';
  }
}

class _QueueStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _QueueStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 94),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueEntryRow extends StatelessWidget {
  final SurveyEvidenceUploadQueueEntry entry;
  final DateTime now;

  const _QueueEntryRow({required this.entry, required this.now});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(colorScheme);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_statusIcon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _statusLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    final evidenceTitle = entry.metadata['evidenceTitle'];
    if (evidenceTitle is String && evidenceTitle.trim().isNotEmpty) {
      return evidenceTitle;
    }

    return entry.evidenceId;
  }

  String get _detail {
    final parts = <String>[];
    final surveyTitle = entry.metadata['surveyTitle'];
    if (surveyTitle is String && surveyTitle.trim().isNotEmpty) {
      parts.add(surveyTitle);
    }
    if (entry.attemptCount > 0) {
      parts.add('${entry.attemptCount} attempts');
    }
    if (entry.lastError != null && entry.lastError!.trim().isNotEmpty) {
      parts.add(entry.lastError!);
    }

    return parts.isEmpty ? entry.id : parts.join(' • ');
  }

  String get _statusLabel {
    switch (entry.status) {
      case SurveyEvidenceUploadQueueStatus.pending:
        return entry.isDue(now) ? 'Due' : 'Waiting';
      case SurveyEvidenceUploadQueueStatus.uploading:
        return 'Uploading';
      case SurveyEvidenceUploadQueueStatus.uploaded:
        return 'Uploaded';
      case SurveyEvidenceUploadQueueStatus.failed:
        return 'Failed';
      case SurveyEvidenceUploadQueueStatus.skipped:
        return 'Skipped';
    }
  }

  IconData get _statusIcon {
    switch (entry.status) {
      case SurveyEvidenceUploadQueueStatus.pending:
        return Icons.pending_actions_outlined;
      case SurveyEvidenceUploadQueueStatus.uploading:
        return Icons.sync_outlined;
      case SurveyEvidenceUploadQueueStatus.uploaded:
        return Icons.cloud_done_outlined;
      case SurveyEvidenceUploadQueueStatus.failed:
        return Icons.cloud_off_outlined;
      case SurveyEvidenceUploadQueueStatus.skipped:
        return Icons.block_outlined;
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (entry.status) {
      case SurveyEvidenceUploadQueueStatus.pending:
      case SurveyEvidenceUploadQueueStatus.uploading:
        return colorScheme.tertiary;
      case SurveyEvidenceUploadQueueStatus.uploaded:
        return colorScheme.primary;
      case SurveyEvidenceUploadQueueStatus.failed:
      case SurveyEvidenceUploadQueueStatus.skipped:
        return colorScheme.error;
    }
  }
}
