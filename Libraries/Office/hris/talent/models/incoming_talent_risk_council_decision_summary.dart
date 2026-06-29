import 'incoming_talent_risk_council_decision.dart';

/// Aggregate council decision progress and the next governance action.
class IncomingTalentRiskCouncilDecisionSummary {
  final int totalDecisions;
  final int approvedCount;
  final int assignedCount;
  final int monitorCount;
  final int escalatedCount;
  final int closedCount;
  final int attentionCount;
  final int promotionResolutionReviewCount;
  final String nextAction;

  const IncomingTalentRiskCouncilDecisionSummary({
    required this.totalDecisions,
    required this.approvedCount,
    required this.assignedCount,
    required this.monitorCount,
    required this.escalatedCount,
    required this.closedCount,
    required this.attentionCount,
    required this.promotionResolutionReviewCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilDecisionSummary.fromDecisions(
    List<IncomingTalentRiskCouncilDecision> decisions,
  ) {
    final approvedCount = _countOutcome(
      decisions,
      IncomingTalentRiskCouncilDecisionOutcome.approveActionPlan,
    );
    final assignedCount = _countOutcome(
      decisions,
      IncomingTalentRiskCouncilDecisionOutcome.assignOwner,
    );
    final monitorCount = _countOutcome(
      decisions,
      IncomingTalentRiskCouncilDecisionOutcome.monitorNextCouncil,
    );
    final escalatedCount = _countOutcome(
      decisions,
      IncomingTalentRiskCouncilDecisionOutcome.escalatePeopleBoard,
    );
    final closedCount = _countOutcome(
      decisions,
      IncomingTalentRiskCouncilDecisionOutcome.closeRisk,
    );
    final attentionCount =
        decisions.where((decision) => decision.needsAttention).length;
    final promotionResolutionReviewCount =
        decisions
            .where((decision) => decision.isPromotionResolutionReview)
            .length;

    return IncomingTalentRiskCouncilDecisionSummary(
      totalDecisions: decisions.length,
      approvedCount: approvedCount,
      assignedCount: assignedCount,
      monitorCount: monitorCount,
      escalatedCount: escalatedCount,
      closedCount: closedCount,
      attentionCount: attentionCount,
      promotionResolutionReviewCount: promotionResolutionReviewCount,
      nextAction: _nextAction(
        totalDecisions: decisions.length,
        escalatedCount: escalatedCount,
        assignedCount: assignedCount,
        monitorCount: monitorCount,
        attentionCount: attentionCount,
        promotionResolutionReviewCount: promotionResolutionReviewCount,
      ),
    );
  }
}

int _countOutcome(
  List<IncomingTalentRiskCouncilDecision> decisions,
  IncomingTalentRiskCouncilDecisionOutcome outcome,
) {
  return decisions.where((decision) => decision.outcome == outcome).length;
}

String _nextAction({
  required int totalDecisions,
  required int escalatedCount,
  required int assignedCount,
  required int monitorCount,
  required int attentionCount,
  required int promotionResolutionReviewCount,
}) {
  if (totalDecisions == 0) {
    return 'Record decisions for queued talent risks.';
  }
  if (escalatedCount > 0) {
    return 'Escalate $escalatedCount talent council ${_plural(escalatedCount, 'decision')} to people board.';
  }
  if (assignedCount > 0) {
    return 'Confirm $assignedCount accountable risk ${_plural(assignedCount, 'owner')}.';
  }
  if (promotionResolutionReviewCount > 0) {
    return 'Track $promotionResolutionReviewCount promotion resolution council ${_plural(promotionResolutionReviewCount, 'decision')} through stabilization evidence.';
  }
  if (attentionCount > 0) {
    return 'Track $attentionCount council ${_plural(attentionCount, 'decision')} with follow-up risk.';
  }
  if (monitorCount > 0) {
    return 'Monitor $monitorCount council ${_plural(monitorCount, 'decision')} at next council.';
  }
  return 'Talent council decisions are current.';
}

String _plural(int count, String noun) {
  return count == 1 ? noun : '${noun}s';
}
