class AccountingWorkspaceWorkQueueCloseReadiness {
  AccountingWorkspaceWorkQueueCloseReadiness({
    required this.queueCount,
    required this.totalItems,
    required this.releaseBlockerItems,
    required this.evidenceRequestItems,
    required this.postingGateItems,
    Iterable<AccountingWorkspaceWorkQueueCloseReadinessNextAction> actionPlan =
        const [],
  }) : actionPlan = List.unmodifiable(actionPlan);

  final int queueCount;
  final int totalItems;
  final int releaseBlockerItems;
  final int evidenceRequestItems;
  final int postingGateItems;
  final List<AccountingWorkspaceWorkQueueCloseReadinessNextAction> actionPlan;

  AccountingWorkspaceWorkQueueCloseReadinessNextAction? get nextAction {
    return actionPlan.isEmpty ? null : actionPlan.first;
  }

  bool get hasQueues => queueCount > 0;
  bool get hasReleaseBlockers => releaseBlockerItems > 0;
  bool get hasEvidenceRequests => evidenceRequestItems > 0;
  bool get hasPostingGates => postingGateItems > 0;
  bool get hasNextAction => nextAction != null;
  bool get hasActionPlan => actionPlan.isNotEmpty;
  int get actionPlanCount => actionPlan.length;

  int get readinessScore {
    if (!hasQueues || totalItems == 0) return 100;

    final blockerPenalty = _weightedPenalty(
      affectedItems: releaseBlockerItems,
      totalItems: totalItems,
      maxPenalty: 45,
    );
    final evidencePenalty = _weightedPenalty(
      affectedItems: evidenceRequestItems,
      totalItems: totalItems,
      maxPenalty: 30,
    );
    final postingPenalty = _weightedPenalty(
      affectedItems: postingGateItems,
      totalItems: totalItems,
      maxPenalty: 25,
    );

    final score = 100 - blockerPenalty - evidencePenalty - postingPenalty;
    final roundedScore = score.round();
    if (roundedScore < 0) return 0;
    if (roundedScore > 100) return 100;

    return roundedScore;
  }

  String get scoreLabel => '$readinessScore% ready';

  String get lockGateLabel {
    if (readinessScore >= 90) return 'Ready for lock review';
    if (readinessScore >= 70) return 'Close watch';
    if (readinessScore >= 40) return 'Management review';
    return 'Lock blocked';
  }

  int get primaryDriverItemCount {
    switch (_primaryDriver) {
      case _CloseReadinessDriver.releaseBlockers:
        return releaseBlockerItems;
      case _CloseReadinessDriver.evidenceRequests:
        return evidenceRequestItems;
      case _CloseReadinessDriver.postingGates:
        return postingGateItems;
      case _CloseReadinessDriver.none:
        return 0;
    }
  }

  String get primaryDriverLabel {
    switch (_primaryDriver) {
      case _CloseReadinessDriver.releaseBlockers:
        return 'Release blockers';
      case _CloseReadinessDriver.evidenceRequests:
        return 'Evidence requests';
      case _CloseReadinessDriver.postingGates:
        return 'Posting gates';
      case _CloseReadinessDriver.none:
        return 'No active drivers';
    }
  }

  String get primaryDriverDetailLabel {
    switch (_primaryDriver) {
      case _CloseReadinessDriver.releaseBlockers:
        return '$primaryDriverItemCount items blocking release';
      case _CloseReadinessDriver.evidenceRequests:
        return '$primaryDriverItemCount items need owner follow-up';
      case _CloseReadinessDriver.postingGates:
        return '$primaryDriverItemCount items need posting review';
      case _CloseReadinessDriver.none:
        return 'No readiness pressure detected';
    }
  }

  String get statusLabel {
    if (hasReleaseBlockers) return 'Release blocked';
    if (hasEvidenceRequests || hasPostingGates) return 'Close attention';
    return 'Ready to monitor';
  }

  String get statusDetailLabel {
    return '$releaseBlockerItems blockers | '
        '$evidenceRequestItems evidence | '
        '$postingGateItems posting';
  }

  String get actionLabel {
    if (hasReleaseBlockers) {
      return 'Clear release blockers before close or reporting lock';
    }
    if (hasEvidenceRequests) {
      return 'Send evidence requests and monitor owner responses';
    }
    if (hasPostingGates) {
      return 'Review journal gates before period lock';
    }
    return 'Keep monitoring close readiness';
  }

  String get actionPlanBrief {
    final lines = [
      'Close readiness: $statusLabel ($scoreLabel)',
      'Lock gate: $lockGateLabel',
      'Primary driver: $primaryDriverLabel - $primaryDriverDetailLabel',
      'Counts: $statusDetailLabel',
      'Action: $actionLabel',
      if (hasActionPlan) ...[
        'Ranked actions:',
        ..._rankedActionLines(actionPlan),
      ] else
        'Ranked actions: none',
    ];

    return lines.join('\n');
  }

  _CloseReadinessDriver get _primaryDriver {
    if (!hasQueues || totalItems == 0) return _CloseReadinessDriver.none;

    final drivers = [
      _CloseReadinessDriverScore(
        driver: _CloseReadinessDriver.releaseBlockers,
        itemCount: releaseBlockerItems,
        penalty: _weightedPenalty(
          affectedItems: releaseBlockerItems,
          totalItems: totalItems,
          maxPenalty: 45,
        ),
      ),
      _CloseReadinessDriverScore(
        driver: _CloseReadinessDriver.evidenceRequests,
        itemCount: evidenceRequestItems,
        penalty: _weightedPenalty(
          affectedItems: evidenceRequestItems,
          totalItems: totalItems,
          maxPenalty: 30,
        ),
      ),
      _CloseReadinessDriverScore(
        driver: _CloseReadinessDriver.postingGates,
        itemCount: postingGateItems,
        penalty: _weightedPenalty(
          affectedItems: postingGateItems,
          totalItems: totalItems,
          maxPenalty: 25,
        ),
      ),
    ]..sort(_compareDriverScores);

    final topDriver = drivers.first;
    if (topDriver.itemCount == 0 || topDriver.penalty == 0) {
      return _CloseReadinessDriver.none;
    }

    return topDriver.driver;
  }
}

List<String> _rankedActionLines(
  List<AccountingWorkspaceWorkQueueCloseReadinessNextAction> actionPlan,
) {
  return actionPlan.map((action) => action.briefLabel).toList();
}

class AccountingWorkspaceWorkQueueCloseReadinessNextAction {
  const AccountingWorkspaceWorkQueueCloseReadinessNextAction({
    required this.rank,
    required this.queueId,
    required this.title,
    required this.urgencyLabel,
    required this.ownerLabel,
    required this.dueLabel,
    required this.reasonLabel,
  });

  final int rank;
  final String queueId;
  final String title;
  final String urgencyLabel;
  final String ownerLabel;
  final String dueLabel;
  final String reasonLabel;

  String get rankLabel => '#$rank';
  String get detailLabel => '$reasonLabel · $ownerLabel · $dueLabel';
  String get previewLabel => '$rankLabel $urgencyLabel · $detailLabel';

  String get briefLabel {
    return '$rank. $title - $urgencyLabel - $reasonLabel - '
        '$ownerLabel - $dueLabel';
  }
}

enum _CloseReadinessDriver {
  releaseBlockers,
  evidenceRequests,
  postingGates,
  none,
}

class _CloseReadinessDriverScore {
  const _CloseReadinessDriverScore({
    required this.driver,
    required this.itemCount,
    required this.penalty,
  });

  final _CloseReadinessDriver driver;
  final int itemCount;
  final double penalty;
}

int _compareDriverScores(
  _CloseReadinessDriverScore a,
  _CloseReadinessDriverScore b,
) {
  final penaltyComparison = b.penalty.compareTo(a.penalty);
  if (penaltyComparison != 0) return penaltyComparison;

  return b.itemCount.compareTo(a.itemCount);
}

double _weightedPenalty({
  required int affectedItems,
  required int totalItems,
  required int maxPenalty,
}) {
  if (totalItems <= 0 || affectedItems <= 0) return 0;

  return (affectedItems / totalItems) * maxPenalty;
}
