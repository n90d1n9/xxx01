import 'survey_evidence_sync_insights.dart';

class SurveyEvidenceUploadPlanner {
  final SurveyEvidenceSyncInsights insights;

  const SurveyEvidenceUploadPlanner({required this.insights});

  SurveyEvidenceUploadPlan createPlan({int? limit}) {
    final tasks = insights.items
        .map(SurveyEvidenceUploadTask.fromSyncItem)
        .where((task) => task.action != SurveyEvidenceUploadAction.none)
        .toList();

    tasks.sort((left, right) {
      final priority = left.priority.compareTo(right.priority);
      if (priority != 0) {
        return priority;
      }

      return right.item.evidence.capturedAt.compareTo(
        left.item.evidence.capturedAt,
      );
    });

    return SurveyEvidenceUploadPlan(
      tasks: limit == null ? tasks : tasks.take(limit).toList(),
    );
  }
}

class SurveyEvidenceUploadPlan {
  final List<SurveyEvidenceUploadTask> tasks;

  const SurveyEvidenceUploadPlan({required this.tasks});

  bool get hasWork => tasks.isNotEmpty;

  List<SurveyEvidenceUploadTask> get uploadableTasks {
    return tasks.where((task) => task.canStartUpload).toList();
  }

  List<SurveyEvidenceUploadTask> get blockedTasks {
    return tasks
        .where((task) => task.action == SurveyEvidenceUploadAction.fixEvidence)
        .toList();
  }

  List<SurveyEvidenceUploadTask> get retryableTasks {
    return tasks
        .where((task) => task.action == SurveyEvidenceUploadAction.retryUpload)
        .toList();
  }

  List<SurveyEvidenceUploadTask> get monitoringTasks {
    return tasks
        .where(
          (task) => task.action == SurveyEvidenceUploadAction.monitorUpload,
        )
        .toList();
  }

  SurveyEvidenceUploadTask? get nextUploadTask {
    for (final task in tasks) {
      if (task.canStartUpload) {
        return task;
      }
    }

    return null;
  }
}

class SurveyEvidenceUploadTask {
  final SurveyEvidenceSyncItem item;
  final SurveyEvidenceUploadAction action;

  const SurveyEvidenceUploadTask({required this.item, required this.action});

  factory SurveyEvidenceUploadTask.fromSyncItem(SurveyEvidenceSyncItem item) {
    return SurveyEvidenceUploadTask(item: item, action: _actionFor(item.state));
  }

  String get responseId => item.response.id;

  String get evidenceId => item.evidence.id;

  bool get canStartUpload =>
      action == SurveyEvidenceUploadAction.queueUpload ||
      action == SurveyEvidenceUploadAction.retryUpload;

  int get priority {
    switch (action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return 0;
      case SurveyEvidenceUploadAction.retryUpload:
        return 1;
      case SurveyEvidenceUploadAction.queueUpload:
        return 2;
      case SurveyEvidenceUploadAction.monitorUpload:
        return 3;
      case SurveyEvidenceUploadAction.none:
        return 4;
    }
  }

  String get actionLabel {
    switch (action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return 'Fix evidence';
      case SurveyEvidenceUploadAction.retryUpload:
        return 'Retry upload';
      case SurveyEvidenceUploadAction.queueUpload:
        return 'Queue upload';
      case SurveyEvidenceUploadAction.monitorUpload:
        return 'Monitor upload';
      case SurveyEvidenceUploadAction.none:
        return 'No action';
    }
  }

  String get detail {
    switch (action) {
      case SurveyEvidenceUploadAction.fixEvidence:
        return item.detail;
      case SurveyEvidenceUploadAction.retryUpload:
        return item.attachment.uploadError ?? 'Upload failed';
      case SurveyEvidenceUploadAction.queueUpload:
        return '${item.survey.title} • ${item.response.respondentName}';
      case SurveyEvidenceUploadAction.monitorUpload:
        return item.stateLabel;
      case SurveyEvidenceUploadAction.none:
        return 'No upload action required';
    }
  }

  static SurveyEvidenceUploadAction _actionFor(SurveyEvidenceSyncState state) {
    switch (state) {
      case SurveyEvidenceSyncState.blocked:
        return SurveyEvidenceUploadAction.fixEvidence;
      case SurveyEvidenceSyncState.failed:
        return SurveyEvidenceUploadAction.retryUpload;
      case SurveyEvidenceSyncState.readyToUpload:
        return SurveyEvidenceUploadAction.queueUpload;
      case SurveyEvidenceSyncState.queued:
      case SurveyEvidenceSyncState.uploading:
        return SurveyEvidenceUploadAction.monitorUpload;
      case SurveyEvidenceSyncState.uploaded:
      case SurveyEvidenceSyncState.localOnly:
        return SurveyEvidenceUploadAction.none;
    }
  }
}

enum SurveyEvidenceUploadAction {
  fixEvidence,
  retryUpload,
  queueUpload,
  monitorUpload,
  none,
}
