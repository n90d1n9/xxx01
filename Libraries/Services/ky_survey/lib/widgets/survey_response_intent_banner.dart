import 'package:flutter/material.dart';

import '../logic/survey_response_view_intent.dart';

class SurveyResponseIntentBanner extends StatelessWidget {
  final SurveyResponseViewerIntent intent;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SurveyResponseIntentBanner({
    super.key,
    required this.intent,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _intentColor(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_intentIcon(), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intent.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    intent.detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        icon: Icon(_actionIcon(), size: 18),
                        label: Text(actionLabel!),
                        onPressed: onAction,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _intentIcon() {
    switch (intent.focus) {
      case SurveyResponseViewerFocus.answerIssue:
        return Icons.fact_check_outlined;
      case SurveyResponseViewerFocus.evidenceIssue:
        return Icons.attachment_outlined;
      case SurveyResponseViewerFocus.uploadIssue:
        return Icons.cloud_sync_outlined;
      case SurveyResponseViewerFocus.submitReview:
        return Icons.send_outlined;
      case SurveyResponseViewerFocus.readOnly:
        return Icons.visibility_outlined;
      case SurveyResponseViewerFocus.standard:
        return Icons.info_outline;
    }
  }

  IconData _actionIcon() {
    switch (intent.focus) {
      case SurveyResponseViewerFocus.answerIssue:
        return Icons.rule_outlined;
      case SurveyResponseViewerFocus.evidenceIssue:
        return Icons.add_photo_alternate_outlined;
      case SurveyResponseViewerFocus.uploadIssue:
        return Icons.manage_search_outlined;
      case SurveyResponseViewerFocus.submitReview:
        return Icons.send_outlined;
      case SurveyResponseViewerFocus.readOnly:
        return Icons.visibility_outlined;
      case SurveyResponseViewerFocus.standard:
        return Icons.arrow_forward_outlined;
    }
  }

  Color _intentColor(ColorScheme colorScheme) {
    switch (intent.focus) {
      case SurveyResponseViewerFocus.answerIssue:
        return colorScheme.tertiary;
      case SurveyResponseViewerFocus.evidenceIssue:
      case SurveyResponseViewerFocus.uploadIssue:
        return colorScheme.secondary;
      case SurveyResponseViewerFocus.submitReview:
      case SurveyResponseViewerFocus.standard:
        return colorScheme.primary;
      case SurveyResponseViewerFocus.readOnly:
        return colorScheme.onSurfaceVariant;
    }
  }
}
