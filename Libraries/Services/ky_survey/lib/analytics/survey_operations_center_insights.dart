import 'survey_evidence_sync_insights.dart';
import 'survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_queue_insights.dart';
import 'survey_response_sync_readiness.dart';

enum SurveyOperationsCenterHealth { steady, monitoring, ready, attention }

enum SurveyOperationsCenterActionKind {
  openFieldworkQueue,
  runDueUploads,
  runUploadPlan,
  requeueFailedUploads,
  maintainUploadQueue,
  monitorUploadQueue,
  reviewReports,
}

/// Describes one prioritized operation the survey workspace can perform next.
class SurveyOperationsCenterAction {
  final SurveyOperationsCenterActionKind kind;
  final String title;
  final String detail;
  final int count;

  const SurveyOperationsCenterAction({
    required this.kind,
    required this.title,
    required this.detail,
    required this.count,
  });
}

/// Aggregates fieldwork, evidence, and upload-queue health for command views.
class SurveyOperationsCenterInsights {
  final SurveyResponseSyncReadinessInsights responseReadiness;
  final SurveyEvidenceSyncInsights evidenceSyncInsights;
  final SurveyEvidenceUploadPlan uploadPlan;
  final SurveyEvidenceUploadQueueInsights? uploadQueueInsights;

  const SurveyOperationsCenterInsights({
    required this.responseReadiness,
    required this.evidenceSyncInsights,
    required this.uploadPlan,
    this.uploadQueueInsights,
  });

  factory SurveyOperationsCenterInsights.evaluate({
    required SurveyResponseSyncReadinessInsights responseReadiness,
    required SurveyEvidenceSyncInsights evidenceSyncInsights,
    SurveyEvidenceUploadPlan? uploadPlan,
    SurveyEvidenceUploadQueueInsights? uploadQueueInsights,
  }) {
    return SurveyOperationsCenterInsights(
      responseReadiness: responseReadiness,
      evidenceSyncInsights: evidenceSyncInsights,
      uploadPlan:
          uploadPlan ??
          SurveyEvidenceUploadPlanner(
            insights: evidenceSyncInsights,
          ).createPlan(),
      uploadQueueInsights: uploadQueueInsights,
    );
  }

  int get answerIssueCount => responseReadiness.answerIssueCount;

  int get evidenceCaptureIssueCount => responseReadiness.evidenceIssueCount;

  int get responseUploadFailedCount => responseReadiness.uploadFailedCount;

  int get queueFailedCount => uploadQueueInsights?.failedCount ?? 0;

  int get staleUploadCount => uploadQueueInsights?.staleUploadingCount ?? 0;

  int get queueAttentionCount => queueFailedCount + staleUploadCount;

  int get attentionCount {
    return answerIssueCount +
        evidenceCaptureIssueCount +
        responseUploadFailedCount +
        queueAttentionCount;
  }

  int get readyResponseCount => responseReadiness.readyToSubmitCount;

  int get readyEvidenceUploadCount => uploadPlan.uploadableTasks.length;

  int get dueQueueUploadCount => uploadQueueInsights?.dueCount ?? 0;

  int get readyWorkCount {
    return readyResponseCount + readyEvidenceUploadCount + dueQueueUploadCount;
  }

  int get waitingResponseSyncCount => responseReadiness.uploadPendingCount;

  int get waitingQueueUploadCount => uploadQueueInsights?.waitingCount ?? 0;

  int get activeQueueUploadCount => uploadQueueInsights?.uploadingCount ?? 0;

  int get waitingSyncCount {
    return waitingResponseSyncCount +
        waitingQueueUploadCount +
        activeQueueUploadCount;
  }

  int get queueDepth => uploadQueueInsights?.totalCount ?? 0;

  bool get hasOperationsWork {
    return attentionCount > 0 || readyWorkCount > 0 || waitingSyncCount > 0;
  }

  SurveyOperationsCenterHealth get health {
    if (attentionCount > 0) {
      return SurveyOperationsCenterHealth.attention;
    }

    if (readyWorkCount > 0) {
      return SurveyOperationsCenterHealth.ready;
    }

    if (waitingSyncCount > 0) {
      return SurveyOperationsCenterHealth.monitoring;
    }

    return SurveyOperationsCenterHealth.steady;
  }

  String get statusLabel {
    switch (health) {
      case SurveyOperationsCenterHealth.attention:
        return 'Attention required';
      case SurveyOperationsCenterHealth.ready:
        return 'Ready to move';
      case SurveyOperationsCenterHealth.monitoring:
        return 'Sync in progress';
      case SurveyOperationsCenterHealth.steady:
        return 'Operations steady';
    }
  }

  String get detailLabel {
    switch (health) {
      case SurveyOperationsCenterHealth.attention:
        return _plural(
          attentionCount,
          'item needs follow-up',
          'items need follow-up',
        );
      case SurveyOperationsCenterHealth.ready:
        return _plural(
          readyWorkCount,
          'item is ready for action',
          'items are ready for action',
        );
      case SurveyOperationsCenterHealth.monitoring:
        return _plural(
          waitingSyncCount,
          'item is waiting on sync',
          'items are waiting on sync',
        );
      case SurveyOperationsCenterHealth.steady:
        return 'No fieldwork or upload blockers are active.';
    }
  }

  SurveyResponseSyncReadiness? get nextResponseAction {
    final queue = responseReadiness.actionQueue(limit: 1);
    return queue.isEmpty ? null : queue.first;
  }

  SurveyOperationsCenterAction get primaryAction => actions.first;

  List<SurveyOperationsCenterAction> get actions {
    final actions = <SurveyOperationsCenterAction>[];

    if (queueFailedCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.requeueFailedUploads,
          title: 'Requeue failed uploads',
          detail: _plural(
            queueFailedCount,
            'failed upload is in the queue',
            'failed uploads are in the queue',
          ),
          count: queueFailedCount,
        ),
      );
    }

    if (staleUploadCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.maintainUploadQueue,
          title: 'Maintain upload queue',
          detail: _plural(
            staleUploadCount,
            'upload appears stalled',
            'uploads appear stalled',
          ),
          count: staleUploadCount,
        ),
      );
    }

    final responseIssueCount =
        answerIssueCount +
        evidenceCaptureIssueCount +
        responseUploadFailedCount;
    if (responseIssueCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.openFieldworkQueue,
          title: 'Review fieldwork blockers',
          detail: _plural(
            responseIssueCount,
            'response needs review',
            'responses need review',
          ),
          count: responseIssueCount,
        ),
      );
    }

    if (dueQueueUploadCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.runDueUploads,
          title: 'Run due uploads',
          detail: _plural(
            dueQueueUploadCount,
            'queued upload is due',
            'queued uploads are due',
          ),
          count: dueQueueUploadCount,
        ),
      );
    }

    if (readyEvidenceUploadCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.runUploadPlan,
          title: 'Upload ready evidence',
          detail: _plural(
            readyEvidenceUploadCount,
            'attachment is ready',
            'attachments are ready',
          ),
          count: readyEvidenceUploadCount,
        ),
      );
    }

    if (readyResponseCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.openFieldworkQueue,
          title: 'Submit ready responses',
          detail: _plural(
            readyResponseCount,
            'response is ready to submit',
            'responses are ready to submit',
          ),
          count: readyResponseCount,
        ),
      );
    }

    if (waitingSyncCount > 0) {
      actions.add(
        SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.monitorUploadQueue,
          title: 'Monitor sync progress',
          detail: _plural(
            waitingSyncCount,
            'item is still syncing',
            'items are still syncing',
          ),
          count: waitingSyncCount,
        ),
      );
    }

    if (actions.isEmpty) {
      actions.add(
        const SurveyOperationsCenterAction(
          kind: SurveyOperationsCenterActionKind.reviewReports,
          title: 'Review reports',
          detail: 'Reports and evidence sync are up to date.',
          count: 0,
        ),
      );
    }

    return actions;
  }

  static String _plural(int count, String singular, [String? plural]) {
    if (count == 1) {
      return '1 $singular';
    }

    return '$count ${plural ?? '${singular}s'}';
  }
}
