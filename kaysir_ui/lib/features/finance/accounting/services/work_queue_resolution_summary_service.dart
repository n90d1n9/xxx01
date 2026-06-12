import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_state.dart';
import '../models/work_queue_resolution_summary.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'accounting_workspace_work_queue_clearance_action_sync.dart';
import 'work_queue_resolution_gate_service.dart';

class AccountingWorkspaceWorkQueueResolutionSummaryService {
  const AccountingWorkspaceWorkQueueResolutionSummaryService();

  static const _clearanceActionSync =
      AccountingWorkspaceWorkQueueClearanceActionSync();
  static const _resolutionGateService =
      AccountingWorkspaceWorkQueueResolutionGateService();

  AccountingWorkspaceWorkQueueResolutionSummary summarize({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required Map<String, AccountingWorkspaceWorkQueueDetail> detailsByQueueId,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
    Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
        evidenceReadinessByQueueId =
        const {},
  }) {
    var queueCount = 0;
    var clearedQueueCount = 0;
    var readyToClearQueueCount = 0;
    var blockedQueueCount = 0;
    var waitingQueueCount = 0;
    final candidates = <_ResolutionNextActionCandidate>[];

    for (final queue in queues) {
      queueCount += 1;

      final resolution = _resolveQueue(
        queue: queue,
        detail: detailsByQueueId[queue.id],
        actionState: actionStates[queue.id],
        reviewerSignOffState: reviewerSignOffStates[queue.id],
        resolutionState: resolutionStates[queue.id],
        evidenceReadiness: evidenceReadinessByQueueId[queue.id],
      );

      if (resolution.isCleared) {
        clearedQueueCount += 1;
        continue;
      }

      if (resolution.canClear) {
        readyToClearQueueCount += 1;
        final candidate = _candidateFor(queue: queue, resolution: resolution);
        if (candidate != null) candidates.add(candidate);
        continue;
      }

      if (resolution.hasBlockers) {
        blockedQueueCount += 1;
        final candidate = _candidateFor(queue: queue, resolution: resolution);
        if (candidate != null) candidates.add(candidate);
        continue;
      }

      waitingQueueCount += 1;
      final candidate = _candidateFor(queue: queue, resolution: resolution);
      if (candidate != null) candidates.add(candidate);
    }

    candidates.sort(_compareResolutionCandidates);

    return AccountingWorkspaceWorkQueueResolutionSummary(
      queueCount: queueCount,
      clearedQueueCount: clearedQueueCount,
      readyToClearQueueCount: readyToClearQueueCount,
      blockedQueueCount: blockedQueueCount,
      waitingQueueCount: waitingQueueCount,
      nextAction: candidates.isEmpty ? null : candidates.first.toNextAction(),
    );
  }

  AccountingWorkspaceWorkQueueResolutionNextAction? nextActionFor({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required AccountingWorkspaceWorkQueueResolutionFilter filter,
    required Map<String, AccountingWorkspaceWorkQueueDetail> detailsByQueueId,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
    Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
        evidenceReadinessByQueueId =
        const {},
  }) {
    final candidates = <_ResolutionNextActionCandidate>[];

    for (final queue in queues) {
      final resolution = _resolveQueue(
        queue: queue,
        detail: detailsByQueueId[queue.id],
        actionState: actionStates[queue.id],
        reviewerSignOffState: reviewerSignOffStates[queue.id],
        resolutionState: resolutionStates[queue.id],
        evidenceReadiness: evidenceReadinessByQueueId[queue.id],
      );
      if (!_matchesResolutionFilter(resolution, filter)) continue;

      final candidate = _candidateFor(queue: queue, resolution: resolution);
      if (candidate != null) candidates.add(candidate);
    }

    candidates.sort(_compareResolutionCandidates);

    return candidates.isEmpty ? null : candidates.first.toNextAction();
  }

  List<AccountingWorkspaceWorkQueueResolutionBriefItem> briefItemsFor({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required AccountingWorkspaceWorkQueueResolutionFilter filter,
    required Map<String, AccountingWorkspaceWorkQueueDetail> detailsByQueueId,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
    Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
        evidenceReadinessByQueueId =
        const {},
    int limit = 3,
  }) {
    if (limit <= 0) {
      return const <AccountingWorkspaceWorkQueueResolutionBriefItem>[];
    }

    final candidates = <_ResolutionBriefItemCandidate>[];

    for (final queue in queues) {
      final resolution = _resolveQueue(
        queue: queue,
        detail: detailsByQueueId[queue.id],
        actionState: actionStates[queue.id],
        reviewerSignOffState: reviewerSignOffStates[queue.id],
        resolutionState: resolutionStates[queue.id],
        evidenceReadiness: evidenceReadinessByQueueId[queue.id],
      );
      if (!_matchesResolutionFilter(resolution, filter)) continue;

      final candidate = _briefItemCandidateFor(
        queue: queue,
        resolution: resolution,
        includeCleared:
            filter == AccountingWorkspaceWorkQueueResolutionFilter.cleared,
      );
      if (candidate != null) candidates.add(candidate);
    }

    candidates.sort(_compareBriefItemCandidates);

    return List<AccountingWorkspaceWorkQueueResolutionBriefItem>.unmodifiable([
      for (var index = 0; index < candidates.take(limit).length; index++)
        candidates[index].toBriefItem(rank: index + 1),
    ]);
  }

  List<AccountingWorkspaceWorkQueue> filterByResolution({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required AccountingWorkspaceWorkQueueResolutionFilter filter,
    required Map<String, AccountingWorkspaceWorkQueueDetail> detailsByQueueId,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
    Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
        evidenceReadinessByQueueId =
        const {},
  }) {
    if (filter.isDefault) {
      return List<AccountingWorkspaceWorkQueue>.unmodifiable(queues);
    }

    return List<AccountingWorkspaceWorkQueue>.unmodifiable([
      for (final queue in queues)
        if (_matchesResolutionFilter(
          _resolveQueue(
            queue: queue,
            detail: detailsByQueueId[queue.id],
            actionState: actionStates[queue.id],
            reviewerSignOffState: reviewerSignOffStates[queue.id],
            resolutionState: resolutionStates[queue.id],
            evidenceReadiness: evidenceReadinessByQueueId[queue.id],
          ),
          filter,
        ))
          queue,
    ]);
  }

  Map<String, AccountingWorkspaceWorkQueueResolutionSnapshot> snapshotsFor({
    required Iterable<AccountingWorkspaceWorkQueue> queues,
    required Map<String, AccountingWorkspaceWorkQueueDetail> detailsByQueueId,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
    Map<String, AccountingWorkspaceWorkQueueEvidenceReadiness>
        evidenceReadinessByQueueId =
        const {},
  }) {
    return Map<
      String,
      AccountingWorkspaceWorkQueueResolutionSnapshot
    >.unmodifiable({
      for (final queue in queues)
        queue.id: _snapshotFor(
          queueId: queue.id,
          resolution: _resolveQueue(
            queue: queue,
            detail: detailsByQueueId[queue.id],
            actionState: actionStates[queue.id],
            reviewerSignOffState: reviewerSignOffStates[queue.id],
            resolutionState: resolutionStates[queue.id],
            evidenceReadiness: evidenceReadinessByQueueId[queue.id],
          ),
        ),
    });
  }

  _ResolvedQueueResolution _resolveQueue({
    required AccountingWorkspaceWorkQueue queue,
    required AccountingWorkspaceWorkQueueDetail? detail,
    required AccountingWorkspaceWorkQueueActivityActionState? actionState,
    required AccountingWorkspaceWorkQueueReviewerSignOffState?
    reviewerSignOffState,
    required AccountingWorkspaceWorkQueueResolutionState? resolutionState,
    required AccountingWorkspaceWorkQueueEvidenceReadiness? evidenceReadiness,
  }) {
    if (detail == null) {
      return const _ResolvedQueueResolution(
        isCleared: false,
        canClear: false,
        hasBlockers: false,
        statusLabel: 'Waiting',
        actionLabel: 'Open queue detail',
      );
    }

    final effectiveActionState =
        actionState ??
        AccountingWorkspaceWorkQueueActivityActionState(queueId: queue.id);
    final effectiveReviewerSignOffState =
        reviewerSignOffState ??
        AccountingWorkspaceWorkQueueReviewerSignOffState(queueId: queue.id);
    final effectiveResolutionState =
        resolutionState ??
        AccountingWorkspaceWorkQueueResolutionState(queueId: queue.id);
    final clearanceChecklist = _clearanceActionSync.sync(
      checklist: detail.clearanceChecklist,
      actionState: effectiveActionState,
      reviewerSignOffState: effectiveReviewerSignOffState,
      evidenceReadiness: evidenceReadiness,
    );
    final gate = _resolutionGateService.resolve(
      clearanceChecklist: clearanceChecklist,
      reviewerSignOffState: effectiveReviewerSignOffState,
      resolutionState: effectiveResolutionState,
      evidenceReadiness: evidenceReadiness,
    );

    return _ResolvedQueueResolution(
      isCleared: gate.isCleared,
      canClear: gate.canClear,
      hasBlockers: gate.hasBlockers,
      statusLabel: gate.statusLabel,
      actionLabel: gate.nextActionLabel,
    );
  }
}

AccountingWorkspaceWorkQueueResolutionSnapshot _snapshotFor({
  required String queueId,
  required _ResolvedQueueResolution resolution,
}) {
  return AccountingWorkspaceWorkQueueResolutionSnapshot(
    queueId: queueId,
    status: _snapshotStatusFor(resolution),
    statusLabel: resolution.statusLabel,
    actionLabel: resolution.actionLabel,
  );
}

AccountingWorkspaceWorkQueueResolutionSnapshotStatus _snapshotStatusFor(
  _ResolvedQueueResolution resolution,
) {
  if (resolution.isCleared) {
    return AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared;
  }
  if (resolution.canClear) {
    return AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready;
  }
  if (resolution.hasBlockers) {
    return AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked;
  }

  return AccountingWorkspaceWorkQueueResolutionSnapshotStatus.waiting;
}

_ResolutionNextActionCandidate? _candidateFor({
  required AccountingWorkspaceWorkQueue queue,
  required _ResolvedQueueResolution resolution,
}) {
  if (resolution.isCleared) return null;

  final statusRank =
      resolution.canClear
          ? 4
          : resolution.hasBlockers
          ? 3
          : 2;

  return _ResolutionNextActionCandidate(
    queue: queue,
    statusLabel: resolution.statusLabel,
    actionLabel: resolution.actionLabel,
    priorityScore: _queuePriorityScore(queue, statusRank: statusRank),
  );
}

_ResolutionBriefItemCandidate? _briefItemCandidateFor({
  required AccountingWorkspaceWorkQueue queue,
  required _ResolvedQueueResolution resolution,
  required bool includeCleared,
}) {
  if (resolution.isCleared && !includeCleared) return null;

  final statusRank =
      resolution.isCleared
          ? 1
          : resolution.canClear
          ? 4
          : resolution.hasBlockers
          ? 3
          : 2;

  return _ResolutionBriefItemCandidate(
    queue: queue,
    statusLabel: resolution.statusLabel,
    actionLabel: resolution.actionLabel,
    priorityScore: _queuePriorityScore(queue, statusRank: statusRank),
  );
}

bool _matchesResolutionFilter(
  _ResolvedQueueResolution resolution,
  AccountingWorkspaceWorkQueueResolutionFilter filter,
) {
  switch (filter) {
    case AccountingWorkspaceWorkQueueResolutionFilter.all:
      return true;
    case AccountingWorkspaceWorkQueueResolutionFilter.ready:
      return resolution.canClear;
    case AccountingWorkspaceWorkQueueResolutionFilter.blocked:
      return !resolution.isCleared &&
          !resolution.canClear &&
          resolution.hasBlockers;
    case AccountingWorkspaceWorkQueueResolutionFilter.open:
      return !resolution.isCleared;
    case AccountingWorkspaceWorkQueueResolutionFilter.cleared:
      return resolution.isCleared;
  }
}

class _ResolvedQueueResolution {
  const _ResolvedQueueResolution({
    required this.isCleared,
    required this.canClear,
    required this.hasBlockers,
    required this.statusLabel,
    required this.actionLabel,
  });

  final bool isCleared;
  final bool canClear;
  final bool hasBlockers;
  final String statusLabel;
  final String actionLabel;
}

int _queuePriorityScore(
  AccountingWorkspaceWorkQueue queue, {
  required int statusRank,
}) {
  return statusRank * 10000 +
      _severityRank(queue.severity) * 1000 +
      _slaRank(queue.slaStatus) * 100 +
      queue.count;
}

int _severityRank(AccountingWorkspaceWorkQueueSeverity severity) {
  switch (severity) {
    case AccountingWorkspaceWorkQueueSeverity.critical:
      return 3;
    case AccountingWorkspaceWorkQueueSeverity.warning:
      return 2;
    case AccountingWorkspaceWorkQueueSeverity.info:
      return 1;
  }
}

int _slaRank(AccountingWorkspaceWorkQueueSlaStatus status) {
  switch (status) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return 3;
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 2;
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return 1;
  }
}

int _compareResolutionCandidates(
  _ResolutionNextActionCandidate left,
  _ResolutionNextActionCandidate right,
) {
  final priorityComparison = right.priorityScore.compareTo(left.priorityScore);
  if (priorityComparison != 0) return priorityComparison;

  return left.queue.title.compareTo(right.queue.title);
}

int _compareBriefItemCandidates(
  _ResolutionBriefItemCandidate left,
  _ResolutionBriefItemCandidate right,
) {
  final priorityComparison = right.priorityScore.compareTo(left.priorityScore);
  if (priorityComparison != 0) return priorityComparison;

  return left.queue.title.compareTo(right.queue.title);
}

class _ResolutionNextActionCandidate {
  const _ResolutionNextActionCandidate({
    required this.queue,
    required this.statusLabel,
    required this.actionLabel,
    required this.priorityScore,
  });

  final AccountingWorkspaceWorkQueue queue;
  final String statusLabel;
  final String actionLabel;
  final int priorityScore;

  AccountingWorkspaceWorkQueueResolutionNextAction toNextAction() {
    return AccountingWorkspaceWorkQueueResolutionNextAction(
      queueId: queue.id,
      title: queue.title,
      statusLabel: statusLabel,
      actionLabel: actionLabel,
      ownerLabel: queue.ownerLabel,
      dueLabel: queue.dueLabel,
    );
  }
}

class _ResolutionBriefItemCandidate {
  const _ResolutionBriefItemCandidate({
    required this.queue,
    required this.statusLabel,
    required this.actionLabel,
    required this.priorityScore,
  });

  final AccountingWorkspaceWorkQueue queue;
  final String statusLabel;
  final String actionLabel;
  final int priorityScore;

  AccountingWorkspaceWorkQueueResolutionBriefItem toBriefItem({
    required int rank,
  }) {
    return AccountingWorkspaceWorkQueueResolutionBriefItem(
      rank: rank,
      queueId: queue.id,
      title: queue.title,
      statusLabel: statusLabel,
      actionLabel: actionLabel,
      ownerLabel: queue.ownerLabel,
      dueLabel: queue.dueLabel,
    );
  }
}
