import '../logic/survey_evidence_upload_state_bridge.dart';
import 'survey_response_provider.dart';

class SurveyResponseUploadStateSink implements SurveyEvidenceUploadStateSink {
  final SurveyResponseNotifier notifier;

  const SurveyResponseUploadStateSink(this.notifier);

  @override
  void queueEvidenceUpload({
    required String responseId,
    required String evidenceId,
    DateTime? queuedAt,
  }) {
    notifier.queueEvidenceUpload(
      responseId: responseId,
      evidenceId: evidenceId,
      queuedAt: queuedAt,
    );
  }

  @override
  void markEvidenceUploading({
    required String responseId,
    required String evidenceId,
    DateTime? uploadingAt,
  }) {
    notifier.markEvidenceUploading(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadingAt: uploadingAt,
    );
  }

  @override
  void markEvidenceUploaded({
    required String responseId,
    required String evidenceId,
    required String remoteUrl,
    DateTime? uploadedAt,
  }) {
    notifier.markEvidenceUploaded(
      responseId: responseId,
      evidenceId: evidenceId,
      remoteUrl: remoteUrl,
      uploadedAt: uploadedAt,
    );
  }

  @override
  void markEvidenceUploadFailed({
    required String responseId,
    required String evidenceId,
    required String uploadError,
    DateTime? failedAt,
  }) {
    notifier.markEvidenceUploadFailed(
      responseId: responseId,
      evidenceId: evidenceId,
      uploadError: uploadError,
      failedAt: failedAt,
    );
  }
}

SurveyEvidenceUploadStateObserver surveyResponseUploadStateObserver(
  SurveyResponseNotifier notifier,
) {
  return SurveyEvidenceUploadStateObserver(
    sink: SurveyResponseUploadStateSink(notifier),
  );
}
