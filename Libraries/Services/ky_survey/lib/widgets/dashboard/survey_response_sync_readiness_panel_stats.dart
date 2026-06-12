part of 'survey_response_sync_readiness_panel.dart';

class _ReadinessStatWrap extends StatelessWidget {
  final _ReadinessPanelSnapshot snapshot;

  const _ReadinessStatWrap({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = [
      _ReadinessStat(
        icon: Icons.task_alt_outlined,
        label: 'Ready',
        value: snapshot.readyToSubmitCount,
        color: colorScheme.primary,
      ),
      _ReadinessStat(
        icon: Icons.fact_check_outlined,
        label: 'Answers',
        value: snapshot.answerIssueCount,
        color: colorScheme.tertiary,
      ),
      _ReadinessStat(
        icon: Icons.attachment_outlined,
        label: 'Evidence',
        value: snapshot.evidenceIssueCount,
        color: colorScheme.secondary,
      ),
      _ReadinessStat(
        icon: Icons.cloud_sync_outlined,
        label: 'Waiting',
        value: snapshot.uploadPendingCount,
        color: colorScheme.primary,
      ),
      _ReadinessStat(
        icon: Icons.cloud_off_outlined,
        label: 'Failed',
        value: snapshot.uploadFailedCount,
        color: colorScheme.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final width = constraints.maxWidth;
        final columns = width >= 860
            ? 5
            : width >= 620
            ? 3
            : width >= 420
            ? 2
            : 1;
        final tileWidth = (width - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: tileWidth,
                child: _ReadinessStatTile(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _ReadinessStat {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _ReadinessStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _ReadinessStatTile extends StatelessWidget {
  final _ReadinessStat stat;

  const _ReadinessStatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: stat.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(stat.icon, size: 18, color: stat.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stat.value.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  Text(
                    stat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
