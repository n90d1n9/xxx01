part of 'survey_operations_center_panel.dart';

/// Renders one recommended operations action with an optional direct command.
class _OperationActionRow extends StatelessWidget {
  final SurveyOperationsCenterAction action;
  final String? labelOverride;
  final bool showDisabledCommand;
  final VoidCallback? onPressed;

  const _OperationActionRow({
    required this.action,
    required this.labelOverride,
    required this.showDisabledCommand,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(_iconFor(action.kind), color: colorScheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    action.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (onPressed != null || showDisabledCommand)
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward_outlined, size: 17),
                label: Text(labelOverride ?? _buttonLabelFor(action.kind)),
                onPressed: onPressed,
              )
            else
              _OperationCountPill(count: action.count),
          ],
        ),
      ),
    );
  }
}

/// Shows an action count when no direct callback is available.
class _OperationCountPill extends StatelessWidget {
  final int count;

  const _OperationCountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          count.toString(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(SurveyOperationsCenterActionKind kind) {
  switch (kind) {
    case SurveyOperationsCenterActionKind.openFieldworkQueue:
      return Icons.assignment_turned_in_outlined;
    case SurveyOperationsCenterActionKind.runDueUploads:
    case SurveyOperationsCenterActionKind.runUploadPlan:
      return Icons.cloud_upload_outlined;
    case SurveyOperationsCenterActionKind.requeueFailedUploads:
      return Icons.refresh_outlined;
    case SurveyOperationsCenterActionKind.maintainUploadQueue:
      return Icons.tune_outlined;
    case SurveyOperationsCenterActionKind.monitorUploadQueue:
      return Icons.sync_outlined;
    case SurveyOperationsCenterActionKind.reviewReports:
      return Icons.summarize_outlined;
  }
}

String _buttonLabelFor(SurveyOperationsCenterActionKind kind) {
  switch (kind) {
    case SurveyOperationsCenterActionKind.openFieldworkQueue:
      return 'Open queue';
    case SurveyOperationsCenterActionKind.runDueUploads:
      return 'Run due';
    case SurveyOperationsCenterActionKind.runUploadPlan:
      return 'Upload ready';
    case SurveyOperationsCenterActionKind.requeueFailedUploads:
      return 'Requeue';
    case SurveyOperationsCenterActionKind.maintainUploadQueue:
      return 'Maintain';
    case SurveyOperationsCenterActionKind.monitorUploadQueue:
      return 'Monitor';
    case SurveyOperationsCenterActionKind.reviewReports:
      return 'Review';
  }
}
