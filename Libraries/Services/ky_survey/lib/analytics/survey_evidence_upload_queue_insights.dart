import '../logic/survey_evidence_upload_queue.dart';

enum SurveyEvidenceUploadQueueHealth {
  empty,
  ready,
  waiting,
  uploading,
  needsAttention,
  complete,
}

class SurveyEvidenceUploadQueueInsights {
  final SurveyEvidenceUploadQueue queue;
  final DateTime now;
  final Duration staleUploadingAfter;

  const SurveyEvidenceUploadQueueInsights({
    required this.queue,
    required this.now,
    this.staleUploadingAfter = const Duration(minutes: 30),
  });

  List<SurveyEvidenceUploadQueueEntry> get pendingEntries {
    return queue.entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.pending,
        )
        .toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get dueEntries {
    return queue.dueEntries(now: now);
  }

  List<SurveyEvidenceUploadQueueEntry> get waitingEntries {
    return pendingEntries.where((entry) => !entry.isDue(now)).toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get uploadingEntries {
    return queue.entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.uploading,
        )
        .toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get staleUploadingEntries {
    return uploadingEntries.where((entry) {
      return !entry.updatedAt.add(staleUploadingAfter).isAfter(now);
    }).toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get failedEntries {
    return queue.entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.failed,
        )
        .toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get uploadedEntries {
    return queue.entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.uploaded,
        )
        .toList();
  }

  List<SurveyEvidenceUploadQueueEntry> get skippedEntries {
    return queue.entries
        .where(
          (entry) => entry.status == SurveyEvidenceUploadQueueStatus.skipped,
        )
        .toList();
  }

  int get totalCount => queue.entries.length;

  int get pendingCount => pendingEntries.length;

  int get dueCount => dueEntries.length;

  int get waitingCount => waitingEntries.length;

  int get uploadingCount => uploadingEntries.length;

  int get staleUploadingCount => staleUploadingEntries.length;

  int get failedCount => failedEntries.length;

  int get uploadedCount => uploadedEntries.length;

  int get skippedCount => skippedEntries.length;

  int get terminalCount => uploadedCount + skippedCount;

  bool get hasWork => dueCount > 0 || waitingCount > 0 || uploadingCount > 0;

  bool get needsAttention => failedCount > 0 || staleUploadingCount > 0;

  bool get isComplete => totalCount > 0 && terminalCount == totalCount;

  DateTime? get oldestPendingAt {
    return _oldest(pendingEntries.map((entry) => entry.createdAt));
  }

  DateTime? get oldestDueAt {
    return _oldest(dueEntries.map((entry) => entry.createdAt));
  }

  DateTime? get nextWakeAt {
    return _oldest(
      waitingEntries.map((entry) => entry.nextAttemptAt).whereType<DateTime>(),
    );
  }

  Duration? get waitUntilNextWake {
    final wakeAt = nextWakeAt;
    if (wakeAt == null) {
      return null;
    }

    final wait = wakeAt.difference(now);
    return wait.isNegative ? Duration.zero : wait;
  }

  SurveyEvidenceUploadQueueHealth get health {
    if (queue.isEmpty) {
      return SurveyEvidenceUploadQueueHealth.empty;
    }
    if (needsAttention) {
      return SurveyEvidenceUploadQueueHealth.needsAttention;
    }
    if (dueCount > 0) {
      return SurveyEvidenceUploadQueueHealth.ready;
    }
    if (uploadingCount > 0) {
      return SurveyEvidenceUploadQueueHealth.uploading;
    }
    if (waitingCount > 0) {
      return SurveyEvidenceUploadQueueHealth.waiting;
    }
    if (isComplete) {
      return SurveyEvidenceUploadQueueHealth.complete;
    }

    return SurveyEvidenceUploadQueueHealth.empty;
  }

  String get healthLabel {
    switch (health) {
      case SurveyEvidenceUploadQueueHealth.empty:
        return 'No queued uploads';
      case SurveyEvidenceUploadQueueHealth.ready:
        return 'Ready to upload';
      case SurveyEvidenceUploadQueueHealth.waiting:
        return 'Waiting for retry';
      case SurveyEvidenceUploadQueueHealth.uploading:
        return 'Uploading';
      case SurveyEvidenceUploadQueueHealth.needsAttention:
        return 'Needs attention';
      case SurveyEvidenceUploadQueueHealth.complete:
        return 'Complete';
    }
  }

  String get nextActionLabel {
    switch (health) {
      case SurveyEvidenceUploadQueueHealth.empty:
        return 'Queue evidence uploads';
      case SurveyEvidenceUploadQueueHealth.ready:
        return 'Run due uploads';
      case SurveyEvidenceUploadQueueHealth.waiting:
        return 'Wait for next retry';
      case SurveyEvidenceUploadQueueHealth.uploading:
        return 'Monitor active uploads';
      case SurveyEvidenceUploadQueueHealth.needsAttention:
        return 'Review failed uploads';
      case SurveyEvidenceUploadQueueHealth.complete:
        return 'Review uploaded evidence';
    }
  }

  String get summaryLabel {
    if (queue.isEmpty) {
      return 'No queued evidence uploads';
    }

    final parts = <String>[];
    if (dueCount > 0) {
      parts.add('$dueCount due');
    }
    if (waitingCount > 0) {
      parts.add('$waitingCount waiting');
    }
    if (uploadingCount > 0) {
      parts.add('$uploadingCount uploading');
    }
    if (failedCount > 0) {
      parts.add('$failedCount failed');
    }
    if (staleUploadingCount > 0) {
      parts.add('$staleUploadingCount stale');
    }
    if (terminalCount > 0) {
      parts.add('$terminalCount complete');
    }

    return parts.isEmpty ? healthLabel : parts.join(', ');
  }

  DateTime? _oldest(Iterable<DateTime> timestamps) {
    DateTime? oldest;
    for (final timestamp in timestamps) {
      if (oldest == null || timestamp.isBefore(oldest)) {
        oldest = timestamp;
      }
    }

    return oldest;
  }
}
