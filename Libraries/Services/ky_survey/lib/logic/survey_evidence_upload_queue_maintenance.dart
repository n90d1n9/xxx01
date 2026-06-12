import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_queue.dart';

class SurveyEvidenceUploadQueueMaintenance {
  final SurveyEvidenceUploadQueue queue;
  final DateTime now;
  final Duration staleUploadingAfter;

  const SurveyEvidenceUploadQueueMaintenance({
    required this.queue,
    required this.now,
    this.staleUploadingAfter = const Duration(minutes: 30),
  });

  SurveyEvidenceUploadQueueMaintenanceResult run({
    Duration? terminalRetention,
    bool pruneUploaded = true,
    bool pruneSkipped = true,
    bool pruneFailed = false,
    String staleUploadReason = 'Upload was interrupted and requeued.',
  }) {
    final recovered = recoverStaleUploads(reason: staleUploadReason);
    if (terminalRetention == null) {
      return recovered;
    }

    final pruned =
        SurveyEvidenceUploadQueueMaintenance(
          queue: recovered.queue,
          now: now,
          staleUploadingAfter: staleUploadingAfter,
        ).pruneTerminalEntries(
          olderThan: terminalRetention,
          includeUploaded: pruneUploaded,
          includeSkipped: pruneSkipped,
          includeFailed: pruneFailed,
        );

    return SurveyEvidenceUploadQueueMaintenanceResult(
      initialQueue: queue,
      queue: pruned.queue,
      recoveredEntries: recovered.recoveredEntries,
      prunedEntries: pruned.prunedEntries,
      maintainedAt: now,
    );
  }

  SurveyEvidenceUploadQueueMaintenanceResult recoverStaleUploads({
    String reason = 'Upload was interrupted and requeued.',
  }) {
    final recoveredEntries = <SurveyEvidenceUploadQueueEntry>[];
    final entries = queue.entries.map((entry) {
      if (!_isStaleUploading(entry)) {
        return entry;
      }

      final recovered = entry.copyWith(
        status: SurveyEvidenceUploadQueueStatus.pending,
        updatedAt: now,
        nextAttemptAt: now,
        lastError: reason,
        clearRemoteUrl: true,
      );
      recoveredEntries.add(recovered);
      return recovered;
    }).toList();

    return SurveyEvidenceUploadQueueMaintenanceResult(
      initialQueue: queue,
      queue: SurveyEvidenceUploadQueue(entries: entries),
      recoveredEntries: recoveredEntries,
      maintainedAt: now,
    );
  }

  SurveyEvidenceUploadQueueMaintenanceResult requeueFailedEntries({
    Iterable<String>? queueIds,
    int? limit,
    bool resetAttemptCount = false,
    String reason = 'Failed upload requeued.',
  }) {
    final selectedIds = queueIds?.toSet();
    final requeuedEntries = <SurveyEvidenceUploadQueueEntry>[];
    final entries = queue.entries.map((entry) {
      if (!_canRequeueFailedEntry(entry, selectedIds: selectedIds)) {
        return entry;
      }
      if (limit != null && requeuedEntries.length >= limit) {
        return entry;
      }

      final requeued = entry.copyWith(
        action: SurveyEvidenceUploadAction.retryUpload,
        priority: 1,
        status: SurveyEvidenceUploadQueueStatus.pending,
        attemptCount: resetAttemptCount ? 0 : entry.attemptCount,
        updatedAt: now,
        nextAttemptAt: now,
        lastError: reason,
        clearRemoteUrl: true,
      );
      requeuedEntries.add(requeued);
      return requeued;
    }).toList();

    return SurveyEvidenceUploadQueueMaintenanceResult(
      initialQueue: queue,
      queue: SurveyEvidenceUploadQueue(entries: entries),
      requeuedEntries: requeuedEntries,
      maintainedAt: now,
    );
  }

  SurveyEvidenceUploadQueueMaintenanceResult pruneTerminalEntries({
    required Duration olderThan,
    bool includeUploaded = true,
    bool includeSkipped = true,
    bool includeFailed = false,
  }) {
    final cutoff = now.subtract(olderThan);
    final prunedEntries = <SurveyEvidenceUploadQueueEntry>[];
    final retainedEntries = <SurveyEvidenceUploadQueueEntry>[];

    for (final entry in queue.entries) {
      if (_shouldPrune(
        entry,
        cutoff: cutoff,
        includeUploaded: includeUploaded,
        includeSkipped: includeSkipped,
        includeFailed: includeFailed,
      )) {
        prunedEntries.add(entry);
      } else {
        retainedEntries.add(entry);
      }
    }

    return SurveyEvidenceUploadQueueMaintenanceResult(
      initialQueue: queue,
      queue: SurveyEvidenceUploadQueue(entries: retainedEntries),
      prunedEntries: prunedEntries,
      maintainedAt: now,
    );
  }

  bool _isStaleUploading(SurveyEvidenceUploadQueueEntry entry) {
    if (entry.status != SurveyEvidenceUploadQueueStatus.uploading) {
      return false;
    }

    return !entry.updatedAt.add(staleUploadingAfter).isAfter(now);
  }

  bool _shouldPrune(
    SurveyEvidenceUploadQueueEntry entry, {
    required DateTime cutoff,
    required bool includeUploaded,
    required bool includeSkipped,
    required bool includeFailed,
  }) {
    final statusMatches =
        (includeUploaded &&
            entry.status == SurveyEvidenceUploadQueueStatus.uploaded) ||
        (includeSkipped &&
            entry.status == SurveyEvidenceUploadQueueStatus.skipped) ||
        (includeFailed &&
            entry.status == SurveyEvidenceUploadQueueStatus.failed);
    if (!statusMatches) {
      return false;
    }

    return !entry.updatedAt.isAfter(cutoff);
  }

  bool _canRequeueFailedEntry(
    SurveyEvidenceUploadQueueEntry entry, {
    required Set<String>? selectedIds,
  }) {
    if (entry.status != SurveyEvidenceUploadQueueStatus.failed) {
      return false;
    }

    return selectedIds == null || selectedIds.contains(entry.id);
  }
}

class SurveyEvidenceUploadQueueMaintenanceResult {
  final SurveyEvidenceUploadQueue initialQueue;
  final SurveyEvidenceUploadQueue queue;
  final List<SurveyEvidenceUploadQueueEntry> recoveredEntries;
  final List<SurveyEvidenceUploadQueueEntry> requeuedEntries;
  final List<SurveyEvidenceUploadQueueEntry> prunedEntries;
  final DateTime maintainedAt;

  const SurveyEvidenceUploadQueueMaintenanceResult({
    required this.initialQueue,
    required this.queue,
    required this.maintainedAt,
    this.recoveredEntries = const [],
    this.requeuedEntries = const [],
    this.prunedEntries = const [],
  });

  bool get changed {
    return recoveredEntries.isNotEmpty ||
        requeuedEntries.isNotEmpty ||
        prunedEntries.isNotEmpty;
  }

  int get recoveredCount => recoveredEntries.length;

  int get requeuedCount => requeuedEntries.length;

  int get prunedCount => prunedEntries.length;

  String get summaryLabel {
    if (!changed) {
      return 'Queue maintenance made no changes';
    }

    final parts = <String>[];
    if (recoveredCount > 0) {
      parts.add('$recoveredCount recovered');
    }
    if (requeuedCount > 0) {
      parts.add('$requeuedCount requeued');
    }
    if (prunedCount > 0) {
      parts.add('$prunedCount pruned');
    }

    return parts.join(', ');
  }
}
