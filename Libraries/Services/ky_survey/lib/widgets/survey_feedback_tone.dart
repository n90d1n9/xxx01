import 'package:flutter/material.dart';

enum SurveyFeedbackTone { success, info, warning, error }

/// Resolves shared icons and colors for survey feedback surfaces.
class SurveyFeedbackToneStyle {
  final IconData icon;
  final Color color;
  final Color onColor;

  const SurveyFeedbackToneStyle({
    required this.icon,
    required this.color,
    required this.onColor,
  });

  factory SurveyFeedbackToneStyle.resolve(
    ColorScheme colorScheme,
    SurveyFeedbackTone tone,
  ) {
    switch (tone) {
      case SurveyFeedbackTone.success:
        return SurveyFeedbackToneStyle(
          icon: Icons.check_circle_outline,
          color: colorScheme.primary,
          onColor: colorScheme.onPrimary,
        );
      case SurveyFeedbackTone.info:
        return SurveyFeedbackToneStyle(
          icon: Icons.info_outline,
          color: colorScheme.secondary,
          onColor: colorScheme.onSecondary,
        );
      case SurveyFeedbackTone.warning:
        return SurveyFeedbackToneStyle(
          icon: Icons.report_problem_outlined,
          color: colorScheme.tertiary,
          onColor: colorScheme.onTertiary,
        );
      case SurveyFeedbackTone.error:
        return SurveyFeedbackToneStyle(
          icon: Icons.error_outline,
          color: colorScheme.error,
          onColor: colorScheme.onError,
        );
    }
  }
}
