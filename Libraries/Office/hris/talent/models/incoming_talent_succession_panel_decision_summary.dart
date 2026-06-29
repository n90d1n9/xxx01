import 'incoming_talent_succession_panel_decision.dart';

class IncomingTalentSuccessionPanelDecisionSummary {
  final int totalDecisions;
  final int approvedCount;
  final int conditionalCount;
  final int deferredCount;
  final int declinedCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentSuccessionPanelDecisionSummary({
    required this.totalDecisions,
    required this.approvedCount,
    required this.conditionalCount,
    required this.deferredCount,
    required this.declinedCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionPanelDecisionSummary.fromDecisions(
    List<IncomingTalentSuccessionPanelDecision> decisions,
  ) {
    final approvedCount =
        decisions
            .where(
              (decision) =>
                  decision.outcome ==
                      IncomingTalentSuccessionPanelOutcome.approvePromotion ||
                  decision.outcome ==
                      IncomingTalentSuccessionPanelOutcome
                          .approveSuccessionBench,
            )
            .length;
    final conditionalCount = _countByOutcome(
      decisions,
      IncomingTalentSuccessionPanelOutcome.conditionalApproval,
    );
    final deferredCount = _countByOutcome(
      decisions,
      IncomingTalentSuccessionPanelOutcome.defer,
    );
    final declinedCount = _countByOutcome(
      decisions,
      IncomingTalentSuccessionPanelOutcome.decline,
    );
    final attentionCount =
        decisions.where((decision) => decision.needsAttention).length;

    return IncomingTalentSuccessionPanelDecisionSummary(
      totalDecisions: decisions.length,
      approvedCount: approvedCount,
      conditionalCount: conditionalCount,
      deferredCount: deferredCount,
      declinedCount: declinedCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalDecisions: decisions.length,
        approvedCount: approvedCount,
        conditionalCount: conditionalCount,
        deferredCount: deferredCount,
        declinedCount: declinedCount,
        attentionCount: attentionCount,
      ),
    );
  }

  static int _countByOutcome(
    List<IncomingTalentSuccessionPanelDecision> decisions,
    IncomingTalentSuccessionPanelOutcome outcome,
  ) {
    return decisions.where((decision) => decision.outcome == outcome).length;
  }

  static String _nextAction({
    required int totalDecisions,
    required int approvedCount,
    required int conditionalCount,
    required int deferredCount,
    required int declinedCount,
    required int attentionCount,
  }) {
    if (totalDecisions == 0) {
      return 'Record panel outcomes for submitted nominations.';
    }
    if (deferredCount > 0) {
      return 'Resolve $deferredCount deferred panel decisions.';
    }
    if (conditionalCount > 0) {
      return 'Track $conditionalCount conditional approvals.';
    }
    if (attentionCount > 0) {
      return 'Follow up $attentionCount panel decision risks.';
    }
    if (approvedCount > 0) {
      return 'Activate $approvedCount approved talent moves.';
    }
    if (declinedCount > 0) {
      return 'Close declined succession records.';
    }
    return 'Panel decisions are current.';
  }
}
