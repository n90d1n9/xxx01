import 'package:flutter/material.dart';

import '../logic/survey_response_question_status.dart';
import 'survey_response_question_status_chip.dart';

/// Presents question-level response states for the currently selected section.
class SurveyResponseQuestionStatusMap extends StatelessWidget {
  final SurveyResponseQuestionStatusSummary summary;
  final String? selectedQuestionId;
  final ValueChanged<String>? onQuestionSelected;

  const SurveyResponseQuestionStatusMap({
    super.key,
    required this.summary,
    this.selectedQuestionId,
    this.onQuestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (!summary.hasItems) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Question status',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              summary.statusLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in summary.items)
                  SurveyResponseQuestionStatusChip(
                    item: item,
                    selected: item.questionId == selectedQuestionId,
                    onSelected: onQuestionSelected,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
