import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_queue.dart';
import 'survey_evidence_upload_queue_maintenance.dart';
import 'survey_evidence_upload_queue_processor.dart';
import 'survey_evidence_upload_retry_policy.dart';
import 'survey_evidence_upload_service.dart';

DateTime _defaultEvidenceUploadQueueClock() => DateTime.now();

abstract interface class SurveyEvidenceUploadQueueStore {
  Future<SurveyEvidenceUploadQueue> load();

  Future<void> save(SurveyEvidenceUploadQueue queue);
}

class SurveyEvidenceUploadMemoryQueueStore
    implements SurveyEvidenceUploadQueueStore {
  SurveyEvidenceUploadQueue _queue;

  SurveyEvidenceUploadMemoryQueueStore({
    SurveyEvidenceUploadQueue initialQueue = const SurveyEvidenceUploadQueue(),
  }) : _queue = initialQueue;

  SurveyEvidenceUploadQueue get queue => _queue;

  @override
  Future<SurveyEvidenceUploadQueue> load() async => _queue;

  @override
  Future<void> save(SurveyEvidenceUploadQueue queue) async {
    _queue = queue;
  }
}

class SurveyEvidenceUploadQueueCoordinator {
  final SurveyEvidenceUploadQueueStore store;
  final SurveyEvidenceUploadService service;
  final SurveyEvidenceUploadRetryPolicy queueRetryPolicy;
  final SurveyEvidenceUploadClock clock;

  const SurveyEvidenceUploadQueueCoordinator({
    required this.store,
    required this.service,
    this.queueRetryPolicy = const SurveyEvidenceUploadRetryPolicy.none(),
    this.clock = _defaultEvidenceUploadQueueClock,
  });

  Future<SurveyEvidenceUploadQueueEnqueueResult> enqueuePlan(
    SurveyEvidenceUploadPlan plan, {
    int? limit,
    Map<String, dynamic> metadata = const {},
  }) async {
    final initialQueue = await store.load();
    final queuedAt = clock();
    final queue = _enqueuePlan(
      queue: initialQueue,
      plan: plan,
      queuedAt: queuedAt,
      limit: limit,
      metadata: metadata,
    );
    final enqueuedEntries = _enqueuedEntries(
      before: initialQueue,
      after: queue,
      queuedAt: queuedAt,
    );

    await store.save(queue);
    return SurveyEvidenceUploadQueueEnqueueResult(
      initialQueue: initialQueue,
      queue: queue,
      enqueuedEntries: enqueuedEntries,
      queuedAt: queuedAt,
    );
  }

  Future<SurveyEvidenceUploadQueueProcessResult> processDue(
    SurveyEvidenceUploadPlan plan, {
    int? limit,
    bool stopOnFailure = false,
    SurveyEvidenceUploadObserver? observer,
    Map<String, dynamic> metadata = const {},
  }) async {
    final queue = await store.load();
    final processor = _processor;
    final result = await processor.processDueEntries(
      queue: queue,
      plan: plan,
      now: clock(),
      limit: limit,
      stopOnFailure: stopOnFailure,
      observer: observer,
      metadata: metadata,
    );

    await store.save(result.queue);
    return result;
  }

  Future<SurveyEvidenceUploadQueueMaintenanceResult> maintainQueue({
    Duration staleUploadingAfter = const Duration(minutes: 30),
    Duration? terminalRetention,
    bool pruneUploaded = true,
    bool pruneSkipped = true,
    bool pruneFailed = false,
    String staleUploadReason = 'Upload was interrupted and requeued.',
  }) async {
    final queue = await store.load();
    final result =
        SurveyEvidenceUploadQueueMaintenance(
          queue: queue,
          now: clock(),
          staleUploadingAfter: staleUploadingAfter,
        ).run(
          terminalRetention: terminalRetention,
          pruneUploaded: pruneUploaded,
          pruneSkipped: pruneSkipped,
          pruneFailed: pruneFailed,
          staleUploadReason: staleUploadReason,
        );

    if (result.changed) {
      await store.save(result.queue);
    }
    return result;
  }

  Future<SurveyEvidenceUploadQueueMaintenanceResult> requeueFailedUploads({
    Iterable<String>? queueIds,
    int? limit,
    bool resetAttemptCount = false,
    String reason = 'Failed upload requeued.',
  }) async {
    final queue = await store.load();
    final result =
        SurveyEvidenceUploadQueueMaintenance(
          queue: queue,
          now: clock(),
        ).requeueFailedEntries(
          queueIds: queueIds,
          limit: limit,
          resetAttemptCount: resetAttemptCount,
          reason: reason,
        );

    if (result.changed) {
      await store.save(result.queue);
    }
    return result;
  }

  Future<SurveyEvidenceUploadQueueSyncResult> syncPlan(
    SurveyEvidenceUploadPlan plan, {
    int? enqueueLimit,
    int? processLimit,
    bool stopOnFailure = false,
    SurveyEvidenceUploadObserver? observer,
    Map<String, dynamic> metadata = const {},
  }) async {
    final initialQueue = await store.load();
    final queuedAt = clock();
    final queuedQueue = _enqueuePlan(
      queue: initialQueue,
      plan: plan,
      queuedAt: queuedAt,
      limit: enqueueLimit,
      metadata: metadata,
    );
    final enqueuedEntries = _enqueuedEntries(
      before: initialQueue,
      after: queuedQueue,
      queuedAt: queuedAt,
    );

    await store.save(queuedQueue);

    final processedAt = clock();
    final processResult = await _processor.processDueEntries(
      queue: queuedQueue,
      plan: plan,
      now: processedAt,
      limit: processLimit,
      stopOnFailure: stopOnFailure,
      observer: observer,
      metadata: metadata,
    );

    await store.save(processResult.queue);
    return SurveyEvidenceUploadQueueSyncResult(
      initialQueue: initialQueue,
      queuedQueue: queuedQueue,
      processResult: processResult,
      enqueuedEntries: enqueuedEntries,
      queuedAt: queuedAt,
      processedAt: processedAt,
    );
  }

  SurveyEvidenceUploadQueueProcessor get _processor {
    return SurveyEvidenceUploadQueueProcessor(
      service: service,
      queueRetryPolicy: queueRetryPolicy,
    );
  }

  SurveyEvidenceUploadQueue _enqueuePlan({
    required SurveyEvidenceUploadQueue queue,
    required SurveyEvidenceUploadPlan plan,
    required DateTime queuedAt,
    int? limit,
    Map<String, dynamic> metadata = const {},
  }) {
    return SurveyEvidenceUploadQueuePlanner(
      queue: queue,
      plan: plan,
      queuedAt: queuedAt,
    ).enqueueUploadableTasks(limit: limit, metadata: metadata);
  }

  List<SurveyEvidenceUploadQueueEntry> _enqueuedEntries({
    required SurveyEvidenceUploadQueue before,
    required SurveyEvidenceUploadQueue after,
    required DateTime queuedAt,
  }) {
    return after.entries.where((entry) {
      if (entry.createdAt != queuedAt) {
        return false;
      }

      final previous = before.entryById(entry.id);
      return previous == null || previous.isTerminal;
    }).toList();
  }
}

class SurveyEvidenceUploadQueueEnqueueResult {
  final SurveyEvidenceUploadQueue initialQueue;
  final SurveyEvidenceUploadQueue queue;
  final List<SurveyEvidenceUploadQueueEntry> enqueuedEntries;
  final DateTime queuedAt;

  const SurveyEvidenceUploadQueueEnqueueResult({
    required this.initialQueue,
    required this.queue,
    required this.enqueuedEntries,
    required this.queuedAt,
  });

  bool get hasWork => enqueuedEntries.isNotEmpty;

  int get enqueuedCount => enqueuedEntries.length;

  String get summaryLabel {
    if (!hasWork) {
      return 'No evidence uploads queued';
    }

    return '$enqueuedCount queued';
  }
}

class SurveyEvidenceUploadQueueSyncResult {
  final SurveyEvidenceUploadQueue initialQueue;
  final SurveyEvidenceUploadQueue queuedQueue;
  final SurveyEvidenceUploadQueueProcessResult processResult;
  final List<SurveyEvidenceUploadQueueEntry> enqueuedEntries;
  final DateTime queuedAt;
  final DateTime processedAt;

  const SurveyEvidenceUploadQueueSyncResult({
    required this.initialQueue,
    required this.queuedQueue,
    required this.processResult,
    required this.enqueuedEntries,
    required this.queuedAt,
    required this.processedAt,
  });

  SurveyEvidenceUploadQueue get finalQueue => processResult.queue;

  bool get hasWork => enqueuedEntries.isNotEmpty || processResult.hasWork;

  int get enqueuedCount => enqueuedEntries.length;

  int get processedCount => processResult.processedCount;

  int get uploadedCount => processResult.uploadedCount;

  int get failedCount => processResult.failedCount;

  int get retryScheduledCount => processResult.retryScheduledCount;

  int get skippedCount => processResult.skippedCount;

  String get summaryLabel {
    if (!hasWork) {
      return 'No evidence uploads ready';
    }

    final parts = <String>[];
    if (enqueuedCount > 0) {
      parts.add('$enqueuedCount queued');
    }
    if (processedCount > 0) {
      parts.add(processResult.summaryLabel);
    }

    return parts.isEmpty ? processResult.summaryLabel : parts.join(', ');
  }
}
