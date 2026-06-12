import 'package:flutter/material.dart';

import '../../logic/survey_evidence_upload_execution_feedback.dart';
import '../survey_feedback_tone.dart';

/// Builds tone-aware snackbars for single evidence upload results.
class SurveyEvidenceUploadExecutionSnackBar {
  const SurveyEvidenceUploadExecutionSnackBar._();

  static SnackBar build(
    BuildContext context,
    SurveyEvidenceUploadExecutionFeedback feedback,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final toneStyle = SurveyFeedbackToneStyle.resolve(
      colorScheme,
      _feedbackTone(feedback.tone),
    );

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: toneStyle.color,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(toneStyle.icon, color: toneStyle.onColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: toneStyle.onColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  feedback.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: toneStyle.onColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static SurveyFeedbackTone _feedbackTone(
    SurveyEvidenceUploadExecutionFeedbackTone tone,
  ) {
    switch (tone) {
      case SurveyEvidenceUploadExecutionFeedbackTone.success:
        return SurveyFeedbackTone.success;
      case SurveyEvidenceUploadExecutionFeedbackTone.info:
        return SurveyFeedbackTone.info;
      case SurveyEvidenceUploadExecutionFeedbackTone.warning:
        return SurveyFeedbackTone.warning;
      case SurveyEvidenceUploadExecutionFeedbackTone.error:
        return SurveyFeedbackTone.error;
    }
  }
}
