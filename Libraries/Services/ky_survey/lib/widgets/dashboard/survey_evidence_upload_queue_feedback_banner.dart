import 'package:flutter/material.dart';

import '../../logic/survey_evidence_upload_queue_action_feedback.dart';
import '../survey_feedback_tone.dart';

class SurveyEvidenceUploadQueueFeedbackBanner extends StatelessWidget {
  final SurveyEvidenceUploadQueueActionFeedback feedback;
  final VoidCallback? onDismiss;

  const SurveyEvidenceUploadQueueFeedbackBanner({
    super.key,
    required this.feedback,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final toneStyle = SurveyFeedbackToneStyle.resolve(
      colorScheme,
      _feedbackTone,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: toneStyle.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: toneStyle.color.withValues(alpha: 0.34)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(toneStyle.icon, color: toneStyle.color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    feedback.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Dismiss',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }

  SurveyFeedbackTone get _feedbackTone {
    switch (feedback.tone) {
      case SurveyEvidenceUploadQueueActionFeedbackTone.success:
        return SurveyFeedbackTone.success;
      case SurveyEvidenceUploadQueueActionFeedbackTone.info:
        return SurveyFeedbackTone.info;
      case SurveyEvidenceUploadQueueActionFeedbackTone.warning:
        return SurveyFeedbackTone.warning;
      case SurveyEvidenceUploadQueueActionFeedbackTone.error:
        return SurveyFeedbackTone.error;
    }
  }
}
