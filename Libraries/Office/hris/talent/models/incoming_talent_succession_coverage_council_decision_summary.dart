import 'incoming_talent_succession_coverage_council_decision.dart';

class IncomingTalentSuccessionCoverageCouncilDecisionSummary {
  final int totalDecisions;
  final int recoveryApprovedCount;
  final int sponsorAssignedCount;
  final int closureValidatedCount;
  final int deferredCount;
  final int escalatedCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentSuccessionCoverageCouncilDecisionSummary({
    required this.totalDecisions,
    required this.recoveryApprovedCount,
    required this.sponsorAssignedCount,
    required this.closureValidatedCount,
    required this.deferredCount,
    required this.escalatedCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageCouncilDecisionSummary.fromDecisions(
    List<IncomingTalentSuccessionCoverageCouncilDecision> decisions,
  ) {
    final recoveryApprovedCount = _countOutcome(
      decisions,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .approveRecoveryPlan,
    );
    final sponsorAssignedCount = _countOutcome(
      decisions,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .assignExecutiveSponsor,
    );
    final closureValidatedCount = _countOutcome(
      decisions,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome.validateClosure,
    );
    final deferredCount = _countOutcome(
      decisions,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome.deferToNextCouncil,
    );
    final escalatedCount = _countOutcome(
      decisions,
      IncomingTalentSuccessionCoverageCouncilDecisionOutcome
          .escalateToPeopleBoard,
    );
    final attentionCount =
        decisions.where((decision) => decision.needsAttention).length;

    return IncomingTalentSuccessionCoverageCouncilDecisionSummary(
      totalDecisions: decisions.length,
      recoveryApprovedCount: recoveryApprovedCount,
      sponsorAssignedCount: sponsorAssignedCount,
      closureValidatedCount: closureValidatedCount,
      deferredCount: deferredCount,
      escalatedCount: escalatedCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalDecisions: decisions.length,
        sponsorAssignedCount: sponsorAssignedCount,
        deferredCount: deferredCount,
        escalatedCount: escalatedCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countOutcome(
  List<IncomingTalentSuccessionCoverageCouncilDecision> decisions,
  IncomingTalentSuccessionCoverageCouncilDecisionOutcome outcome,
) {
  return decisions.where((decision) => decision.outcome == outcome).length;
}

String _nextAction({
  required int totalDecisions,
  required int sponsorAssignedCount,
  required int deferredCount,
  required int escalatedCount,
  required int attentionCount,
}) {
  if (totalDecisions == 0) {
    return 'Record council decisions from agenda items.';
  }
  if (escalatedCount > 0) {
    return 'Track $escalatedCount people board escalations.';
  }
  if (sponsorAssignedCount > 0) {
    return 'Confirm $sponsorAssignedCount executive sponsor commitments.';
  }
  if (deferredCount > 0) {
    return 'Prepare evidence for $deferredCount deferred decisions.';
  }
  if (attentionCount > 0) {
    return 'Follow up $attentionCount council decisions needing attention.';
  }
  return '$totalDecisions coverage council decisions recorded.';
}
