part of 'survey_operations_center_panel.dart';

/// Lays out the four headline operations counts without nesting cards.
class _OperationsMetricStrip extends StatelessWidget {
  final SurveyOperationsCenterInsights insights;

  const _OperationsMetricStrip({required this.insights});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = width >= 760
            ? (width - 30) / 4
            : width >= 420
            ? (width - 10) / 2
            : width;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _OperationMetric(
              width: itemWidth,
              icon: Icons.priority_high_outlined,
              label: 'Attention',
              value: insights.attentionCount.toString(),
            ),
            _OperationMetric(
              width: itemWidth,
              icon: Icons.rocket_launch_outlined,
              label: 'Ready',
              value: insights.readyWorkCount.toString(),
            ),
            _OperationMetric(
              width: itemWidth,
              icon: Icons.sync_outlined,
              label: 'Waiting sync',
              value: insights.waitingSyncCount.toString(),
            ),
            _OperationMetric(
              width: itemWidth,
              icon: Icons.cloud_queue_outlined,
              label: 'Queue depth',
              value: insights.queueDepth.toString(),
            ),
          ],
        );
      },
    );
  }
}

/// Presents a single compact operations metric.
class _OperationMetric extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;

  const _OperationMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
