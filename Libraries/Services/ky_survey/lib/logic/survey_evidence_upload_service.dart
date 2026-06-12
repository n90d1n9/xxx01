import '../analytics/survey_evidence_sync_insights.dart';
import '../analytics/survey_evidence_upload_planner.dart';
import '../models/survey.dart';
import '../models/survey_attachment.dart';
import '../models/survey_evidence.dart';
import '../models/survey_evidence_requirement.dart';
import '../models/survey_response.dart';
import 'survey_evidence_upload_retry_policy.dart';

typedef SurveyEvidenceUploadClock = DateTime Function();

DateTime _defaultEvidenceUploadClock() => DateTime.now();

abstract interface class SurveyEvidenceUploader {
  Future<SurveyEvidenceUploadResult> upload(
    SurveyEvidenceUploadRequest request,
  );
}

class SurveyEvidenceUploadService {
  final SurveyEvidenceUploader uploader;
  final SurveyEvidenceUploadClock clock;
  final SurveyEvidenceUploadRetryPolicy retryPolicy;
  final SurveyEvidenceUploadRetryWait retryWait;

  const SurveyEvidenceUploadService({
    required this.uploader,
    this.clock = _defaultEvidenceUploadClock,
    this.retryPolicy = const SurveyEvidenceUploadRetryPolicy.none(),
    this.retryWait = defaultSurveyEvidenceUploadRetryWait,
  });

  Future<SurveyEvidenceUploadExecution> uploadNext(
    SurveyEvidenceUploadPlan plan, {
    SurveyEvidenceUploadObserver? observer,
    int attempt = 1,
    Map<String, dynamic> metadata = const {},
  }) {
    final task = plan.nextUploadTask;
    if (task == null) {
      return Future.value(
        SurveyEvidenceUploadExecution.noTask(completedAt: clock()),
      );
    }

    return uploadTask(
      task,
      observer: observer,
      attempt: attempt,
      metadata: metadata,
    );
  }

  Future<SurveyEvidenceUploadBatchExecution> uploadPlan(
    SurveyEvidenceUploadPlan plan, {
    SurveyEvidenceUploadObserver? observer,
    int attempt = 1,
    int? limit,
    bool stopOnFailure = false,
    Map<String, dynamic> metadata = const {},
  }) async {
    final startedAt = clock();
    final tasks = limit == null
        ? plan.uploadableTasks
        : plan.uploadableTasks.take(limit).toList();
    final executions = <SurveyEvidenceUploadExecution>[];

    for (final task in tasks) {
      final execution = await uploadTask(
        task,
        observer: observer,
        attempt: attempt,
        metadata: metadata,
      );
      executions.add(execution);

      if (stopOnFailure && execution.failed) {
        break;
      }
    }

    return SurveyEvidenceUploadBatchExecution(
      executions: executions,
      requestedTaskCount: tasks.length,
      startedAt: startedAt,
      completedAt: clock(),
    );
  }

  Future<SurveyEvidenceUploadExecution> uploadTask(
    SurveyEvidenceUploadTask task, {
    SurveyEvidenceUploadObserver? observer,
    int attempt = 1,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!task.canStartUpload) {
      final skippedAt = clock();
      final reason = 'Task action ${task.actionLabel} cannot start upload.';
      observer?.onSkipped(task, reason, skippedAt);
      return SurveyEvidenceUploadExecution.skipped(
        task: task,
        completedAt: skippedAt,
        message: reason,
      );
    }

    var currentAttempt = attempt;
    var completedAttempts = 0;

    while (true) {
      final queuedAt = clock();
      observer?.onQueued(task, queuedAt);
      final uploadingAt = clock();
      observer?.onUploading(task, uploadingAt);

      final request = SurveyEvidenceUploadRequest(
        task: task,
        attempt: currentAttempt,
        queuedAt: queuedAt,
        uploadingAt: uploadingAt,
        metadata: metadata,
      );

      final result = _normalizeUploadResult(await _upload(request));
      final completedAt = clock();
      completedAttempts += 1;

      if (result.status == SurveyEvidenceUploadResultStatus.uploaded) {
        observer?.onUploaded(task, result, completedAt);
        return SurveyEvidenceUploadExecution.uploaded(
          task: task,
          queuedAt: queuedAt,
          uploadingAt: uploadingAt,
          completedAt: completedAt,
          remoteUrl: result.remoteUrl!,
          metadata: result.metadata,
        );
      }

      if (result.status == SurveyEvidenceUploadResultStatus.skipped) {
        final reason = result.message ?? 'Upload skipped';
        observer?.onSkipped(task, reason, completedAt);
        return SurveyEvidenceUploadExecution.skipped(
          task: task,
          queuedAt: queuedAt,
          uploadingAt: uploadingAt,
          completedAt: completedAt,
          message: reason,
          metadata: result.metadata,
        );
      }

      final shouldRetry = retryPolicy.shouldRetry(
        completedAttempts: completedAttempts,
        failed: true,
      );
      if (!shouldRetry) {
        observer?.onFailed(task, result, completedAt);
        return SurveyEvidenceUploadExecution.failed(
          task: task,
          queuedAt: queuedAt,
          uploadingAt: uploadingAt,
          completedAt: completedAt,
          message: result.message ?? 'Upload failed',
          metadata: result.metadata,
        );
      }

      final retryDelay = retryPolicy.delayAfterAttempt(completedAttempts);
      observer?.onRetrying(
        task,
        result,
        currentAttempt + 1,
        retryDelay,
        completedAt,
      );
      await retryWait(retryDelay);
      currentAttempt += 1;
    }
  }

  Future<SurveyEvidenceUploadResult> _upload(
    SurveyEvidenceUploadRequest request,
  ) async {
    try {
      return await uploader.upload(request);
    } catch (error) {
      return SurveyEvidenceUploadResult.failed(
        message: error.toString(),
        metadata: {'errorType': error.runtimeType.toString()},
      );
    }
  }

  SurveyEvidenceUploadResult _normalizeUploadResult(
    SurveyEvidenceUploadResult result,
  ) {
    if (result.status != SurveyEvidenceUploadResultStatus.uploaded) {
      return result;
    }

    final remoteUrl = result.remoteUrl;
    if (remoteUrl != null && remoteUrl.trim().isNotEmpty) {
      return result;
    }

    return SurveyEvidenceUploadResult.failed(
      message: 'Upload completed without a remote URL.',
      metadata: result.metadata,
    );
  }
}

class SurveyEvidenceUploadRequest {
  final SurveyEvidenceUploadTask task;
  final int attempt;
  final DateTime queuedAt;
  final DateTime uploadingAt;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceUploadRequest({
    required this.task,
    required this.attempt,
    required this.queuedAt,
    required this.uploadingAt,
    this.metadata = const {},
  });

  SurveyEvidenceSyncItem get item => task.item;

  Survey get survey => item.survey;

  SurveyResponse get response => item.response;

  SurveyEvidence get evidence => item.evidence;

  SurveyAttachment get attachment => item.attachment;

  SurveyEvidenceRequirement? get requirement => item.requirement;
}

enum SurveyEvidenceUploadResultStatus { uploaded, failed, skipped }

class SurveyEvidenceUploadResult {
  final SurveyEvidenceUploadResultStatus status;
  final String? remoteUrl;
  final String? message;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceUploadResult._({
    required this.status,
    this.remoteUrl,
    this.message,
    this.metadata = const {},
  });

  const SurveyEvidenceUploadResult.uploaded({
    required String remoteUrl,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         status: SurveyEvidenceUploadResultStatus.uploaded,
         remoteUrl: remoteUrl,
         metadata: metadata,
       );

  const SurveyEvidenceUploadResult.failed({
    required String message,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         status: SurveyEvidenceUploadResultStatus.failed,
         message: message,
         metadata: metadata,
       );

  const SurveyEvidenceUploadResult.skipped({
    required String message,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         status: SurveyEvidenceUploadResultStatus.skipped,
         message: message,
         metadata: metadata,
       );
}

enum SurveyEvidenceUploadExecutionStatus { noTask, skipped, uploaded, failed }

class SurveyEvidenceUploadExecution {
  final SurveyEvidenceUploadTask? task;
  final SurveyEvidenceUploadExecutionStatus status;
  final DateTime? queuedAt;
  final DateTime? uploadingAt;
  final DateTime completedAt;
  final String? remoteUrl;
  final String? message;
  final Map<String, dynamic> metadata;

  const SurveyEvidenceUploadExecution._({
    required this.status,
    required this.completedAt,
    this.task,
    this.queuedAt,
    this.uploadingAt,
    this.remoteUrl,
    this.message,
    this.metadata = const {},
  });

  const SurveyEvidenceUploadExecution.noTask({required DateTime completedAt})
    : this._(
        status: SurveyEvidenceUploadExecutionStatus.noTask,
        completedAt: completedAt,
        message: 'No uploadable evidence task is available.',
      );

  const SurveyEvidenceUploadExecution.uploaded({
    required SurveyEvidenceUploadTask task,
    required DateTime queuedAt,
    required DateTime uploadingAt,
    required DateTime completedAt,
    required String remoteUrl,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         task: task,
         status: SurveyEvidenceUploadExecutionStatus.uploaded,
         queuedAt: queuedAt,
         uploadingAt: uploadingAt,
         completedAt: completedAt,
         remoteUrl: remoteUrl,
         metadata: metadata,
       );

  const SurveyEvidenceUploadExecution.failed({
    required SurveyEvidenceUploadTask task,
    required DateTime queuedAt,
    required DateTime uploadingAt,
    required DateTime completedAt,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         task: task,
         status: SurveyEvidenceUploadExecutionStatus.failed,
         queuedAt: queuedAt,
         uploadingAt: uploadingAt,
         completedAt: completedAt,
         message: message,
         metadata: metadata,
       );

  const SurveyEvidenceUploadExecution.skipped({
    required SurveyEvidenceUploadTask task,
    required DateTime completedAt,
    DateTime? queuedAt,
    DateTime? uploadingAt,
    required String message,
    Map<String, dynamic> metadata = const {},
  }) : this._(
         task: task,
         status: SurveyEvidenceUploadExecutionStatus.skipped,
         queuedAt: queuedAt,
         uploadingAt: uploadingAt,
         completedAt: completedAt,
         message: message,
         metadata: metadata,
       );

  bool get didUpload => status == SurveyEvidenceUploadExecutionStatus.uploaded;

  bool get failed => status == SurveyEvidenceUploadExecutionStatus.failed;
}

class SurveyEvidenceUploadBatchExecution {
  final List<SurveyEvidenceUploadExecution> executions;
  final int requestedTaskCount;
  final DateTime startedAt;
  final DateTime completedAt;

  const SurveyEvidenceUploadBatchExecution({
    required this.executions,
    required this.requestedTaskCount,
    required this.startedAt,
    required this.completedAt,
  });

  bool get hasWork => requestedTaskCount > 0;

  int get attemptedCount => executions.length;

  int get uploadedCount {
    return executions
        .where(
          (execution) =>
              execution.status == SurveyEvidenceUploadExecutionStatus.uploaded,
        )
        .length;
  }

  int get failedCount {
    return executions
        .where(
          (execution) =>
              execution.status == SurveyEvidenceUploadExecutionStatus.failed,
        )
        .length;
  }

  int get skippedCount {
    return executions
        .where(
          (execution) =>
              execution.status == SurveyEvidenceUploadExecutionStatus.skipped,
        )
        .length;
  }

  bool get hasFailures => failedCount > 0;

  bool get isComplete => attemptedCount == requestedTaskCount && !hasFailures;

  String get summaryLabel {
    if (!hasWork) {
      return 'No uploadable evidence tasks';
    }

    if (hasFailures) {
      return '$uploadedCount uploaded, $failedCount failed';
    }

    return '$uploadedCount uploaded';
  }
}

abstract class SurveyEvidenceUploadObserver {
  const SurveyEvidenceUploadObserver();

  void onQueued(SurveyEvidenceUploadTask task, DateTime queuedAt) {}

  void onUploading(SurveyEvidenceUploadTask task, DateTime uploadingAt) {}

  void onUploaded(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime uploadedAt,
  ) {}

  void onFailed(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime failedAt,
  ) {}

  void onSkipped(
    SurveyEvidenceUploadTask task,
    String reason,
    DateTime skippedAt,
  ) {}

  void onRetrying(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    int nextAttempt,
    Duration retryDelay,
    DateTime retryingAt,
  ) {}
}

class SurveyEvidenceUploadCallbacks extends SurveyEvidenceUploadObserver {
  final void Function(SurveyEvidenceUploadTask task, DateTime queuedAt)? queued;
  final void Function(SurveyEvidenceUploadTask task, DateTime uploadingAt)?
  uploading;
  final void Function(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime uploadedAt,
  )?
  uploaded;
  final void Function(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime failedAt,
  )?
  failed;
  final void Function(
    SurveyEvidenceUploadTask task,
    String reason,
    DateTime skippedAt,
  )?
  skipped;
  final void Function(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    int nextAttempt,
    Duration retryDelay,
    DateTime retryingAt,
  )?
  retrying;

  const SurveyEvidenceUploadCallbacks({
    this.queued,
    this.uploading,
    this.uploaded,
    this.failed,
    this.skipped,
    this.retrying,
  });

  @override
  void onQueued(SurveyEvidenceUploadTask task, DateTime queuedAt) {
    queued?.call(task, queuedAt);
  }

  @override
  void onUploading(SurveyEvidenceUploadTask task, DateTime uploadingAt) {
    uploading?.call(task, uploadingAt);
  }

  @override
  void onUploaded(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime uploadedAt,
  ) {
    uploaded?.call(task, result, uploadedAt);
  }

  @override
  void onFailed(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    DateTime failedAt,
  ) {
    failed?.call(task, result, failedAt);
  }

  @override
  void onSkipped(
    SurveyEvidenceUploadTask task,
    String reason,
    DateTime skippedAt,
  ) {
    skipped?.call(task, reason, skippedAt);
  }

  @override
  void onRetrying(
    SurveyEvidenceUploadTask task,
    SurveyEvidenceUploadResult result,
    int nextAttempt,
    Duration retryDelay,
    DateTime retryingAt,
  ) {
    retrying?.call(task, result, nextAttempt, retryDelay, retryingAt);
  }
}
