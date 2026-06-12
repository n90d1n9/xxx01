import 'package:flutter/material.dart';

import '../analytics/survey_evidence_upload_planner.dart';

enum SurveyEvidenceUploadTaskActionButtonStyle { filledTonal, outlined }

/// Renders a consistent evidence upload task action button across survey UIs.
class SurveyEvidenceUploadTaskActionButton extends StatelessWidget {
  final SurveyEvidenceUploadTask task;
  final bool active;
  final VoidCallback? onPressed;
  final SurveyEvidenceUploadTaskActionButtonStyle style;
  final String activeLabel;

  const SurveyEvidenceUploadTaskActionButton({
    super.key,
    required this.task,
    required this.onPressed,
    this.active = false,
    this.style = SurveyEvidenceUploadTaskActionButtonStyle.filledTonal,
    this.activeLabel = 'Uploading...',
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(_icon, size: 18);
    final label = Text(active ? activeLabel : task.actionLabel);
    final callback = active ? null : onPressed;

    switch (style) {
      case SurveyEvidenceUploadTaskActionButtonStyle.filledTonal:
        return FilledButton.tonalIcon(
          icon: icon,
          label: label,
          onPressed: callback,
        );
      case SurveyEvidenceUploadTaskActionButtonStyle.outlined:
        return OutlinedButton.icon(
          icon: icon,
          label: label,
          onPressed: callback,
        );
    }
  }

  IconData get _icon {
    if (active) {
      return Icons.sync_outlined;
    }

    switch (task.action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return Icons.edit_outlined;
      case SurveyEvidenceUploadAction.retryUpload:
        return Icons.refresh_outlined;
      case SurveyEvidenceUploadAction.queueUpload:
        return Icons.cloud_upload_outlined;
      case SurveyEvidenceUploadAction.monitorUpload:
        return Icons.sync_outlined;
      case SurveyEvidenceUploadAction.none:
        return Icons.check_circle_outline;
    }
  }
}
