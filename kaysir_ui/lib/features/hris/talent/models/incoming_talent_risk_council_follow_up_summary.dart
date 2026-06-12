import 'incoming_talent_risk_council_follow_up.dart';

/// Aggregate execution health for council follow-ups and next operator action.
class IncomingTalentRiskCouncilFollowUpSummary {
  final int totalCount;
  final int plannedCount;
  final int inProgressCount;
  final int blockedCount;
  final int escalatedCount;
  final int completedCount;
  final int dueSoonCount;
  final int overdueCount;
  final int attentionCount;
  final int promotionResolutionReviewCount;
  final String nextAction;

  const IncomingTalentRiskCouncilFollowUpSummary({
    required this.totalCount,
    required this.plannedCount,
    required this.inProgressCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.completedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.promotionResolutionReviewCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilFollowUpSummary.fromFollowUps({
    required List<IncomingTalentRiskCouncilFollowUp> followUps,
    required DateTime asOfDate,
  }) {
    final plannedCount = _countByStatus(
      followUps,
      IncomingTalentRiskCouncilFollowUpStatus.planned,
    );
    final inProgressCount = _countByStatus(
      followUps,
      IncomingTalentRiskCouncilFollowUpStatus.inProgress,
    );
    final blockedCount = _countByStatus(
      followUps,
      IncomingTalentRiskCouncilFollowUpStatus.blocked,
    );
    final escalatedCount = _countByStatus(
      followUps,
      IncomingTalentRiskCouncilFollowUpStatus.escalated,
    );
    final completedCount = _countByStatus(
      followUps,
      IncomingTalentRiskCouncilFollowUpStatus.completed,
    );
    final dueSoonCount =
        followUps.where((followUp) => followUp.isDueSoon(asOfDate)).length;
    final overdueCount =
        followUps.where((followUp) => followUp.isOverdue(asOfDate)).length;
    final attentionCount =
        followUps.where((followUp) => followUp.needsAttention).length;
    final promotionResolutionReviewCount =
        followUps
            .where((followUp) => followUp.isPromotionResolutionReview)
            .length;

    return IncomingTalentRiskCouncilFollowUpSummary(
      totalCount: followUps.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      blockedCount: blockedCount,
      escalatedCount: escalatedCount,
      completedCount: completedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      attentionCount: attentionCount,
      promotionResolutionReviewCount: promotionResolutionReviewCount,
      nextAction: _nextAction(
        totalCount: followUps.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        blockedCount: blockedCount,
        escalatedCount: escalatedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
        promotionResolutionReviewCount: promotionResolutionReviewCount,
      ),
    );
  }
}

int _countByStatus(
  List<IncomingTalentRiskCouncilFollowUp> followUps,
  IncomingTalentRiskCouncilFollowUpStatus status,
) {
  return followUps.where((followUp) => followUp.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int plannedCount,
  required int inProgressCount,
  required int blockedCount,
  required int escalatedCount,
  required int dueSoonCount,
  required int overdueCount,
  required int promotionResolutionReviewCount,
}) {
  if (totalCount == 0) return 'Create follow-ups from risk council decisions.';
  if (blockedCount > 0) {
    return 'Unblock $blockedCount risk council ${_plural(blockedCount, 'follow-up')}.';
  }
  if (escalatedCount > 0) {
    return 'Track $escalatedCount escalated risk ${_plural(escalatedCount, 'follow-up')} with people leadership.';
  }
  if (overdueCount > 0) {
    return 'Close $overdueCount overdue risk ${_plural(overdueCount, 'follow-up')}.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount risk council ${_plural(dueSoonCount, 'follow-up')} due soon.';
  }
  if (promotionResolutionReviewCount > 0) {
    return 'Close the loop on $promotionResolutionReviewCount promotion stabilization ${_plural(promotionResolutionReviewCount, 'follow-up')}.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned risk ${_plural(plannedCount, 'follow-up')}.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount risk ${_plural(inProgressCount, 'follow-up')} in progress.';
  }
  return 'Risk council follow-ups are complete.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
