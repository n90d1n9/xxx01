import 'work_queue_evidence_readiness.dart';

/// Summarizes evidence readiness across the work queues included in a close packet.
class AccountingWorkspaceWorkQueueClosePacketEvidenceSummary {
  const AccountingWorkspaceWorkQueueClosePacketEvidenceSummary({
    required this.queueCount,
    required this.readyQueueCount,
    required this.reviewNeededQueueCount,
    required this.reworkQueueCount,
    required this.partialQueueCount,
    required this.missingQueueCount,
    required this.requestedEvidenceCount,
    required this.linkedEvidenceCount,
    required this.acceptedEvidenceCount,
    required this.pendingReviewCount,
    required this.reworkEvidenceCount,
  });

  factory AccountingWorkspaceWorkQueueClosePacketEvidenceSummary.fromReadiness(
    Iterable<AccountingWorkspaceWorkQueueEvidenceReadiness> readinessItems,
  ) {
    var queueCount = 0;
    var readyQueueCount = 0;
    var reviewNeededQueueCount = 0;
    var reworkQueueCount = 0;
    var partialQueueCount = 0;
    var missingQueueCount = 0;
    var requestedEvidenceCount = 0;
    var linkedEvidenceCount = 0;
    var acceptedEvidenceCount = 0;
    var pendingReviewCount = 0;
    var reworkEvidenceCount = 0;

    for (final readiness in readinessItems) {
      queueCount += 1;
      requestedEvidenceCount += readiness.requestedItemCount;
      linkedEvidenceCount += readiness.linkedEvidenceCount;
      acceptedEvidenceCount += readiness.acceptedEvidenceCount;
      pendingReviewCount += readiness.pendingReviewCount;
      reworkEvidenceCount += readiness.reworkEvidenceCount;

      switch (readiness.status) {
        case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
          readyQueueCount += 1;
        case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
          reviewNeededQueueCount += 1;
        case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
          reworkQueueCount += 1;
        case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
          partialQueueCount += 1;
        case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
          missingQueueCount += 1;
      }
    }

    return AccountingWorkspaceWorkQueueClosePacketEvidenceSummary(
      queueCount: queueCount,
      readyQueueCount: readyQueueCount,
      reviewNeededQueueCount: reviewNeededQueueCount,
      reworkQueueCount: reworkQueueCount,
      partialQueueCount: partialQueueCount,
      missingQueueCount: missingQueueCount,
      requestedEvidenceCount: requestedEvidenceCount,
      linkedEvidenceCount: linkedEvidenceCount,
      acceptedEvidenceCount: acceptedEvidenceCount,
      pendingReviewCount: pendingReviewCount,
      reworkEvidenceCount: reworkEvidenceCount,
    );
  }

  final int queueCount;
  final int readyQueueCount;
  final int reviewNeededQueueCount;
  final int reworkQueueCount;
  final int partialQueueCount;
  final int missingQueueCount;
  final int requestedEvidenceCount;
  final int linkedEvidenceCount;
  final int acceptedEvidenceCount;
  final int pendingReviewCount;
  final int reworkEvidenceCount;

  bool get hasQueues => queueCount > 0;

  bool get isFullyReady => hasQueues && readyQueueCount == queueCount;

  int get actionNeededQueueCount {
    return queueCount - readyQueueCount;
  }

  String get statusLabel {
    if (!hasQueues) return 'No evidence readiness';
    if (isFullyReady) return 'Evidence accepted';
    if (reworkQueueCount > 0) return 'Evidence rework needed';
    if (missingQueueCount > 0) return 'Evidence missing';
    if (reviewNeededQueueCount > 0) return 'Evidence review needed';

    return 'Evidence partial';
  }

  String get coverageLabel {
    if (requestedEvidenceCount == 0) return 'No requested evidence';

    return '$acceptedEvidenceCount/$requestedEvidenceCount accepted';
  }

  String get queueBreakdownLabel {
    return '$readyQueueCount ready | '
        '$reviewNeededQueueCount review | '
        '$reworkQueueCount rework | '
        '$partialQueueCount partial | '
        '$missingQueueCount missing';
  }

  String get linkReviewLabel {
    return '$linkedEvidenceCount linked | '
        '$pendingReviewCount pending review | '
        '$reworkEvidenceCount rework';
  }
}
