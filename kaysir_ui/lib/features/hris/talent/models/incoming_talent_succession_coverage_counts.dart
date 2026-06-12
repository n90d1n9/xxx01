import 'incoming_talent_succession_activation_plan.dart';
import 'incoming_talent_succession_bench_action.dart';
import 'incoming_talent_succession_bench_check_in.dart';
import 'incoming_talent_succession_bench_replenishment.dart';
import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_transition_intervention.dart';
import 'incoming_talent_succession_transition_outcome_review.dart';
import 'incoming_talent_succession_transition_pulse.dart';

class IncomingTalentSuccessionCoverageCounts {
  final int totalCandidates;
  final int readyNowCount;
  final int readySoonCount;
  final int blockedCandidateCount;
  final int highRiskCandidateCount;
  final int activationPlanCount;
  final int activationAtRiskCount;
  final int transitionPulseCount;
  final int transitionPulseAtRiskCount;
  final int openTransitionInterventionCount;
  final int transitionOutcomeRiskCount;
  final int benchPlanCount;
  final int criticalBenchPlanCount;
  final int benchCheckInAttentionCount;
  final int openBenchActionCount;

  const IncomingTalentSuccessionCoverageCounts({
    required this.totalCandidates,
    required this.readyNowCount,
    required this.readySoonCount,
    required this.blockedCandidateCount,
    required this.highRiskCandidateCount,
    required this.activationPlanCount,
    required this.activationAtRiskCount,
    required this.transitionPulseCount,
    required this.transitionPulseAtRiskCount,
    required this.openTransitionInterventionCount,
    required this.transitionOutcomeRiskCount,
    required this.benchPlanCount,
    required this.criticalBenchPlanCount,
    required this.benchCheckInAttentionCount,
    required this.openBenchActionCount,
  });

  factory IncomingTalentSuccessionCoverageCounts.fromSignals({
    required List<IncomingTalentSuccessionCandidate> candidates,
    required List<IncomingTalentSuccessionActivationPlan> activationPlans,
    required List<IncomingTalentSuccessionTransitionPulse> transitionPulses,
    required List<IncomingTalentSuccessionTransitionIntervention>
    transitionInterventions,
    required List<IncomingTalentSuccessionTransitionOutcomeReview>
    transitionOutcomeReviews,
    required List<IncomingTalentSuccessionBenchReplenishment> benchPlans,
    required List<IncomingTalentSuccessionBenchCheckIn> benchCheckIns,
    required List<IncomingTalentSuccessionBenchAction> benchActions,
  }) {
    return IncomingTalentSuccessionCoverageCounts(
      totalCandidates: candidates.length,
      readyNowCount:
          candidates
              .where(
                (candidate) =>
                    candidate.readiness ==
                    IncomingTalentSuccessionReadiness.readyNow,
              )
              .length,
      readySoonCount:
          candidates
              .where(
                (candidate) =>
                    candidate.readiness ==
                    IncomingTalentSuccessionReadiness.readySoon,
              )
              .length,
      blockedCandidateCount:
          candidates
              .where(
                (candidate) =>
                    candidate.readiness ==
                    IncomingTalentSuccessionReadiness.blocked,
              )
              .length,
      highRiskCandidateCount:
          candidates
              .where(
                (candidate) =>
                    candidate.risk == IncomingTalentSuccessionRisk.high,
              )
              .length,
      activationPlanCount: activationPlans.length,
      activationAtRiskCount:
          activationPlans.where((plan) => plan.needsAttention).length,
      transitionPulseCount: transitionPulses.length,
      transitionPulseAtRiskCount:
          transitionPulses.where((pulse) => pulse.needsAttention).length,
      openTransitionInterventionCount:
          transitionInterventions
              .where((intervention) => intervention.isOpen)
              .length,
      transitionOutcomeRiskCount:
          transitionOutcomeReviews
              .where((review) => review.needsAttention)
              .length,
      benchPlanCount: benchPlans.length,
      criticalBenchPlanCount:
          benchPlans.where((plan) => plan.needsAttention).length,
      benchCheckInAttentionCount:
          benchCheckIns.where((checkIn) => checkIn.needsAttention).length,
      openBenchActionCount:
          benchActions.where((action) => action.isOpen).length,
    );
  }

  int get readyCoverageCount => readyNowCount + readySoonCount;

  int get attentionSignalCount {
    return blockedCandidateCount +
        highRiskCandidateCount +
        activationAtRiskCount +
        transitionPulseAtRiskCount +
        openTransitionInterventionCount +
        transitionOutcomeRiskCount +
        criticalBenchPlanCount +
        benchCheckInAttentionCount +
        openBenchActionCount;
  }

  double get readyCoverageRatio {
    if (totalCandidates == 0) return 0;
    return readyCoverageCount / totalCandidates;
  }
}
