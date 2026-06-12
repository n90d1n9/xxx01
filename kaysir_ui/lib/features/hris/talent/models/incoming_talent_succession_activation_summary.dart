import 'incoming_talent_succession_activation_plan.dart';

class IncomingTalentSuccessionActivationSummary {
  final int totalPlans;
  final int plannedCount;
  final int inProgressCount;
  final int atRiskCount;
  final int completedCount;
  final int attentionCount;
  final String nextAction;

  const IncomingTalentSuccessionActivationSummary({
    required this.totalPlans,
    required this.plannedCount,
    required this.inProgressCount,
    required this.atRiskCount,
    required this.completedCount,
    required this.attentionCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionActivationSummary.fromPlans(
    List<IncomingTalentSuccessionActivationPlan> plans,
  ) {
    final plannedCount = _countByStatus(
      plans,
      IncomingTalentSuccessionActivationStatus.planned,
    );
    final inProgressCount = _countByStatus(
      plans,
      IncomingTalentSuccessionActivationStatus.inProgress,
    );
    final atRiskCount = _countByStatus(
      plans,
      IncomingTalentSuccessionActivationStatus.atRisk,
    );
    final completedCount = _countByStatus(
      plans,
      IncomingTalentSuccessionActivationStatus.completed,
    );
    final attentionCount = plans.where((plan) => plan.needsAttention).length;

    return IncomingTalentSuccessionActivationSummary(
      totalPlans: plans.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      atRiskCount: atRiskCount,
      completedCount: completedCount,
      attentionCount: attentionCount,
      nextAction: _nextAction(
        totalPlans: plans.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        atRiskCount: atRiskCount,
        completedCount: completedCount,
        attentionCount: attentionCount,
      ),
    );
  }

  static int _countByStatus(
    List<IncomingTalentSuccessionActivationPlan> plans,
    IncomingTalentSuccessionActivationStatus status,
  ) {
    return plans.where((plan) => plan.status == status).length;
  }

  static String _nextAction({
    required int totalPlans,
    required int plannedCount,
    required int inProgressCount,
    required int atRiskCount,
    required int completedCount,
    required int attentionCount,
  }) {
    if (totalPlans == 0) {
      return 'Activate approved succession decisions.';
    }
    if (atRiskCount > 0) {
      return 'Stabilize $atRiskCount at-risk activations.';
    }
    if (attentionCount > 0) {
      return 'Review $attentionCount activation risks.';
    }
    if (plannedCount > 0) {
      return 'Launch $plannedCount planned succession moves.';
    }
    if (inProgressCount > 0) {
      return 'Track $inProgressCount active succession transitions.';
    }
    if (completedCount > 0) {
      return 'Close $completedCount completed succession activations.';
    }
    return 'Succession activations are current.';
  }
}
