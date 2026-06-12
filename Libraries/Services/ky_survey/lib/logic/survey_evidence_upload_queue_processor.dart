import '../analytics/survey_evidence_upload_planner.dart';
import 'survey_evidence_upload_queue.dart';
import 'survey_evidence_upload_retry_policy.dart';
import 'survey_evidence_upload_service.dart';

class SurveyEvidenceUploadQueueProcessor {
  final SurveyEvidenceUploadService service;
  final SurveyEvidenceUploadRetryPolicy queueRetryPolicy;

  const SurveyEvidenceUploadQueueProcessor({
    required this.service,
    this.queueRetryPolicy = const SurveyEvidenceUploadRetryPolicy.none(),
  });

  Future<SurveyEvidenceUploadQueueProcessResult> processDueEntries({
    required SurveyEvidenceUploadQueue queue,
    required SurveyEvidenceUploadPlan plan,
    required DateTime now,
    int? limit,
    bool stopOnFailure = false,
    SurveyEvidenceUploadObserver? observer,
    Map<String, dynamic> metadata = const {},
  }) async {
    final taskByQueueId = {
      for (final task in plan.uploadableTasks)
        SurveyEvidenceUploadQueueEntry.queueIdForTask(task): task,
    };
    final dueEntries = queue.dueEntries(now: now, limit: limit);
    final items = <SurveyEvidenceUploadQueueProcessItem>[];
    var nextQueue = queue;

    for (final entry in dueEntries) {
      final task = taskByQueueId[entry.id];
      if (task == null) {
        final skippedEntry = entry.markSkipped(
          reason: 'Upload task is no longer available.',
          skippedAt: now,
        );
        nextQueue = nextQueue.upsert(skippedEntry);
        items.add(
          SurveyEvidenceUploadQueueProcessItem(
            originalEntry: entry,
            updatedEntry: skippedEntry,
            message: skippedEntry.lastError,
          ),
        );
        continue;
      }

      final uploadingEntry = entry.markUploading(now);
      nextQueue = nextQueue.upsert(uploadingEntry);
      final execution = await service.uploadTask(
        task,
        attempt: entry.attemptCount + 1,
        observer: observer,
        metadata: metadata,
      );
      final updatedEntry = _entryForExecution(uploadingEntry, execution);
      nextQueue = nextQueue.upsert(updatedEntry);
      items.add(
        SurveyEvidenceUploadQueueProcessItem(
          originalEntry: entry,
          updatedEntry: updatedEntry,
          execution: execution,
          message: execution.message,
        ),
      );

      if (stopOnFailure && execution.failed) {
        break;
      }
    }

    return SurveyEvidenceUploadQueueProcessResult(
      queue: nextQueue,
      items: items,
      dueEntryCount: dueEntries.length,
    );
  }

  SurveyEvidenceUploadQueueEntry _entryForExecution(
    SurveyEvidenceUploadQueueEntry entry,
    SurveyEvidenceUploadExecution execution,
  ) {
    switch (execution.status) {
      case SurveyEvidenceUploadExecutionStatus.uploaded:
        return entry.markUploaded(
          remoteUrl: execution.remoteUrl!,
          uploadedAt: execution.completedAt,
        );
      case SurveyEvidenceUploadExecutionStatus.failed:
        return entry.markFailed(
          error: execution.message ?? 'Upload failed',
          failedAt: execution.completedAt,
          retryPolicy: queueRetryPolicy,
        );
      case SurveyEvidenceUploadExecutionStatus.skipped:
      case SurveyEvidenceUploadExecutionStatus.noTask:
        return entry.markSkipped(
          reason: execution.message ?? 'Upload skipped',
          skippedAt: execution.completedAt,
        );
    }
  }
}

class SurveyEvidenceUploadQueueProcessResult {
  final SurveyEvidenceUploadQueue queue;
  final List<SurveyEvidenceUploadQueueProcessItem> items;
  final int dueEntryCount;

  const SurveyEvidenceUploadQueueProcessResult({
    required this.queue,
    required this.items,
    required this.dueEntryCount,
  });

  bool get hasWork => dueEntryCount > 0;

  int get processedCount => items.length;

  int get uploadedCount {
    return items.where((item) => item.didUpload).length;
  }

  int get failedCount {
    return items.where((item) => item.failed).length;
  }

  int get retryScheduledCount {
    return items.where((item) => item.retryScheduled).length;
  }

  int get skippedCount {
    return items.where((item) => item.skipped).length;
  }

  String get summaryLabel {
    if (!hasWork) {
      return 'No due evidence uploads';
    }

    final parts = <String>[];
    if (uploadedCount > 0) {
      parts.add('$uploadedCount uploaded');
    }
    if (retryScheduledCount > 0) {
      parts.add('$retryScheduledCount retry scheduled');
    }
    if (failedCount > 0) {
      parts.add('$failedCount failed');
    }
    if (skippedCount > 0) {
      parts.add('$skippedCount skipped');
    }

    return parts.isEmpty ? '$processedCount processed' : parts.join(', ');
  }
}

class SurveyEvidenceUploadQueueProcessItem {
  final SurveyEvidenceUploadQueueEntry originalEntry;
  final SurveyEvidenceUploadQueueEntry updatedEntry;
  final SurveyEvidenceUploadExecution? execution;
  final String? message;

  const SurveyEvidenceUploadQueueProcessItem({
    required this.originalEntry,
    required this.updatedEntry,
    this.execution,
    this.message,
  });

  bool get didUpload {
    return updatedEntry.status == SurveyEvidenceUploadQueueStatus.uploaded;
  }

  bool get failed {
    return updatedEntry.status == SurveyEvidenceUploadQueueStatus.failed;
  }

  bool get retryScheduled {
    return updatedEntry.status == SurveyEvidenceUploadQueueStatus.pending &&
        updatedEntry.attemptCount > originalEntry.attemptCount;
  }

  bool get skipped {
    return updatedEntry.status == SurveyEvidenceUploadQueueStatus.skipped;
  }
}
