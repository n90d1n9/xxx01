part of 'survey_operations_center_panel.dart';

/// Displays the operations-center title, health, and primary status message.
class _OperationsHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String status;
  final String detail;

  const _OperationsHeader({
    required this.icon,
    required this.color,
    required this.status,
    required this.detail,
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
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Survey Operations Center',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$status • $detail',
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

/// Shows the primary operation button with an action-specific icon.
class _PrimaryOperationButton extends StatelessWidget {
  final SurveyOperationsCenterAction action;
  final String? labelOverride;
  final bool showDisabledCommand;
  final VoidCallback? onPressed;

  const _PrimaryOperationButton({
    required this.action,
    required this.labelOverride,
    required this.showDisabledCommand,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (onPressed == null && !showDisabledCommand) {
      return _PrimaryOperationStatusPill(action: action);
    }

    return FilledButton.icon(
      icon: Icon(_iconFor(action.kind), size: 18),
      label: Text(labelOverride ?? _buttonLabelFor(action.kind)),
      onPressed: onPressed,
    );
  }
}

/// Shows primary operation status when the current role has no direct command.
class _PrimaryOperationStatusPill extends StatelessWidget {
  final SurveyOperationsCenterAction action;

  const _PrimaryOperationStatusPill({required this.action});

  @override
  Widget build(BuildContext context) {
    return SurveyDashboardStatePill(
      label: action.count == 0 ? 'Up to date' : 'View only',
      tooltip: action.detail,
      icon: action.count == 0
          ? Icons.task_alt_outlined
          : Icons.visibility_outlined,
    );
  }
}
