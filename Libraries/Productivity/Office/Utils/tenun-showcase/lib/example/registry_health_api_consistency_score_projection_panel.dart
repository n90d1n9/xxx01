import 'package:flutter/material.dart';

import 'registry_health_api_consistency_score_projection.dart';
import 'registry_health_api_consistency_scorecard_panel.dart';

class RegistryHealthApiConsistencyScoreProjectionPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyScoreProjectionPanel({
    super.key,
    required this.projection,
  });

  final RegistryHealthApiConsistencyScoreProjection projection;

  @override
  Widget build(BuildContext context) {
    if (projection.isClear) {
      return const Text('No score projection needed.');
    }

    final color = registryHealthApiConsistencyScoreGradeColor(
      projection.projectedGrade,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score Projection', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ProjectionMetricChip(
              label: 'Current',
              value: '${projection.scorecard.scorePercent}%',
              color: registryHealthApiConsistencyScoreGradeColor(
                projection.scorecard.grade,
              ),
            ),
            _ProjectionMetricChip(
              label: 'Projected',
              value: '${projection.projectedScorePercent}%',
              color: color,
            ),
            _ProjectionMetricChip(
              label: 'Grade',
              value: projection.projectedGradeLabel,
              color: color,
            ),
            _ProjectionMetricChip(
              label: 'Status',
              value: projection.statusLabel,
              color: color,
            ),
            _ProjectionMetricChip(
              label: 'Recover',
              value: '+${projection.totalImpactLabel}',
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final step in projection.steps) _ProjectionStepRow(step: step),
      ],
    );
  }
}

class _ProjectionMetricChip extends StatelessWidget {
  const _ProjectionMetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(Icons.trending_up_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ProjectionStepRow extends StatelessWidget {
  const _ProjectionStepRow({required this.step});

  final RegistryHealthApiConsistencyScoreProjectionStep step;

  @override
  Widget build(BuildContext context) {
    final color = registryHealthApiConsistencyScoreGradeColor(
      step.projectedGrade,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_upward_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  step.phaseLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '+${step.impactLabel}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${step.projectedScorePercent}% ${step.projectedGradeLabel}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${step.actionCount} actions',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  step.resolutionLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  step.statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
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
