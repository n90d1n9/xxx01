import 'package:flutter/material.dart';

import 'registry_health_api_consistency_scorecard.dart';

class RegistryHealthApiConsistencyScorecardPanel extends StatelessWidget {
  const RegistryHealthApiConsistencyScorecardPanel({
    super.key,
    required this.scorecard,
  });

  final RegistryHealthApiConsistencyScorecard scorecard;

  @override
  Widget build(BuildContext context) {
    final gradeColor = registryHealthApiConsistencyScoreGradeColor(
      scorecard.grade,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Scorecard', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ScoreMetricChip(
              label: 'Score',
              value: '${scorecard.scorePercent}%',
              color: gradeColor,
            ),
            _ScoreMetricChip(
              label: 'Grade',
              value: scorecard.gradeLabel,
              color: gradeColor,
            ),
            _ScoreMetricChip(
              label: 'Required Penalty',
              value: registryHealthApiConsistencyScoreWeightLabel(
                scorecard.requiredPenaltyWeight,
              ),
              color: scorecard.requiredPenaltyWeight == 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
            _ScoreMetricChip(
              label: 'Advisory Penalty',
              value: registryHealthApiConsistencyScoreWeightLabel(
                scorecard.advisoryPenaltyWeight,
              ),
              color: scorecard.advisoryPenaltyWeight == 0
                  ? Colors.green.shade700
                  : Colors.orange.shade800,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: scorecard.scoreRatio,
            minHeight: 6,
            color: gradeColor,
            backgroundColor: gradeColor.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

Color registryHealthApiConsistencyScoreGradeColor(
  RegistryHealthApiConsistencyScoreGrade grade,
) {
  switch (grade) {
    case RegistryHealthApiConsistencyScoreGrade.excellent:
      return Colors.green.shade700;
    case RegistryHealthApiConsistencyScoreGrade.good:
      return Colors.blue.shade700;
    case RegistryHealthApiConsistencyScoreGrade.watch:
      return Colors.orange.shade800;
    case RegistryHealthApiConsistencyScoreGrade.blocked:
      return Colors.red.shade700;
  }
}

class _ScoreMetricChip extends StatelessWidget {
  const _ScoreMetricChip({
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
        child: Icon(Icons.speed_outlined, size: 14, color: color),
      ),
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
