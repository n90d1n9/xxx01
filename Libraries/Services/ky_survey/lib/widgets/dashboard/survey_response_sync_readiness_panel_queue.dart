part of 'survey_response_sync_readiness_panel.dart';

/// Displays one response readiness item with its current action state.
class _ReadinessQueueRow extends StatelessWidget {
  final SurveyResponseSyncReadiness item;
  final ValueChanged<SurveyResponseSyncReadiness>? onOpenResponse;

  const _ReadinessQueueRow({required this.item, this.onOpenResponse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _statusColor(colorScheme);
    final isInteractive = onOpenResponse != null;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: isInteractive ? () => onOpenResponse!(item) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_statusIcon(), size: 19, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.response.respondentName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _ReadinessStatusChip(
                              label: item.statusLabel,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.survey?.title ?? 'Survey definition unavailable',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.detailLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _ReadinessQueueAction(
                color: color,
                icon: _actionIcon(),
                tooltip: _actionTooltip(),
                onPressed: isInteractive ? () => onOpenResponse!(item) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _actionIcon() {
    switch (item.status) {
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return Icons.send_outlined;
      case SurveyResponseSyncReadinessStatus.needsAnswers:
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return Icons.edit_note_outlined;
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return Icons.visibility_outlined;
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return Icons.refresh_outlined;
      case SurveyResponseSyncReadinessStatus.submitted:
        return Icons.done_all_outlined;
      case SurveyResponseSyncReadinessStatus.discarded:
        return Icons.delete_outline;
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return Icons.link_off_outlined;
    }
  }

  String _actionTooltip() {
    switch (item.status) {
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return 'Review and submit response';
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return 'Resume answers';
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return 'Fix evidence';
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return 'View response';
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return 'Review failed upload';
      case SurveyResponseSyncReadinessStatus.submitted:
        return 'View submitted response';
      case SurveyResponseSyncReadinessStatus.discarded:
        return 'View discarded response';
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return 'Survey definition unavailable';
    }
  }

  IconData _statusIcon() {
    switch (item.status) {
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
        return Icons.task_alt_outlined;
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return Icons.fact_check_outlined;
      case SurveyResponseSyncReadinessStatus.needsEvidence:
        return Icons.attachment_outlined;
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return Icons.cloud_sync_outlined;
      case SurveyResponseSyncReadinessStatus.uploadFailed:
        return Icons.cloud_off_outlined;
      case SurveyResponseSyncReadinessStatus.submitted:
        return Icons.done_all_outlined;
      case SurveyResponseSyncReadinessStatus.discarded:
        return Icons.delete_outline;
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return Icons.link_off_outlined;
    }
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (item.status) {
      case SurveyResponseSyncReadinessStatus.readyToSubmit:
      case SurveyResponseSyncReadinessStatus.submitted:
        return colorScheme.primary;
      case SurveyResponseSyncReadinessStatus.needsAnswers:
        return colorScheme.tertiary;
      case SurveyResponseSyncReadinessStatus.needsEvidence:
      case SurveyResponseSyncReadinessStatus.uploadPending:
        return colorScheme.secondary;
      case SurveyResponseSyncReadinessStatus.uploadFailed:
      case SurveyResponseSyncReadinessStatus.missingSurvey:
        return colorScheme.error;
      case SurveyResponseSyncReadinessStatus.discarded:
        return colorScheme.onSurfaceVariant;
    }
  }
}

/// Shows the available response queue command or read-only state.
class _ReadinessQueueAction extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ReadinessQueueAction({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    if (onPressed == null) {
      return const SurveyReadOnlyPill(
        tooltip: 'Read-only response summary',
        compact: true,
      );
    }

    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      color: color,
      onPressed: onPressed,
    );
  }
}

/// Presents a response readiness state with compact dashboard styling.
class _ReadinessStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ReadinessStatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
