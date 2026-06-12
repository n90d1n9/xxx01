import '../analytics/survey_evidence_upload_planner.dart';
import '../analytics/survey_evidence_upload_queue_insights.dart';
import 'survey_evidence_upload_queue.dart';
import 'survey_evidence_upload_queue_coordinator.dart';
import 'survey_evidence_upload_queue_maintenance.dart';
import 'survey_evidence_upload_queue_processor.dart';
import 'survey_evidence_upload_retry_policy.dart';
import 'survey_evidence_upload_service.dart';

DateTime _defaultEvidenceUploadQueueActionClock() => DateTime.now();

enum SurveyEvidenceUploadQueueAction {
  loadState,
  enqueuePlan,
  runDueUploads,
  maintainQueue,
  requeueFailedUploads,
  syncPlan,
}

class SurveyEvidenceUploadQueueActionController {
  final SurveyEvidenceUploadQueueCoordinator coordinator;
  final SurveyEvidenceUploadClock clock;
  final Duration staleUploadingAfter;

  const SurveyEvidenceUploadQueueActionController({
    required this.coordinator,
    required this.clock,
    this.staleUploadingAfter = const Duration(minutes: 30),
  });

  factory SurveyEvidenceUploadQueueActionController.fromStore({
    required SurveyEvidenceUploadQueueStore store,
    required SurveyEvidenceUploader uploader,
    SurveyEvidenceUploadClock clock = _defaultEvidenceUploadQueueActionClock,
    SurveyEvidenceUploadRetryPolicy uploadRetryPolicy =
        const SurveyEvidenceUploadRetryPolicy.none(),
    SurveyEvidenceUploadRetryPolicy queueRetryPolicy =
        const SurveyEvidenceUploadRetryPolicy.none(),
    SurveyEvidenceUploadRetryWait retryWait =
        defaultSurveyEvidenceUploadRetryWait,
    Duration staleUploadingAfter = const Duration(minutes: 30),
  }) {
    final service = SurveyEvidenceUploadService(
      uploader: uploader,
      clock: clock,
      retryPolicy: uploadRetryPolicy,
      retryWait: retryWait,
    );

    return SurveyEvidenceUploadQueueActionController(
      coordinator: SurveyEvidenceUploadQueueCoordinator(
        store: store,
        service: service,
        queueRetryPolicy: queueRetryPolicy,
        clock: clock,
      ),
      clock: clock,
      staleUploadingAfter: staleUploadingAfter,
    );
  }

  Future<SurveyEvidenceUploadQueueActionState> loadState() async {
    final queue = await coordinator.store.load();
    return _stateFor(queue);
  }

  Future<SurveyEvidenceUploadQueueActionResult> enqueuePlan(
    SurveyEvidenceUploadPlan plan, {
    int? limit,
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = await coordinator.enqueuePlan(
      plan,
      limit: limit,
      metadata: metadata,
    );

    return _resultFor(
      action: SurveyEvidenceUploadQueueAction.enqueuePlan,
      queue: result.queue,
      message: result.summaryLabel,
      enqueueResult: result,
    );
  }

  Future<SurveyEvidenceUploadQueueActionResult> runDueUploads(
    SurveyEvidenceUploadPlan plan, {
    int? limit,
    bool stopOnFailure = false,
    SurveyEvidenceUploadObserver? observer,
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = await coordinator.processDue(
      plan,
      limit: limit,
      stopOnFailure: stopOnFailure,
      observer: observer,
      metadata: metadata,
    );

    return _resultFor(
      action: SurveyEvidenceUploadQueueAction.runDueUploads,
      queue: result.queue,
      message: result.summaryLabel,
      processResult: result,
    );
  }

  Future<SurveyEvidenceUploadQueueActionResult> maintainQueue({
    Duration? staleUploadingAfter,
    Duration? terminalRetention,
    bool pruneUploaded = true,
    bool pruneSkipped = true,
    bool pruneFailed = false,
    String staleUploadReason = 'Upload was interrupted and requeued.',
  }) async {
    final result = await coordinator.maintainQueue(
      staleUploadingAfter: staleUploadingAfter ?? this.staleUploadingAfter,
      terminalRetention: terminalRetention,
      pruneUploaded: pruneUploaded,
      pruneSkipped: pruneSkipped,
      pruneFailed: pruneFailed,
      staleUploadReason: staleUploadReason,
    );

    return _resultFor(
      action: SurveyEvidenceUploadQueueAction.maintainQueue,
      queue: result.queue,
      message: result.summaryLabel,
      maintenanceResult: result,
    );
  }

  Future<SurveyEvidenceUploadQueueActionResult> requeueFailedUploads({
    Iterable<String>? queueIds,
    int? limit,
    bool resetAttemptCount = false,
    String reason = 'Failed upload requeued.',
  }) async {
    final result = await coordinator.requeueFailedUploads(
      queueIds: queueIds,
      limit: limit,
      resetAttemptCount: resetAttemptCount,
      reason: reason,
    );

    return _resultFor(
      action: SurveyEvidenceUploadQueueAction.requeueFailedUploads,
      queue: result.queue,
      message: result.summaryLabel,
      maintenanceResult: result,
    );
  }

  Future<SurveyEvidenceUploadQueueActionResult> syncPlan(
    SurveyEvidenceUploadPlan plan, {
    int? enqueueLimit,
    int? processLimit,
    bool stopOnFailure = false,
    SurveyEvidenceUploadObserver? observer,
    Map<String, dynamic> metadata = const {},
  }) async {
    final result = await coordinator.syncPlan(
      plan,
      enqueueLimit: enqueueLimit,
      processLimit: processLimit,
      stopOnFailure: stopOnFailure,
      observer: observer,
      metadata: metadata,
    );

    return _resultFor(
      action: SurveyEvidenceUploadQueueAction.syncPlan,
      queue: result.finalQueue,
      message: result.summaryLabel,
      syncResult: result,
    );
  }

  SurveyEvidenceUploadQueueActionState _stateFor(
    SurveyEvidenceUploadQueue queue,
  ) {
    final generatedAt = clock();
    return SurveyEvidenceUploadQueueActionState(
      queue: queue,
      insights: SurveyEvidenceUploadQueueInsights(
        queue: queue,
        now: generatedAt,
        staleUploadingAfter: staleUploadingAfter,
      ),
      generatedAt: generatedAt,
    );
  }

  SurveyEvidenceUploadQueueActionResult _resultFor({
    required SurveyEvidenceUploadQueueAction action,
    required SurveyEvidenceUploadQueue queue,
    required String message,
    SurveyEvidenceUploadQueueEnqueueResult? enqueueResult,
    SurveyEvidenceUploadQueueProcessResult? processResult,
    SurveyEvidenceUploadQueueMaintenanceResult? maintenanceResult,
    SurveyEvidenceUploadQueueSyncResult? syncResult,
  }) {
    final state = _stateFor(queue);
    return SurveyEvidenceUploadQueueActionResult(
      action: action,
      queue: state.queue,
      insights: state.insights,
      generatedAt: state.generatedAt,
      message: message,
      enqueueResult: enqueueResult,
      processResult: processResult,
      maintenanceResult: maintenanceResult,
      syncResult: syncResult,
    );
  }
}

class SurveyEvidenceUploadQueueActionState {
  final SurveyEvidenceUploadQueue queue;
  final SurveyEvidenceUploadQueueInsights insights;
  final DateTime generatedAt;

  const SurveyEvidenceUploadQueueActionState({
    required this.queue,
    required this.insights,
    required this.generatedAt,
  });
}

class SurveyEvidenceUploadQueueActionResult
    extends SurveyEvidenceUploadQueueActionState {
  final SurveyEvidenceUploadQueueAction action;
  final String message;
  final SurveyEvidenceUploadQueueEnqueueResult? enqueueResult;
  final SurveyEvidenceUploadQueueProcessResult? processResult;
  final SurveyEvidenceUploadQueueMaintenanceResult? maintenanceResult;
  final SurveyEvidenceUploadQueueSyncResult? syncResult;

  const SurveyEvidenceUploadQueueActionResult({
    required this.action,
    required super.queue,
    required super.insights,
    required super.generatedAt,
    required this.message,
    this.enqueueResult,
    this.processResult,
    this.maintenanceResult,
    this.syncResult,
  });

  bool get changed {
    return (enqueueResult?.enqueuedCount ?? 0) > 0 ||
        (processResult?.processedCount ?? 0) > 0 ||
        (maintenanceResult?.changed ?? false) ||
        (syncResult?.hasWork ?? false);
  }
}
