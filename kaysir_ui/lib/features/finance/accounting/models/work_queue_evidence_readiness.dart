import 'accounting_workspace_work_queue_evidence_request.dart';
import 'work_queue_evidence_link.dart';
import 'work_queue_evidence_review_state.dart';

/// Evidence support status for accounting work queue clearance readiness.
enum AccountingWorkspaceWorkQueueEvidenceReadinessStatus {
  missing,
  reviewNeeded,
  rework,
  partial,
  ready,
}

/// Coverage summary comparing requested evidence items with attached links.
class AccountingWorkspaceWorkQueueEvidenceReadiness {
  AccountingWorkspaceWorkQueueEvidenceReadiness({
    required this.queueId,
    required this.requestedItemCount,
    required this.linkedEvidenceCount,
    required this.acceptedEvidenceCount,
    required this.pendingReviewCount,
    required this.reworkEvidenceCount,
    required this.status,
    required Iterable<String> remainingRequestedItems,
  }) : remainingRequestedItems = List<String>.unmodifiable(
         remainingRequestedItems,
       );

  factory AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest({
    required String queueId,
    required AccountingWorkspaceWorkQueueEvidenceRequest request,
    required Iterable<AccountingWorkspaceWorkQueueEvidenceLink> links,
    Iterable<AccountingWorkspaceWorkQueueEvidenceReviewState> reviewStates =
        const [],
  }) {
    final requestedItems = [
      for (final item in request.requestedItems)
        if (item.trim().isNotEmpty) item.trim(),
    ];
    final persistedLinks = [
      for (final link in links)
        if (link.isPersistable) link,
    ];
    final reviewStateByLinkId = {
      for (final state in reviewStates)
        if (state.queueId == queueId && state.linkId.trim().isNotEmpty)
          state.linkId: state,
    };
    final linkedEvidenceCount = persistedLinks.length;
    final acceptedEvidenceCount =
        persistedLinks
            .where((link) => reviewStateByLinkId[link.id]?.isAccepted ?? false)
            .length;
    final reworkEvidenceCount =
        persistedLinks
            .where((link) => reviewStateByLinkId[link.id]?.needsRework ?? false)
            .length;
    final pendingReviewCount =
        linkedEvidenceCount - acceptedEvidenceCount - reworkEvidenceCount;
    final requestedItemCount = requestedItems.length;
    final coveredCount =
        acceptedEvidenceCount > requestedItemCount
            ? requestedItemCount
            : acceptedEvidenceCount;
    final remainingRequestedItems = requestedItems.skip(coveredCount);

    return AccountingWorkspaceWorkQueueEvidenceReadiness(
      queueId: queueId,
      requestedItemCount: requestedItemCount,
      linkedEvidenceCount: linkedEvidenceCount,
      acceptedEvidenceCount: acceptedEvidenceCount,
      pendingReviewCount: pendingReviewCount,
      reworkEvidenceCount: reworkEvidenceCount,
      status: _statusFor(
        requestedItemCount: requestedItemCount,
        linkedEvidenceCount: linkedEvidenceCount,
        acceptedEvidenceCount: acceptedEvidenceCount,
        pendingReviewCount: pendingReviewCount,
        reworkEvidenceCount: reworkEvidenceCount,
      ),
      remainingRequestedItems: remainingRequestedItems,
    );
  }

  final String queueId;
  final int requestedItemCount;
  final int linkedEvidenceCount;
  final int acceptedEvidenceCount;
  final int pendingReviewCount;
  final int reworkEvidenceCount;
  final AccountingWorkspaceWorkQueueEvidenceReadinessStatus status;
  final List<String> remainingRequestedItems;

  int get coveredItemCount {
    if (acceptedEvidenceCount > requestedItemCount) return requestedItemCount;

    return acceptedEvidenceCount;
  }

  int get remainingItemCount {
    final remaining = requestedItemCount - coveredItemCount;
    if (remaining < 0) return 0;

    return remaining;
  }

  double get coverageRatio {
    if (requestedItemCount == 0) return 1;

    return coveredItemCount / requestedItemCount;
  }

  String get statusLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
        return 'Evidence missing';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
        return 'Review needed';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
        return 'Rework needed';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
        return 'Evidence partial';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
        return 'Evidence ready';
    }
  }

  String get coverageLabel {
    if (requestedItemCount == 0) return 'No requested items';

    return '$coveredItemCount/$requestedItemCount accepted';
  }

  String get detailLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
        return 'No support links attached for the requested evidence.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
        return '$pendingReviewCount attached link${pendingReviewCount == 1 ? '' : 's'} need review before sign-off.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
        return '$reworkEvidenceCount evidence link${reworkEvidenceCount == 1 ? '' : 's'} need owner rework.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
        return '$remainingItemCount requested item${remainingItemCount == 1 ? '' : 's'} still need accepted support.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
        return 'Accepted links cover the requested evidence count.';
    }
  }

  String get nextActionLabel {
    switch (status) {
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
        return 'Attach the first evidence link before reviewer sign-off.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
        return 'Review attached evidence and accept or return it for rework.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
        return 'Send rework comments to the owner before reviewer sign-off.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
        return 'Accept remaining support or document why one accepted link covers multiple items.';
      case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
        return 'Mark receipt when accepted support is complete.';
    }
  }

  String briefFor(String queueTitle) {
    final lines = [
      'Evidence readiness: $queueTitle',
      'Status: $statusLabel',
      'Coverage: $coverageLabel',
      'Attached evidence: $linkedEvidenceCount',
      'Accepted evidence: $acceptedEvidenceCount',
      'Pending review: $pendingReviewCount',
      'Needs rework: $reworkEvidenceCount',
      'Next action: $nextActionLabel',
      if (remainingRequestedItems.isNotEmpty) ...[
        'Remaining requested items:',
        for (final item in remainingRequestedItems) '- $item',
      ],
    ];

    return lines.join('\n');
  }
}

AccountingWorkspaceWorkQueueEvidenceReadinessStatus _statusFor({
  required int requestedItemCount,
  required int linkedEvidenceCount,
  required int acceptedEvidenceCount,
  required int pendingReviewCount,
  required int reworkEvidenceCount,
}) {
  if (requestedItemCount == 0 || acceptedEvidenceCount >= requestedItemCount) {
    return AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready;
  }
  if (linkedEvidenceCount == 0) {
    return AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing;
  }
  if (reworkEvidenceCount > 0) {
    return AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework;
  }
  if (pendingReviewCount > 0 && acceptedEvidenceCount == 0) {
    return AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded;
  }

  return AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial;
}
