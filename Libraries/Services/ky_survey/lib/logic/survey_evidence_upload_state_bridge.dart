import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_service.dart';

abstract interface class SurveyEvidenceUploadStateSink {
  void queueEvidenceUpload({
    required String responseId,
    required String evidenceId,
    DateTime? queuedAt,
  });

  void markEvidenceUploading({
    required String responseId,
    required String evidenceId,
    DateTime? uploadingAt,
  });

  void markEvidenceUploaded({
    required String responseId,
    required String evidenceId,
    required String remoteUrl,
    DateTime? uploadedAt,
  });

  void markEvidenceUploadFailed({
    required String responseId,
    required String evidenceId,
    required String uploadError,
    DateTime? failedAt,
  });
}

class SurveyEvidenceUploadStateObserver extends SurveyEvidenceUploadObserver {
  final SurveyEvidenceUploadStateSink sink;

  const SurveyEvidenceUploadStateObserver({required this.sink});

  @override
  void onQueued(SurveyEvidenceUploadTask task, DateTime queuedAt) {
    sink.queueEvidenceUpload(
      responseId: task.responseId,
      evidenceId: task.evidenceId,
      queuedAt: queuedAt,
    );
  }

  @override
  void onUploading(SurveyEvidenceUploadTask task, DateTime uploadingAt) {
    sink.markEvidenceUploading(
      responseId: task.responseId,
      evidenceId: task.evidenceId,
      uploadingAt: uploadingAt,
    );
  }

  @override
  void onUploaded(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime uploadedAt,
  ) {
    final remoteUrl = result.remoteUrl;
    if (remoteUrl == null || remoteUrl.trim().isEmpty) {
      sink.markEvidenceUploadFailed(
        responseId: task.responseId,
        evidenceId: task.evidenceId,
        uploadError: 'Upload completed without a remote URL.',
        failedAt: uploadedAt,
      );
      return;
    }

    sink.markEvidenceUploaded(
      responseId: task.responseId,
      evidenceId: task.evidenceId,
      remoteUrl: remoteUrl,
      uploadedAt: uploadedAt,
    );
  }

  @override
  void onFailed(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime failedAt,
  ) {
    sink.markEvidenceUploadFailed(
      responseId: task.responseId,
      evidenceId: task.evidenceId,
      uploadError: result.message ?? 'Upload failed',
      failedAt: failedAt,
    );
  }
}
