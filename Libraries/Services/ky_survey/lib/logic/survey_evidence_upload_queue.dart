import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_retry_policy.dart';

enum SurveyEvidenceUploadQueueStatus {
  pending,
  uploading,
  uploaded,
  failed,
  skipped,
}

SurveyEvidenceUploadQueueStatus surveyEvidenceUploadQueueStatusFromJson(
  Object? value,
) {
  if (value is SurveyEvidenceUploadQueueStatus) {
    return value;
  }

  if (value is String) {
    for (final status in SurveyEvidenceUploadQueueStatus.values) {
      if (status.name == value) {
        return status;
      }
    }
  }

  return SurveyEvidenceUploadQueueStatus.pending;
}

SurveyEvidenceUploadAction surveyEvidenceUploadActionFromJson(Object? value) {
  if (value is SurveyEvidenceUploadAction) {
    return value;
  }

  if (value is String) {
    for (final action in SurveyEvidenceUploadAction.values) {
      if (action.name == value) {
        return action;
      }
    }
  }

  return SurveyEvidenceUploadAction.queueUpload;
}

class SurveyEvidenceUploadQueueEntry {
  final String id;
  final String surveyId;
  final String responseId;
  final String evidenceId;
  final String? requirementId;
  final SurveyEvidenceUploadAction action;
  final int priority;
  final SurveyEvidenceUploadQueueStatus status;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextAttemptAt;
  final String? remoteUrl;
  final String? lastError;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceUploadQueueEntry({
    required this.id,
    required this.surveyId,
    required this.responseId,
    required this.evidenceId,
    required this.action,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.requirementId,
    this.status = SurveyEvidenceUploadQueueStatus.pending,
    this.attemptCount = 0,
    this.nextAttemptAt,
    this.remoteUrl,
    this.lastError,
    this.metadata = const {},
  });

  factory SurveyEvidenceUploadQueueEntry.fromTask(
    SurveyEvidenceUploadTask task, {
    required DateTime queuedAt,
    DateTime? nextAttemptAt,
    Map<String, dynamic> metadata = const {},
  }) {
    return SurveyEvidenceUploadQueueEntry(
      id: queueIdForTask(task),
      surveyId: task.item.survey.id,
      responseId: task.responseId,
      evidenceId: task.evidenceId,
      requirementId: task.item.requirement?.id,
      action: task.action,
      priority: task.priority,
      createdAt: queuedAt,
      updatedAt: queuedAt,
      nextAttemptAt: nextAttemptAt ?? queuedAt,
      metadata: {
        'surveyTitle': task.item.survey.title,
        'evidenceTitle': task.item.title,
        ...metadata,
      },
    );
  }

  factory SurveyEvidenceUploadQueueEntry.fromJson(Map<String, dynamic> json) {
    return SurveyEvidenceUploadQueueEntry(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      responseId: json['responseId'] as String,
      evidenceId: json['evidenceId'] as String,
      requirementId: json['requirementId'] as String?,
      action: surveyEvidenceUploadActionFromJson(json['action']),
      priority: json['priority'] as int? ?? 0,
      status: surveyEvidenceUploadQueueStatusFromJson(json['status']),
      attemptCount: json['attemptCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      nextAttemptAt: json['nextAttemptAt'] == null
          ? null
          : DateTime.parse(json['nextAttemptAt'] as String),
      remoteUrl: json['remoteUrl'] as String?,
      lastError: json['lastError'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  bool get isTerminal {
    return status == SurveyEvidenceUploadQueueStatus.uploaded ||
        status == SurveyEvidenceUploadQueueStatus.skipped;
  }

  bool get canAttempt => status == SurveyEvidenceUploadQueueStatus.pending;

  bool isDue(DateTime now) {
    if (!canAttempt) {
      return false;
    }

    final nextAttempt = nextAttemptAt;
    return nextAttempt == null || !nextAttempt.isAfter(now);
  }

  SurveyEvidenceUploadQueueEntry copyWith({
    String? id,
    String? surveyId,
    String? responseId,
    String? evidenceId,
    String? requirementId,
    SurveyEvidenceUploadAction? action,
    int? priority,
    SurveyEvidenceUploadQueueStatus? status,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextAttemptAt,
    String? remoteUrl,
    String? lastError,
    Map<String, dynamic>? metadata,
    bool clearNextAttemptAt = false,
    bool clearRemoteUrl = false,
    bool clearLastError = false,
  }) {
    return SurveyEvidenceUploadQueueEntry(
      id: id ?? this.id,
      surveyId: surveyId ?? this.surveyId,
      responseId: responseId ?? this.responseId,
      evidenceId: evidenceId ?? this.evidenceId,
      requirementId: requirementId ?? this.requirementId,
      action: action ?? this.action,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextAttemptAt: clearNextAttemptAt
          ? null
          : nextAttemptAt ?? this.nextAttemptAt,
      remoteUrl: clearRemoteUrl ? null : remoteUrl ?? this.remoteUrl,
      lastError: clearLastError ? null : lastError ?? this.lastError,
      metadata: metadata ?? this.metadata,
    );
  }

  SurveyEvidenceUploadQueueEntry markUploading(DateTime uploadingAt) {
    return copyWith(
      status: SurveyEvidenceUploadQueueStatus.uploading,
      updatedAt: uploadingAt,
      clearLastError: true,
    );
  }

  SurveyEvidenceUploadQueueEntry markUploaded({
    required String remoteUrl,
    required DateTime uploadedAt,
  }) {
    return copyWith(
      status: SurveyEvidenceUploadQueueStatus.uploaded,
      remoteUrl: remoteUrl,
      updatedAt: uploadedAt,
      clearNextAttemptAt: true,
      clearLastError: true,
    );
  }

  SurveyEvidenceUploadQueueEntry markSkipped({
    required String reason,
    required DateTime skippedAt,
  }) {
    return copyWith(
      status: SurveyEvidenceUploadQueueStatus.skipped,
      lastError: reason,
      updatedAt: skippedAt,
      clearNextAttemptAt: true,
    );
  }

  SurveyEvidenceUploadQueueEntry markFailed({
    required String error,
    required DateTime failedAt,
    SurveyEvidenceUploadRetryPolicy retryPolicy =
        const SurveyEvidenceUploadRetryPolicy.none(),
  }) {
    final nextAttemptCount = attemptCount + 1;
    final shouldRetry = retryPolicy.shouldRetry(
      completedAttempts: nextAttemptCount,
      failed: true,
    );
    final retryDelay = retryPolicy.delayAfterAttempt(nextAttemptCount);

    return copyWith(
      status: shouldRetry
          ? SurveyEvidenceUploadQueueStatus.pending
          : SurveyEvidenceUploadQueueStatus.failed,
      attemptCount: nextAttemptCount,
      updatedAt: failedAt,
      nextAttemptAt: shouldRetry ? failedAt.add(retryDelay) : null,
      clearNextAttemptAt: !shouldRetry,
      lastError: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'responseId': responseId,
      'evidenceId': evidenceId,
      'requirementId': requirementId,
      'action': action.name,
      'priority': priority,
      'status': status.name,
      'attemptCount': attemptCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'nextAttemptAt': nextAttemptAt?.toIso8601String(),
      'remoteUrl': remoteUrl,
      'lastError': lastError,
      'metadata': metadata,
    };
  }

  static String queueId({
    required String responseId,
    required String evidenceId,
  }) {
    return '$responseId:$evidenceId';
  }

  static String queueIdForTask(SurveyEvidenceUploadTask task) {
    return queueId(responseId: task.responseId, evidenceId: task.evidenceId);
  }
}

class SurveyEvidenceUploadQueue {
  final List<SurveyEvidenceUploadQueueEntry> entries;

  const SurveyEvidenceUploadQueue({this.entries = const []});

  factory SurveyEvidenceUploadQueue.fromJson(Map<String, dynamic> json) {
    return SurveyEvidenceUploadQueue(
      entries: (json['entries'] as List? ?? const [])
          .map(
            (entry) => SurveyEvidenceUploadQueueEntry.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  int get pendingCount {
    return entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.pending,
        )
        .length;
  }

  int get failedCount {
    return entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.failed,
        )
        .length;
  }

  int get uploadedCount {
    return entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.uploaded,
        )
        .length;
  }

  SurveyEvidenceUploadQueueEntry? entryById(String id) {
    for (final entry in entries) {
      if (entry.id == id) {
        return entry;
      }
    }

    return null;
  }

  List<SurveyEvidenceUploadQueueEntry> dueEntries({
    required DateTime now,
    int? limit,
  }) {
    final due = entries.where((entry) => entry.isDue(now)).toList();
    due.sort((left, right) {
      final priority = left.priority.compareTo(right.priority);
      if (priority != 0) {
        return priority;
      }

      return left.createdAt.compareTo(right.createdAt);
    });

    return limit == null ? due : due.take(limit).toList();
  }

  SurveyEvidenceUploadQueue upsert(SurveyEvidenceUploadQueueEntry entry) {
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      return SurveyEvidenceUploadQueue(entries: [...entries, entry]);
    }

    final updated = [...entries];
    updated[index] = entry;
    return SurveyEvidenceUploadQueue(entries: updated);
  }

  SurveyEvidenceUploadQueue remove(String id) {
    return SurveyEvidenceUploadQueue(
      entries: entries.where((entry) => entry.id != id).toList(),
    );
  }

  SurveyEvidenceUploadQueue updateEntry(
    String id,
    SurveyEvidenceUploadQueueEntry Function(
      SurveyEvidenceUploadQueueEntry entry,
    )
    update,
  ) {
    final entry = entryById(id);
    if (entry == null) {
      return this;
    }

    return upsert(update(entry));
  }

  Map<String, dynamic> toJson() {
    return {'entries': entries.map((entry) => entry.toJson()).toList()};
  }
}

class SurveyEvidenceUploadQueuePlanner {
  final SurveyEvidenceUploadQueue queue;
  final SurveyEvidenceUploadPlan plan;
  final DateTime queuedAt;

  const SurveyEvidenceUploadQueuePlanner({
    required this.queue,
    required this.plan,
    required this.queuedAt,
  });

  SurveyEvidenceUploadQueue enqueueUploadableTasks({
    int? limit,
    Map<String, dynamic> metadata = const {},
  }) {
    final tasks = limit == null
        ? plan.uploadableTasks
        : plan.uploadableTasks.take(limit).toList();
    var nextQueue = queue;

    for (final task in tasks) {
      final id = SurveyEvidenceUploadQueueEntry.queueIdForTask(task);
      final existing = nextQueue.entryById(id);
      if (existing != null && !existing.isTerminal) {
        continue;
      }

      nextQueue = nextQueue.upsert(
        SurveyEvidenceUploadQueueEntry.fromTask(
          task,
          queuedAt: queuedAt,
          metadata: metadata,
        ),
      );
    }

    return nextQueue;
  }
}
