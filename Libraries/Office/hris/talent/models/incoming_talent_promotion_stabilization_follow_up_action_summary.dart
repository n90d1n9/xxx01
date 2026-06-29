import 'incoming_talent_promotion_stabilization_follow_up_action.dart';

/// Aggregates promotion stabilization follow-up actions into work signals.
class IncomingTalentPromotionStabilizationFollowUpActionSummary {
  final int totalCount;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final int escalatedCount;
  final int cancelledCount;
  final int criticalCount;
  final int dueSoonCount;
  final int attentionCount;
  final double averageProgress;
  final String nextAction;

  const IncomingTalentPromotionStabilizationFollowUpActionSummary({
    required this.totalCount,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.escalatedCount,
    required this.cancelledCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.attentionCount,
    required this.averageProgress,
    required this.nextAction,
  });

  factory IncomingTalentPromotionStabilizationFollowUpActionSummary.fromActions({
    required List<IncomingTalentPromotionStabilizationFollowUpAction> actions,
    required DateTime asOfDate,
  }) {
    final openCount = _countStatus(
      actions,
      IncomingTalentPromotionStabilizationFollowUpStatus.open,
    );
    final inProgressCount = _countStatus(
      actions,
      IncomingTalentPromotionStabilizationFollowUpStatus.inProgress,
    );
    final resolvedCount = _countStatus(
      actions,
      IncomingTalentPromotionStabilizationFollowUpStatus.resolved,
    );
    final escalatedCount = _countStatus(
      actions,
      IncomingTalentPromotionStabilizationFollowUpStatus.escalated,
    );
    final cancelledCount = _countStatus(
      actions,
      IncomingTalentPromotionStabilizationFollowUpStatus.cancelled,
    );
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final dueSoonCount =
        actions
            .where(
              (action) =>
                  !action.isClosed && !action.dueDate.isAfter(dueThreshold),
            )
            .length;
    final progressTotal = actions.fold<double>(
      0,
      (total, action) => total + action.progressRatio,
    );

    return IncomingTalentPromotionStabilizationFollowUpActionSummary(
      totalCount: actions.length,
      openCount: openCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      escalatedCount: escalatedCount,
      cancelledCount: cancelledCount,
      criticalCount:
          actions
              .where(
                (action) =>
                    action.priority ==
                    IncomingTalentPromotionStabilizationFollowUpPriority
                        .critical,
              )
              .length,
      dueSoonCount: dueSoonCount,
      attentionCount: actions.where((action) => action.needsAttention).length,
      averageProgress: actions.isEmpty ? 0 : progressTotal / actions.length,
      nextAction: _nextAction(
        totalCount: actions.length,
        escalatedCount: escalatedCount,
        dueSoonCount: dueSoonCount,
        openCount: openCount,
        inProgressCount: inProgressCount,
      ),
    );
  }
}

const emptyIncomingTalentPromotionStabilizationFollowUpActionSummary =
    IncomingTalentPromotionStabilizationFollowUpActionSummary(
      totalCount: 0,
      openCount: 0,
      inProgressCount: 0,
      resolvedCount: 0,
      escalatedCount: 0,
      cancelledCount: 0,
      criticalCount: 0,
      dueSoonCount: 0,
      attentionCount: 0,
      averageProgress: 0,
      nextAction: 'Create follow-up actions for risky promotion reviews.',
    );

int _countStatus(
  List<IncomingTalentPromotionStabilizationFollowUpAction> actions,
  IncomingTalentPromotionStabilizationFollowUpStatus status,
) {
  return actions.where((action) => action.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int escalatedCount,
  required int dueSoonCount,
  required int openCount,
  required int inProgressCount,
}) {
  if (totalCount == 0) {
    return 'Create follow-up actions for risky promotion reviews.';
  }
  if (escalatedCount > 0) {
    return 'Resolve $escalatedCount escalated promotion follow-ups.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount promotion follow-ups due soon.';
  }
  if (openCount > 0) {
    return 'Start $openCount open promotion follow-ups.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount promotion follow-ups in progress.';
  }
  return 'Archive resolved promotion stabilization follow-ups.';
}
