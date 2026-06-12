import 'incoming_talent_promotion_decision.dart';

/// Aggregates promotion decisions into implementation metrics.
class IncomingTalentPromotionDecisionSummary {
  final int totalCount;
  final int promoteNowCount;
  final int trialCount;
  final int deferredCount;
  final int approvedCount;
  final int routedCount;
  final int implementedCount;
  final int attentionCount;
  final int dueSoonCount;
  final double averageImplementationProgress;
  final String nextAction;

  const IncomingTalentPromotionDecisionSummary({
    required this.totalCount,
    required this.promoteNowCount,
    required this.trialCount,
    required this.deferredCount,
    required this.approvedCount,
    required this.routedCount,
    required this.implementedCount,
    required this.attentionCount,
    required this.dueSoonCount,
    required this.averageImplementationProgress,
    required this.nextAction,
  });

  factory IncomingTalentPromotionDecisionSummary.fromDecisions({
    required List<IncomingTalentPromotionDecision> decisions,
    required DateTime asOfDate,
  }) {
    final promoteNowCount = _countOutcome(
      decisions,
      IncomingTalentPromotionDecisionOutcome.promoteNow,
    );
    final trialCount = _countOutcome(
      decisions,
      IncomingTalentPromotionDecisionOutcome.promoteWithTrial,
    );
    final deferredCount =
        decisions
            .where(
              (decision) =>
                  decision.outcome ==
                      IncomingTalentPromotionDecisionOutcome.deferPromotion ||
                  decision.outcome ==
                      IncomingTalentPromotionDecisionOutcome.retainInRole,
            )
            .length;
    final approvedCount = _countStatus(
      decisions,
      IncomingTalentPromotionDecisionStatus.approved,
    );
    final routedCount = _countStatus(
      decisions,
      IncomingTalentPromotionDecisionStatus.routed,
    );
    final implementedCount = _countStatus(
      decisions,
      IncomingTalentPromotionDecisionStatus.implemented,
    );
    final attentionCount =
        decisions.where((decision) => decision.needsAttention).length;
    final dueSoonCount =
        decisions
            .where(
              (decision) =>
                  !decision.isClosed &&
                  !decision.effectiveDate.isAfter(
                    asOfDate.add(const Duration(days: 14)),
                  ),
            )
            .length;
    final progressTotal = decisions.fold<double>(
      0,
      (total, decision) => total + decision.implementationProgress,
    );

    return IncomingTalentPromotionDecisionSummary(
      totalCount: decisions.length,
      promoteNowCount: promoteNowCount,
      trialCount: trialCount,
      deferredCount: deferredCount,
      approvedCount: approvedCount,
      routedCount: routedCount,
      implementedCount: implementedCount,
      attentionCount: attentionCount,
      dueSoonCount: dueSoonCount,
      averageImplementationProgress:
          decisions.isEmpty ? 0 : progressTotal / decisions.length,
      nextAction: _nextAction(
        totalCount: decisions.length,
        dueSoonCount: dueSoonCount,
        attentionCount: attentionCount,
        approvedCount: approvedCount,
        routedCount: routedCount,
        deferredCount: deferredCount,
      ),
    );
  }
}

int _countOutcome(
  List<IncomingTalentPromotionDecision> decisions,
  IncomingTalentPromotionDecisionOutcome outcome,
) {
  return decisions.where((decision) => decision.outcome == outcome).length;
}

int _countStatus(
  List<IncomingTalentPromotionDecision> decisions,
  IncomingTalentPromotionDecisionStatus status,
) {
  return decisions.where((decision) => decision.status == status).length;
}

String _nextAction({
  required int totalCount,
  required int dueSoonCount,
  required int attentionCount,
  required int approvedCount,
  required int routedCount,
  required int deferredCount,
}) {
  if (totalCount == 0) {
    return 'Capture decisions for ready promotion packets.';
  }
  if (dueSoonCount > 0) {
    return 'Implement $dueSoonCount promotion decisions due soon.';
  }
  if (approvedCount > 0 || routedCount > 0) {
    return 'Route ${approvedCount + routedCount} promotion decisions to execution.';
  }
  if (deferredCount > 0 || attentionCount > 0) {
    return 'Resolve $attentionCount promotion decisions needing follow-up.';
  }
  return 'Monitor implemented promotion decisions.';
}
