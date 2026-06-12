import 'package:flutter/material.dart';

import '../logic/survey_response_question_status.dart';

/// Shows one compact question response state shortcut.
class SurveyResponseQuestionStatusChip extends StatelessWidget {
  final SurveyResponseQuestionStatusItem item;
  final bool selected;
  final ValueChanged<String>? onSelected;

  const SurveyResponseQuestionStatusChip({
    super.key,
    required this.item,
    this.selected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _colorFor(colorScheme);
    final foreground = selected ? colorScheme.onPrimary : color;

    return Tooltip(
      message: item.tooltipLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onSelected == null ? null : () => onSelected!(item.questionId),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary
                  : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : color.withValues(alpha: 0.28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon, size: 14, color: foreground),
                  const SizedBox(width: 5),
                  Text(
                    '${item.questionLabel} ${item.shortStatusLabel}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (item.tone) {
      SurveyResponseQuestionStatusTone.answered => Icons.task_alt_outlined,
      SurveyResponseQuestionStatusTone.missing => Icons.star_rounded,
      SurveyResponseQuestionStatusTone.invalid => Icons.error_outline,
      SurveyResponseQuestionStatusTone.optional => Icons.radio_button_unchecked,
    };
  }

  Color _colorFor(ColorScheme colorScheme) {
    return switch (item.tone) {
      SurveyResponseQuestionStatusTone.answered => colorScheme.primary,
      SurveyResponseQuestionStatusTone.missing => colorScheme.error,
      SurveyResponseQuestionStatusTone.invalid => colorScheme.error,
      SurveyResponseQuestionStatusTone.optional => colorScheme.onSurfaceVariant,
    };
  }
}
