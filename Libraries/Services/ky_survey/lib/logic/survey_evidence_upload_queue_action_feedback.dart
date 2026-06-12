import 'survey_evidence_upload_queue_actions.dart';

enum SurveyEvidenceUploadQueueActionFeedbackTone {
  success,
  info,
  warning,
  error,
}

class SurveyEvidenceUploadQueueActionFeedback {
  final SurveyEvidenceUploadQueueAction action;
  final SurveyEvidenceUploadQueueActionFeedbackTone tone;
  final String title;
  final String message;

  const SurveyEvidenceUploadQueueActionFeedback({
    required this.action,
    required this.tone,
    required this.title,
    required this.message,
  });

  factory SurveyEvidenceUploadQueueActionFeedback.fromResult(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    switch (result.action) {
      case SurveyEvidenceUploadQueueAction.loadState:
        return SurveyEvidenceUploadQueueActionFeedback(
          action: result.action,
          tone: SurveyEvidenceUploadQueueActionFeedbackTone.info,
          title: 'Queue loaded',
          message: result.insights.summaryLabel,
        );
      case SurveyEvidenceUploadQueueAction.enqueuePlan:
        final count = result.enqueueResult?.enqueuedCount ?? 0;
        return SurveyEvidenceUploadQueueActionFeedback(
          action: result.action,
          tone: count > 0
              ? SurveyEvidenceUploadQueueActionFeedbackTone.success
              : SurveyEvidenceUploadQueueActionFeedbackTone.info,
          title: count > 0 ? 'Evidence queued' : 'Nothing queued',
          message: result.message,
        );
      case SurveyEvidenceUploadQueueAction.runDueUploads:
        return _fromUploadProcessingResult(result);
      case SurveyEvidenceUploadQueueAction.maintainQueue:
        return _fromMaintenanceResult(result);
      case SurveyEvidenceUploadQueueAction.requeueFailedUploads:
        return _fromRequeueResult(result);
      case SurveyEvidenceUploadQueueAction.syncPlan:
        return _fromSyncResult(result);
    }
  }

  factory SurveyEvidenceUploadQueueActionFeedback.fromError({
    required SurveyEvidenceUploadQueueAction action,
    required Object error,
  }) {
    return SurveyEvidenceUploadQueueActionFeedback(
      action: action,
      tone: SurveyEvidenceUploadQueueActionFeedbackTone.error,
      title: '${_actionTitle(action)} failed',
      message: _errorMessage(error),
    );
  }

  static SurveyEvidenceUploadQueueActionFeedback _fromUploadProcessingResult(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    final process = result.processResult;
    if (process == null) {
      return _generic(result);
    }
    if (!process.hasWork) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.info,
        title: 'No due uploads',
        message: result.message,
      );
    }
    if (process.failedCount > 0) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.error,
        title: 'Uploads failed',
        message: result.message,
      );
    }
    if (process.retryScheduledCount > 0 || process.skippedCount > 0) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.warning,
        title: 'Uploads need follow-up',
        message: result.message,
      );
    }

    return SurveyEvidenceUploadQueueActionFeedback(
      action: result.action,
      tone: SurveyEvidenceUploadQueueActionFeedbackTone.success,
      title: 'Uploads completed',
      message: result.message,
    );
  }

  static SurveyEvidenceUploadQueueActionFeedback _fromMaintenanceResult(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    final maintenance = result.maintenanceResult;
    if (maintenance == null) {
      return _generic(result);
    }
    if (!maintenance.changed) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.info,
        title: 'Queue already clean',
        message: result.message,
      );
    }
    if (maintenance.recoveredCount > 0 || maintenance.requeuedCount > 0) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.warning,
        title: 'Queue has recovered work',
        message: result.message,
      );
    }

    return SurveyEvidenceUploadQueueActionFeedback(
      action: result.action,
      tone: SurveyEvidenceUploadQueueActionFeedbackTone.success,
      title: 'Queue maintained',
      message: result.message,
    );
  }

  static SurveyEvidenceUploadQueueActionFeedback _fromRequeueResult(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    final maintenance = result.maintenanceResult;
    final count = maintenance?.requeuedCount ?? 0;
    return SurveyEvidenceUploadQueueActionFeedback(
      action: result.action,
      tone: count > 0
          ? SurveyEvidenceUploadQueueActionFeedbackTone.success
          : SurveyEvidenceUploadQueueActionFeedbackTone.info,
      title: count > 0 ? 'Failed uploads requeued' : 'Nothing requeued',
      message: result.message,
    );
  }

  static SurveyEvidenceUploadQueueActionFeedback _fromSyncResult(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    final sync = result.syncResult;
    if (sync == null) {
      return _generic(result);
    }
    if (!sync.hasWork) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.info,
        title: 'No uploads ready',
        message: result.message,
      );
    }
    if (sync.failedCount > 0) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.error,
        title: 'Sync found upload failures',
        message: result.message,
      );
    }
    if (sync.retryScheduledCount > 0 || sync.skippedCount > 0) {
      return SurveyEvidenceUploadQueueActionFeedback(
        action: result.action,
        tone: SurveyEvidenceUploadQueueActionFeedbackTone.warning,
        title: 'Sync needs follow-up',
        message: result.message,
      );
    }

    return SurveyEvidenceUploadQueueActionFeedback(
      action: result.action,
      tone: SurveyEvidenceUploadQueueActionFeedbackTone.success,
      title: sync.uploadedCount > 0 ? 'Uploads synced' : 'Evidence queued',
      message: result.message,
    );
  }

  static SurveyEvidenceUploadQueueActionFeedback _generic(
    SurveyEvidenceUploadQueueActionResult result,
  ) {
    return SurveyEvidenceUploadQueueActionFeedback(
      action: result.action,
      tone: result.changed
          ? SurveyEvidenceUploadQueueActionFeedbackTone.success
          : SurveyEvidenceUploadQueueActionFeedbackTone.info,
      title: result.changed ? 'Queue updated' : 'No queue changes',
      message: result.message,
    );
  }

  static String _actionTitle(SurveyEvidenceUploadQueueAction action) {
    switch (action) {
      case SurveyEvidenceUploadQueueAction.loadState:
        return 'Load queue';
      case SurveyEvidenceUploadQueueAction.enqueuePlan:
        return 'Queue evidence';
      case SurveyEvidenceUploadQueueAction.runDueUploads:
        return 'Run uploads';
      case SurveyEvidenceUploadQueueAction.maintainQueue:
        return 'Maintain queue';
      case SurveyEvidenceUploadQueueAction.requeueFailedUploads:
        return 'Requeue failed uploads';
      case SurveyEvidenceUploadQueueAction.syncPlan:
        return 'Sync queue';
    }
  }

  static String _errorMessage(Object error) {
    final message = error.toString().trim();
    return message.isEmpty ? 'Unexpected queue action error.' : message;
  }
}
