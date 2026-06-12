import 'package:flutter/material.dart';

import '../logic/survey_response_section_flow.dart';

/// Displays the readiness state for the selected response section.
class SurveyResponseSectionStatusChip extends StatelessWidget {
  final SurveyResponseSectionPageStatus status;

  const SurveyResponseSectionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(Theme.of(context).colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_statusIcon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              status.statusLabel,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _statusIcon {
    if (status.hasIssues) {
      return Icons.error_outline;
    }

    if (status.isComplete) {
      return Icons.task_alt_outlined;
    }

    return Icons.pending_actions_outlined;
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (status.hasIssues) {
      return colorScheme.error;
    }

    if (status.isComplete) {
      return colorScheme.primary;
    }

    return colorScheme.onSurfaceVariant;
  }
}
