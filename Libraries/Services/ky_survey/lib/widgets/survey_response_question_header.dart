import 'package:flutter/material.dart';

/// Displays the question title and compact required/optional status chips.
class SurveyResponseQuestionHeader extends StatelessWidget {
  final String title;
  final bool isRequired;
  final bool enabled;
  final bool hasIssues;
  final bool highlighted;

  const SurveyResponseQuestionHeader({
    super.key,
    required this.title,
    required this.isRequired,
    required this.enabled,
    required this.hasIssues,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        SurveyResponseQuestionStateChip(
          label: isRequired ? 'Required' : 'Optional',
          icon: isRequired ? Icons.star_rounded : Icons.remove_red_eye_outlined,
          color: hasIssues
              ? colorScheme.error
              : isRequired
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        if (highlighted)
          SurveyResponseQuestionStateChip(
            label: 'Focused',
            icon: Icons.center_focus_strong_outlined,
            color: colorScheme.primary,
          ),
        if (!enabled)
          SurveyResponseQuestionStateChip(
            label: 'Read-only',
            icon: Icons.lock_outline,
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}

/// Renders compact metadata chips for response question cards.
class SurveyResponseQuestionStateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const SurveyResponseQuestionStateChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
