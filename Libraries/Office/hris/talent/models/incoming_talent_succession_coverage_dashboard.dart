import 'incoming_talent_succession_activation_plan.dart';
import 'incoming_talent_succession_bench_action.dart';
import 'incoming_talent_succession_bench_check_in.dart';
import 'incoming_talent_succession_bench_replenishment.dart';
import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_coverage_counts.dart';
import 'incoming_talent_succession_transition_intervention.dart';
import 'incoming_talent_succession_transition_outcome_review.dart';
import 'incoming_talent_succession_transition_pulse.dart';

enum IncomingTalentSuccessionCoverageHealth {
  strong('Strong coverage'),
  watch('Watch coverage'),
  critical('Critical coverage');

  final String label;

  const IncomingTalentSuccessionCoverageHealth(this.label);
}

class IncomingTalentSuccessionCoverageDashboard {
  final IncomingTalentSuccessionCoverageCounts counts;
  final int coverageScore;
  final IncomingTalentSuccessionCoverageHealth health;
  final String nextAction;

  const IncomingTalentSuccessionCoverageDashboard({
    required this.counts,
    required this.coverageScore,
    required this.health,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageDashboard.fromSignals({
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
    final counts = IncomingTalentSuccessionCoverageCounts.fromSignals(
      candidates: candidates,
      activationPlans: activationPlans,
      transitionPulses: transitionPulses,
      transitionInterventions: transitionInterventions,
      transitionOutcomeReviews: transitionOutcomeReviews,
      benchPlans: benchPlans,
      benchCheckIns: benchCheckIns,
      benchActions: benchActions,
    );

    final score = _coverageScore(counts);
    final health = _health(
      totalCandidates: counts.totalCandidates,
      readyNowCount: counts.readyNowCount,
      coverageScore: score,
      blockedCandidateCount: counts.blockedCandidateCount,
      criticalBenchPlanCount: counts.criticalBenchPlanCount,
      openBenchActionCount: counts.openBenchActionCount,
      transitionOutcomeRiskCount: counts.transitionOutcomeRiskCount,
    );

    return IncomingTalentSuccessionCoverageDashboard(
      counts: counts,
      coverageScore: score,
      health: health,
      nextAction: _nextAction(
        totalCandidates: counts.totalCandidates,
        readyNowCount: counts.readyNowCount,
        blockedCandidateCount: counts.blockedCandidateCount,
        criticalBenchPlanCount: counts.criticalBenchPlanCount,
        openBenchActionCount: counts.openBenchActionCount,
        openTransitionInterventionCount: counts.openTransitionInterventionCount,
        transitionOutcomeRiskCount: counts.transitionOutcomeRiskCount,
        health: health,
      ),
    );
  }

  int get totalCandidates => counts.totalCandidates;

  int get readyNowCount => counts.readyNowCount;

  int get readySoonCount => counts.readySoonCount;

  int get blockedCandidateCount => counts.blockedCandidateCount;

  int get highRiskCandidateCount => counts.highRiskCandidateCount;

  int get activationPlanCount => counts.activationPlanCount;

  int get activationAtRiskCount => counts.activationAtRiskCount;

  int get transitionPulseCount => counts.transitionPulseCount;

  int get transitionPulseAtRiskCount => counts.transitionPulseAtRiskCount;

  int get openTransitionInterventionCount =>
      counts.openTransitionInterventionCount;

  int get transitionOutcomeRiskCount => counts.transitionOutcomeRiskCount;

  int get benchPlanCount => counts.benchPlanCount;

  int get criticalBenchPlanCount => counts.criticalBenchPlanCount;

  int get benchCheckInAttentionCount => counts.benchCheckInAttentionCount;

  int get openBenchActionCount => counts.openBenchActionCount;

  int get readyCoverageCount => counts.readyCoverageCount;

  int get attentionSignalCount => counts.attentionSignalCount;

  double get coverageRatio => coverageScore / 100;

  double get readyCoverageRatio => counts.readyCoverageRatio;

  static int _coverageScore(IncomingTalentSuccessionCoverageCounts counts) {
    if (counts.totalCandidates == 0) return 0;

    final readyCoverage = counts.readyCoverageRatio;
    final baseScore =
        40 + (readyCoverage * 35).round() + counts.readyNowCount * 6;
    final deductions =
        counts.blockedCandidateCount * 12 +
        counts.highRiskCandidateCount * 8 +
        counts.activationAtRiskCount * 6 +
        counts.transitionPulseAtRiskCount * 7 +
        counts.openTransitionInterventionCount * 7 +
        counts.transitionOutcomeRiskCount * 8 +
        counts.criticalBenchPlanCount * 8 +
        counts.benchCheckInAttentionCount * 6 +
        counts.openBenchActionCount * 5;

    return (baseScore - deductions).clamp(0, 100);
  }

  static IncomingTalentSuccessionCoverageHealth _health({
    required int totalCandidates,
    required int readyNowCount,
    required int coverageScore,
    required int blockedCandidateCount,
    required int criticalBenchPlanCount,
    required int openBenchActionCount,
    required int transitionOutcomeRiskCount,
  }) {
    if (totalCandidates == 0 ||
        coverageScore < 50 ||
        blockedCandidateCount > 0 ||
        criticalBenchPlanCount > 0 ||
        openBenchActionCount >= 3 ||
        transitionOutcomeRiskCount >= 2) {
      return IncomingTalentSuccessionCoverageHealth.critical;
    }
    if (coverageScore >= 75 && readyNowCount > 0 && openBenchActionCount == 0) {
      return IncomingTalentSuccessionCoverageHealth.strong;
    }
    return IncomingTalentSuccessionCoverageHealth.watch;
  }

  static String _nextAction({
    required int totalCandidates,
    required int readyNowCount,
    required int blockedCandidateCount,
    required int criticalBenchPlanCount,
    required int openBenchActionCount,
    required int openTransitionInterventionCount,
    required int transitionOutcomeRiskCount,
    required IncomingTalentSuccessionCoverageHealth health,
  }) {
    if (totalCandidates == 0) {
      return 'Build a succession slate before coverage review.';
    }
    if (openBenchActionCount > 0) {
      return 'Resolve ${_count(openBenchActionCount, 'open bench action')} before coverage review.';
    }
    if (criticalBenchPlanCount > 0) {
      return 'Rebuild ${_count(criticalBenchPlanCount, 'critical bench plan')}.';
    }
    if (openTransitionInterventionCount > 0) {
      return 'Close ${_count(openTransitionInterventionCount, 'transition intervention')}.';
    }
    if (transitionOutcomeRiskCount > 0) {
      return 'Review ${_count(transitionOutcomeRiskCount, 'transition outcome risk')}.';
    }
    if (blockedCandidateCount > 0) {
      return 'Unblock ${_count(blockedCandidateCount, 'succession candidate')}.';
    }
    if (readyNowCount == 0) {
      return 'Convert ready-soon successors into ready-now coverage.';
    }
    if (health == IncomingTalentSuccessionCoverageHealth.watch) {
      return 'Tighten succession readiness before executive review.';
    }
    return 'Succession coverage is healthy.';
  }

  static String _count(int value, String label) {
    return '$value $label${value == 1 ? '' : 's'}';
  }
}
