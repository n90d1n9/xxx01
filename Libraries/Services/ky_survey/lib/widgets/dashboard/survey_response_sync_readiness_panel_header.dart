part of 'survey_response_sync_readiness_panel.dart';

class _ReadinessHeader extends StatelessWidget {
  final _ReadinessPanelSnapshot snapshot;

  const _ReadinessHeader({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAction = snapshot.actionRequiredCount > 0;
    final color = hasAction ? colorScheme.error : colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            hasAction ? Icons.rule_folder_outlined : Icons.cloud_done_outlined,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Response Sync Readiness',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.summaryLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (snapshot.actionRequiredCount > 0) ...[
          const SizedBox(width: 12),
          _ReadinessCountBadge(
            label: 'Action',
            value: snapshot.actionRequiredCount,
            color: colorScheme.error,
          ),
        ],
      ],
    );
  }
}

class _ReadinessCountBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ReadinessCountBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$value $label',
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
