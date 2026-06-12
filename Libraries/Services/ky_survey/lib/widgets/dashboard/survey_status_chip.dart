import 'package:flutter/material.dart';

import '../../models/survey_status.dart';

class SurveyStatusChip extends StatelessWidget {
  final SurveyStatus status;

  const SurveyStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case SurveyStatus.collecting:
      case SurveyStatus.published:
        return colorScheme.primary;
      case SurveyStatus.analyzing:
        return colorScheme.tertiary;
      case SurveyStatus.review:
        return colorScheme.secondary;
      case SurveyStatus.closed:
      case SurveyStatus.archived:
        return colorScheme.outline;
      case SurveyStatus.draft:
        return colorScheme.onSurfaceVariant;
    }
  }
}
