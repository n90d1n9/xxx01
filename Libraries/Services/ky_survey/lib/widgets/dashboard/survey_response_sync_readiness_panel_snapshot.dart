part of 'survey_response_sync_readiness_panel.dart';

class _ReadinessPanelSnapshot {
  final String summaryLabel;
  final List<SurveyResponseSyncReadiness> items;
  final List<SurveyResponseSyncReadiness> queue;
  final int readyToSubmitCount;
  final int answerIssueCount;
  final int evidenceIssueCount;
  final int uploadPendingCount;
  final int uploadFailedCount;
  final int actionRequiredCount;
  final int hiddenQueueCount;

  const _ReadinessPanelSnapshot({
    required this.summaryLabel,
    required this.items,
    required this.queue,
    required this.readyToSubmitCount,
    required this.answerIssueCount,
    required this.evidenceIssueCount,
    required this.uploadPendingCount,
    required this.uploadFailedCount,
    required this.actionRequiredCount,
    required this.hiddenQueueCount,
  });

  factory _ReadinessPanelSnapshot.fromInsights(
    SurveyResponseSyncReadinessInsights insights, {
    required int visibleItemLimit,
  }) {
    final items = insights.items;
    final queue =
        items
            .where((item) => item.requiresAction || item.isWaitingForSync)
            .toList()
          ..sort((left, right) {
            final priority = left.priority.compareTo(right.priority);
            if (priority != 0) {
              return priority;
            }

            return right.lastActivityAt.compareTo(left.lastActivityAt);
          });
    final queueLimit = visibleItemLimit < 0 ? 0 : visibleItemLimit;
    final visibleQueue = queue.take(queueLimit).toList();

    return _ReadinessPanelSnapshot(
      summaryLabel: insights.summaryLabel,
      items: items,
      queue: visibleQueue,
      readyToSubmitCount: items.where((item) => item.canSubmit).length,
      answerIssueCount: items
          .where(
            (item) =>
                item.status == SurveyResponseSyncReadinessStatus.needsAnswers,
          )
          .length,
      evidenceIssueCount: items
          .where(
            (item) =>
                item.status == SurveyResponseSyncReadinessStatus.needsEvidence,
          )
          .length,
      uploadPendingCount: items
          .where(
            (item) =>
                item.status == SurveyResponseSyncReadinessStatus.uploadPending,
          )
          .length,
      uploadFailedCount: items
          .where(
            (item) =>
                item.status == SurveyResponseSyncReadinessStatus.uploadFailed,
          )
          .length,
      actionRequiredCount: items.where((item) => item.requiresAction).length,
      hiddenQueueCount: queue.length - visibleQueue.length,
    );
  }
}
