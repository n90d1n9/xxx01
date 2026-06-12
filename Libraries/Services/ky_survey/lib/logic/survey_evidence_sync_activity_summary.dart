import '../analytics/survey_evidence_sync_insights.dart';
import '../analytics/survey_evidence_upload_planner.dart';
import '../analytics/survey_evidence_upload_queue_insights.dart';
import 'survey_evidence_upload_queue.dart';
import 'survey_evidence_upload_plan_activity.dart';

enum SurveyEvidenceSyncActivityState {
  clear,
  attention,
  active,
  ready,
  waiting,
}

/// Describes one compact evidence sync activity metric for dashboard surfaces.
class SurveyEvidenceSyncActivityMetric {
  final String label;
  final int count;

  const SurveyEvidenceSyncActivityMetric({
    required this.label,
    required this.count,
  });
}

/// Summarizes evidence upload activity across response state and upload queues.
class SurveyEvidenceSyncActivitySummary {
  final int attentionCount;
  final int activeUploadCount;
  final int readyUploadCount;
  final int waitingUploadCount;

  const SurveyEvidenceSyncActivitySummary({
    this.attentionCount = 0,
    this.activeUploadCount = 0,
    this.readyUploadCount = 0,
    this.waitingUploadCount = 0,
  });

  factory SurveyEvidenceSyncActivitySummary.evaluate({
    required SurveyEvidenceSyncInsights evidenceSyncInsights,
    SurveyEvidenceUploadQueueInsights? evidenceUploadQueueInsights,
    Set<String> activeEvidenceUploadKeys = const {},
  }) {
    final plan = SurveyEvidenceUploadPlanner(
      insights: evidenceSyncInsights,
    ).createPlan();
    final uploadActivity = SurveyEvidenceUploadPlanActivity(
      plan: plan,
      activeUploadKeys: activeEvidenceUploadKeys,
    );
    final activeKeys = <String>{
      ...uploadActivity.activeUploadableTasks.map(
        (task) =>
            _taskKey(responseId: task.responseId, evidenceId: task.evidenceId),
      ),
      ..._syncItemKeys(evidenceSyncInsights, SurveyEvidenceSyncState.uploading),
      ...?evidenceUploadQueueInsights?.uploadingEntries.map(_queueEntryKey),
    };
    final attentionKeys = <String>{
      ..._syncItemKeys(evidenceSyncInsights, SurveyEvidenceSyncState.blocked),
      ..._syncItemKeys(evidenceSyncInsights, SurveyEvidenceSyncState.failed),
      ...?evidenceUploadQueueInsights?.failedEntries.map(_queueEntryKey),
      ...?evidenceUploadQueueInsights?.staleUploadingEntries.map(
        _queueEntryKey,
      ),
    };
    final readyKeys = <String>{
      ...uploadActivity.readyUploadableTasks.map(
        (task) =>
            _taskKey(responseId: task.responseId, evidenceId: task.evidenceId),
      ),
      ...?evidenceUploadQueueInsights?.dueEntries.map(_queueEntryKey),
    }..removeAll(activeKeys);
    final waitingKeys = <String>{
      ..._syncItemKeys(evidenceSyncInsights, SurveyEvidenceSyncState.queued),
      ...?evidenceUploadQueueInsights?.waitingEntries.map(_queueEntryKey),
    }..removeAll(activeKeys);

    return SurveyEvidenceSyncActivitySummary(
      attentionCount: attentionKeys.length,
      activeUploadCount: activeKeys.length,
      readyUploadCount: readyKeys.length,
      waitingUploadCount: waitingKeys.length,
    );
  }

  bool get hasActivity {
    return attentionCount > 0 ||
        activeUploadCount > 0 ||
        readyUploadCount > 0 ||
        waitingUploadCount > 0;
  }

  SurveyEvidenceSyncActivityState get state {
    if (attentionCount > 0) {
      return SurveyEvidenceSyncActivityState.attention;
    }
    if (activeUploadCount > 0) {
      return SurveyEvidenceSyncActivityState.active;
    }
    if (readyUploadCount > 0) {
      return SurveyEvidenceSyncActivityState.ready;
    }
    if (waitingUploadCount > 0) {
      return SurveyEvidenceSyncActivityState.waiting;
    }

    return SurveyEvidenceSyncActivityState.clear;
  }

  String get title {
    switch (state) {
      case SurveyEvidenceSyncActivityState.attention:
        return 'Evidence needs attention';
      case SurveyEvidenceSyncActivityState.active:
        return activeUploadCount == 1
            ? 'Evidence upload running'
            : 'Evidence uploads running';
      case SurveyEvidenceSyncActivityState.ready:
        return 'Evidence upload ready';
      case SurveyEvidenceSyncActivityState.waiting:
        return 'Evidence sync waiting';
      case SurveyEvidenceSyncActivityState.clear:
        return 'Evidence sync clear';
    }
  }

  String get detailLabel {
    if (!hasActivity) {
      return 'No evidence upload work is active.';
    }

    final parts = <String>[
      if (activeUploadCount > 0)
        _plural(activeUploadCount, 'upload running', 'uploads running'),
      if (attentionCount > 0)
        _plural(attentionCount, 'item needs attention', 'items need attention'),
      if (readyUploadCount > 0)
        _plural(readyUploadCount, 'upload ready', 'uploads ready'),
      if (waitingUploadCount > 0)
        _plural(waitingUploadCount, 'upload waiting', 'uploads waiting'),
    ];

    return parts.join(' | ');
  }

  List<SurveyEvidenceSyncActivityMetric> get metrics {
    return [
      if (activeUploadCount > 0)
        SurveyEvidenceSyncActivityMetric(
          label: 'Uploading',
          count: activeUploadCount,
        ),
      if (attentionCount > 0)
        SurveyEvidenceSyncActivityMetric(
          label: 'Attention',
          count: attentionCount,
        ),
      if (readyUploadCount > 0)
        SurveyEvidenceSyncActivityMetric(
          label: 'Ready',
          count: readyUploadCount,
        ),
      if (waitingUploadCount > 0)
        SurveyEvidenceSyncActivityMetric(
          label: 'Waiting',
          count: waitingUploadCount,
        ),
    ];
  }

  static Iterable<String> _syncItemKeys(
    SurveyEvidenceSyncInsights insights,
    SurveyEvidenceSyncState state,
  ) {
    return insights.items.where((item) => item.state == state).map((item) {
      return _taskKey(
        responseId: item.response.id,
        evidenceId: item.evidence.id,
      );
    });
  }

  static String _queueEntryKey(SurveyEvidenceUploadQueueEntry entry) {
    return _taskKey(responseId: entry.responseId, evidenceId: entry.evidenceId);
  }

  static String _taskKey({
    required String responseId,
    required String evidenceId,
  }) {
    return '$responseId:$evidenceId';
  }

  static String _plural(int count, String singular, String plural) {
    return count == 1 ? '1 $singular' : '$count $plural';
  }
}
