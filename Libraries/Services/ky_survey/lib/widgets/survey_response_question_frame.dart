import 'package:flutter/material.dart';

import 'survey_response_question_header.dart';
import 'survey_response_question_issue_panel.dart';
import 'survey_response_question_number_badge.dart';

/// Frames a response question with required state, helper copy, and issues.
class SurveyResponseQuestionFrame extends StatelessWidget {
  final int questionNumber;
  final String title;
  final bool isRequired;
  final Widget child;
  final List<String> issueMessages;
  final String? helperText;
  final bool enabled;
  final bool highlighted;

  const SurveyResponseQuestionFrame({
    super.key,
    required this.questionNumber,
    required this.title,
    required this.isRequired,
    required this.child,
    this.issueMessages = const [],
    this.helperText,
    this.enabled = true,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasIssues = issueMessages.isNotEmpty;
    final frameColor = hasIssues
        ? colorScheme.error
        : highlighted
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final statusColor = hasIssues
        ? colorScheme.error
        : highlighted || isRequired
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final statusForegroundColor = hasIssues
        ? colorScheme.onError
        : highlighted || isRequired
        ? colorScheme.onPrimary
        : colorScheme.surface;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: highlighted
          ? (hasIssues
                ? colorScheme.errorContainer.withValues(alpha: 0.2)
                : colorScheme.primaryContainer.withValues(alpha: 0.18))
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: frameColor,
          width: highlighted || hasIssues ? 1.4 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurveyResponseQuestionNumberBadge(
              number: questionNumber,
              color: statusColor,
              foregroundColor: statusForegroundColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SurveyResponseQuestionHeader(
                    title: title,
                    isRequired: isRequired,
                    enabled: enabled,
                    hasIssues: hasIssues,
                    highlighted: highlighted,
                  ),
                  if (helperText?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text(
                      helperText!.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (hasIssues) ...[
                    const SizedBox(height: 12),
                    SurveyResponseQuestionIssuePanel(messages: issueMessages),
                  ],
                  const SizedBox(height: 16),
                  AbsorbPointer(
                    absorbing: !enabled,
                    child: Opacity(opacity: enabled ? 1 : 0.62, child: child),
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
