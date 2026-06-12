import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_service.dart';

enum SurveyEvidenceUploadExecutionFeedbackTone { success, info, warning, error }

/// Builds concise operator feedback for one evidence upload execution.
class SurveyEvidenceUploadExecutionFeedback {
  final SurveyEvidenceUploadExecutionFeedbackTone tone;
  final String title;
  final String message;

  const SurveyEvidenceUploadExecutionFeedback({
    required this.tone,
    required this.title,
    required this.message,
  });

  factory SurveyEvidenceUploadExecutionFeedback.fromExecution(
    SurveyEvidenceUploadExecution execution, {
    SurveyEvidenceUploadTask? fallbackTask,
  }) {
    final task = execution.task ?? fallbackTask;
    final evidenceTitle = task?.item.title ?? 'Evidence upload';

    switch (execution.status) {
      case SurveyEvidenceUploadExecutionStatus.uploaded:
        return SurveyEvidenceUploadExecutionFeedback(
          tone: SurveyEvidenceUploadExecutionFeedbackTone.success,
          title: 'Upload completed',
          message: '$evidenceTitle uploaded',
        );
      case SurveyEvidenceUploadExecutionStatus.failed:
        return SurveyEvidenceUploadExecutionFeedback(
          tone: SurveyEvidenceUploadExecutionFeedbackTone.error,
          title: 'Upload failed',
          message: '$evidenceTitle: ${execution.message ?? 'Upload failed'}',
        );
      case SurveyEvidenceUploadExecutionStatus.skipped:
        return SurveyEvidenceUploadExecutionFeedback(
          tone: SurveyEvidenceUploadExecutionFeedbackTone.warning,
          title: 'Upload skipped',
          message: '$evidenceTitle: ${execution.message ?? 'Upload skipped'}',
        );
      case SurveyEvidenceUploadExecutionStatus.noTask:
        return SurveyEvidenceUploadExecutionFeedback(
          tone: SurveyEvidenceUploadExecutionFeedbackTone.info,
          title: 'No upload task',
          message: execution.message ?? 'No upload task available',
        );
    }
  }
}
