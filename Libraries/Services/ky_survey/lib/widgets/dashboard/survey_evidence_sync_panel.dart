import 'package:flutter/material.dart';

import '../../analytics/survey_evidence_sync_insights.dart';
import 'survey_dashboard_shared.dart';

class SurveyEvidenceSyncPanel extends StatelessWidget {
  final SurveyEvidenceSyncInsights insights;

  const SurveyEvidenceSyncPanel({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final queue = insights.itemsNeedingAttention(limit: 6);

    if (!insights.hasAttachments) {
      return const SurveyEmptyState(
        icon: Icons.cloud_done_outlined,
        title: 'No evidence attachments',
        subtitle:
            'Captured evidence attachments will appear here for sync review.',
      );
    }

    if (queue.isEmpty) {
      return const SurveyEmptyState(
        icon: Icons.verified_outlined,
        title: 'Evidence sync is clear',
        subtitle:
            'All required evidence attachments are uploaded or local-only.',
      );
    }

    return Column(
      children: [
        for (final item in queue)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EvidenceSyncTile(item: item),
          ),
      ],
    );
  }
}

class _EvidenceSyncTile extends StatelessWidget {
  final SurveyEvidenceSyncItem item;

  const _EvidenceSyncTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _stateColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_stateIcon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _EvidenceSyncBadge(label: item.stateLabel, color: color),
          ],
        ),
      ),
    );
  }

  IconData get _stateIcon {
    switch (item.state) {
      case SurveyEvidenceSyncState.blocked:
        return Icons.block_outlined;
      case SurveyEvidenceSyncState.failed:
        return Icons.cloud_off_outlined;
      case SurveyEvidenceSyncState.readyToUpload:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceSyncState.queued:
        return Icons.pending_actions_outlined;
      case SurveyEvidenceSyncState.uploading:
        return Icons.sync_outlined;
      case SurveyEvidenceSyncState.localOnly:
        return Icons.folder_outlined;
      case SurveyEvidenceSyncState.uploaded:
        return Icons.cloud_done_outlined;
    }
  }

  Color _stateColor(ColorScheme colorScheme) {
    switch (item.state) {
      case SurveyEvidenceSyncState.blocked:
      case SurveyEvidenceSyncState.failed:
        return colorScheme.error;
      case SurveyEvidenceSyncState.readyToUpload:
      case SurveyEvidenceSyncState.queued:
      case SurveyEvidenceSyncState.uploading:
        return colorScheme.tertiary;
      case SurveyEvidenceSyncState.localOnly:
        return colorScheme.onSurfaceVariant;
      case SurveyEvidenceSyncState.uploaded:
        return colorScheme.primary;
    }
  }
}

class _EvidenceSyncBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _EvidenceSyncBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
