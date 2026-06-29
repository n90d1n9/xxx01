import 'incoming_talent_career_path_summary.dart';
import 'incoming_talent_career_path_support_action_summary.dart';
import 'incoming_talent_career_path_support_outcome_summary.dart';
import 'incoming_talent_development_check_in_summary.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_summary.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_summary.dart';
import 'incoming_talent_development_intervention_outcome_summary.dart';
import 'incoming_talent_development_intervention_summary.dart';
import 'incoming_talent_development_portfolio_summary.dart';
import 'incoming_talent_development_program_completion_summary.dart';
import 'incoming_talent_development_program_milestone_summary.dart';
import 'incoming_talent_development_roadmap_summary.dart';
import 'incoming_talent_health_signal.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_summary.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_summary.dart';
import 'incoming_talent_promotion_stabilization_review_summary.dart';

/// Calculates weighted talent health scores and supporting signal metadata.
int incomingTalentHealthScore({
  required IncomingTalentDevelopmentRoadmapSummary roadmapSummary,
  required IncomingTalentDevelopmentPortfolioSummary portfolioSummary,
  required IncomingTalentCareerPathSummary careerPathSummary,
  required IncomingTalentCareerPathSupportActionSummary supportActionSummary,
  required IncomingTalentCareerPathSupportOutcomeSummary supportOutcomeSummary,
  required IncomingTalentDevelopmentProgramMilestoneSummary milestoneSummary,
  required IncomingTalentDevelopmentProgramCompletionSummary completionSummary,
  required IncomingTalentDevelopmentCheckInSummary checkInSummary,
  required IncomingTalentDevelopmentInterventionSummary interventionSummary,
  required IncomingTalentDevelopmentInterventionOutcomeSummary
  interventionOutcomeSummary,
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary
  interventionOutcomeFollowUpSummary,
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary
  interventionOutcomeFollowUpResolutionSummary,
  IncomingTalentPromotionStabilizationReviewSummary
      promotionStabilizationSummary =
      emptyIncomingTalentPromotionStabilizationReviewSummary,
  IncomingTalentPromotionStabilizationFollowUpActionSummary
      promotionFollowUpSummary =
      emptyIncomingTalentPromotionStabilizationFollowUpActionSummary,
  IncomingTalentPromotionStabilizationFollowUpResolutionSummary
      promotionResolutionSummary =
      emptyIncomingTalentPromotionStabilizationFollowUpResolutionSummary,
}) {
  final penalties =
      roadmapSummary.atRiskCount * 12 +
      portfolioSummary.watchCount * 10 +
      portfolioSummary.recoveryPriorityCount * 8 +
      careerPathSummary.blockedCount * 10 +
      careerPathSummary.criticalCount * 8 +
      careerPathSummary.dueSoonCount * 3 +
      supportActionSummary.criticalCount * 8 +
      supportActionSummary.openCount * 3 +
      supportActionSummary.dueSoonCount * 4 +
      supportOutcomeSummary.escalateCount * 12 +
      supportOutcomeSummary.monitorCount * 6 +
      supportOutcomeSummary.attentionCount * 4 +
      milestoneSummary.revisionCount * 9 +
      milestoneSummary.dueSoonCount * 3 +
      completionSummary.extensionCount * 10 +
      completionSummary.renewalDueCount * 2 +
      checkInSummary.blockedCount * 14 +
      checkInSummary.lowConfidenceCount * 8 +
      interventionSummary.criticalCount * 14 +
      interventionSummary.openCount * 4 +
      interventionSummary.dueSoonCount * 5 +
      interventionSummary.releaseEvidenceRiskCount * 12 +
      interventionOutcomeSummary.escalateCount * 12 +
      interventionOutcomeSummary.releaseRiskCount * 10 +
      interventionOutcomeSummary.attentionCount * 4 +
      interventionOutcomeFollowUpSummary.escalatedCount * 14 +
      interventionOutcomeFollowUpSummary.overdueCount * 12 +
      interventionOutcomeFollowUpSummary.dueSoonCount * 5 +
      interventionOutcomeFollowUpSummary.inProgressCount * 3 +
      interventionOutcomeFollowUpSummary.openCount * 2 +
      interventionOutcomeFollowUpResolutionSummary.escalateCount * 16 +
      interventionOutcomeFollowUpResolutionSummary.monitorCount * 8 +
      interventionOutcomeFollowUpResolutionSummary.attentionCount * 5 +
      promotionStabilizationSummary.escalatedCount * 16 +
      promotionStabilizationSummary.attentionCount * 5 +
      promotionStabilizationSummary.dueFollowUpCount * 4 +
      promotionStabilizationSummary.trialExtendedCount * 3 +
      promotionFollowUpSummary.escalatedCount * 16 +
      promotionFollowUpSummary.criticalCount * 9 +
      promotionFollowUpSummary.dueSoonCount * 4 +
      promotionFollowUpSummary.openCount * 2 +
      promotionFollowUpSummary.inProgressCount * 2 +
      promotionResolutionSummary.escalatedCount * 16 +
      promotionResolutionSummary.reopenedCount * 12 +
      promotionResolutionSummary.monitorCount * 6 +
      promotionResolutionSummary.attentionCount * 4 +
      portfolioSummary.dueSoonCount * 4;
  final score = 100 - penalties;
  if (score < 0) return 0;
  if (score > 100) return 100;
  return score;
}

List<IncomingTalentHealthSignal> incomingTalentHealthSignals({
  required IncomingTalentDevelopmentRoadmapSummary roadmapSummary,
  required IncomingTalentDevelopmentPortfolioSummary portfolioSummary,
  required IncomingTalentCareerPathSummary careerPathSummary,
  required IncomingTalentCareerPathSupportActionSummary supportActionSummary,
  required IncomingTalentCareerPathSupportOutcomeSummary supportOutcomeSummary,
  required IncomingTalentDevelopmentProgramMilestoneSummary milestoneSummary,
  required IncomingTalentDevelopmentProgramCompletionSummary completionSummary,
  required IncomingTalentDevelopmentCheckInSummary checkInSummary,
  required IncomingTalentDevelopmentInterventionSummary interventionSummary,
  required IncomingTalentDevelopmentInterventionOutcomeSummary
  interventionOutcomeSummary,
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary
  interventionOutcomeFollowUpSummary,
  required IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary
  interventionOutcomeFollowUpResolutionSummary,
  IncomingTalentPromotionStabilizationReviewSummary
      promotionStabilizationSummary =
      emptyIncomingTalentPromotionStabilizationReviewSummary,
  IncomingTalentPromotionStabilizationFollowUpActionSummary
      promotionFollowUpSummary =
      emptyIncomingTalentPromotionStabilizationFollowUpActionSummary,
  IncomingTalentPromotionStabilizationFollowUpResolutionSummary
      promotionResolutionSummary =
      emptyIncomingTalentPromotionStabilizationFollowUpResolutionSummary,
}) {
  return [
    IncomingTalentHealthSignal(
      label: 'Roadmap risk',
      value: '${roadmapSummary.atRiskCount}',
      detail: '${roadmapSummary.totalCount} roadmaps in view',
      severity: incomingTalentHealthSeverity(
        roadmapSummary.atRiskCount,
        criticalThreshold: 2,
      ),
    ),
    IncomingTalentHealthSignal(
      label: 'IDP watch',
      value: '${portfolioSummary.watchCount}',
      detail: '${portfolioSummary.dueSoonCount} reviews due soon',
      severity: incomingTalentHealthSeverity(
        portfolioSummary.watchCount,
        criticalThreshold: 2,
      ),
    ),
    IncomingTalentHealthSignal(
      label: 'Career gaps',
      value: careerPathSummary.averageGap.toStringAsFixed(1),
      detail: '${careerPathSummary.blockedCount} blocked career paths',
      severity:
          careerPathSummary.blockedCount > 0
              ? IncomingTalentHealthSignalSeverity.critical
              : incomingTalentHealthSeverity(careerPathSummary.criticalCount),
    ),
    IncomingTalentHealthSignal(
      label: 'Career support',
      value: '${supportActionSummary.openCount}',
      detail:
          '${supportActionSummary.criticalCount} critical actions, '
          '${supportOutcomeSummary.attentionCount} outcomes on watch',
      severity: _careerSupportSeverity(
        supportActionSummary,
        supportOutcomeSummary,
      ),
    ),
    IncomingTalentHealthSignal(
      label: 'Program milestones',
      value: '${milestoneSummary.revisionCount}',
      detail:
          '${milestoneSummary.submittedCount} submitted, '
          '${milestoneSummary.dueSoonCount} due soon',
      severity: _programMilestoneSeverity(milestoneSummary),
    ),
    IncomingTalentHealthSignal(
      label: 'Program completions',
      value: '${completionSummary.extensionCount}',
      detail:
          '${completionSummary.roleReadyCount} role-ready, '
          '${completionSummary.renewalDueCount} renewals due',
      severity: _programCompletionSeverity(completionSummary),
    ),
    IncomingTalentHealthSignal(
      label: 'Confidence',
      value: checkInSummary.averageConfidenceScore.toStringAsFixed(1),
      detail: '${checkInSummary.lowConfidenceCount} low-confidence check-ins',
      severity:
          checkInSummary.blockedCount > 0
              ? IncomingTalentHealthSignalSeverity.critical
              : incomingTalentHealthSeverity(checkInSummary.lowConfidenceCount),
    ),
    IncomingTalentHealthSignal(
      label: 'Interventions',
      value: '${interventionSummary.openCount}',
      detail:
          '${interventionSummary.criticalCount} critical, '
          '${interventionSummary.releaseEvidenceRiskCount} release risks, '
          '${interventionOutcomeSummary.attentionCount} outcomes on watch, '
          '${interventionOutcomeFollowUpSummary.dueSoonCount} follow-ups due, '
          '${interventionOutcomeFollowUpResolutionSummary.attentionCount} reviews on watch',
      severity: _interventionSeverity(
        interventionSummary,
        interventionOutcomeSummary,
        interventionOutcomeFollowUpSummary,
        interventionOutcomeFollowUpResolutionSummary,
      ),
    ),
    if (promotionStabilizationSummary.totalCount > 0)
      IncomingTalentHealthSignal(
        label: 'Promotion stability',
        value: '${promotionStabilizationSummary.attentionCount}',
        detail:
            '${promotionStabilizationSummary.escalatedCount} escalated, '
            '${promotionStabilizationSummary.dueFollowUpCount} follow-ups due, '
            '${promotionStabilizationSummary.averageConfidence.toStringAsFixed(1)} avg confidence',
        severity: _promotionStabilizationSeverity(
          promotionStabilizationSummary,
        ),
      ),
    if (promotionFollowUpSummary.totalCount > 0)
      IncomingTalentHealthSignal(
        label: 'Promotion follow-ups',
        value: '${promotionFollowUpSummary.attentionCount}',
        detail:
            '${promotionFollowUpSummary.escalatedCount} escalated, '
            '${promotionFollowUpSummary.dueSoonCount} due soon, '
            '${(promotionFollowUpSummary.averageProgress * 100).round()}% avg progress',
        severity: _promotionFollowUpSeverity(promotionFollowUpSummary),
      ),
    if (promotionResolutionSummary.totalCount > 0)
      IncomingTalentHealthSignal(
        label: 'Promotion resolutions',
        value: '${promotionResolutionSummary.attentionCount}',
        detail:
            '${promotionResolutionSummary.escalatedCount} escalated, '
            '${promotionResolutionSummary.reopenedCount} reopened, '
            '${promotionResolutionSummary.averageConfidenceAfter.toStringAsFixed(1)} avg confidence',
        severity: _promotionResolutionSeverity(promotionResolutionSummary),
      ),
  ];
}

IncomingTalentHealthSignalSeverity incomingTalentHealthSeverity(
  int value, {
  int criticalThreshold = 2,
}) {
  if (value >= criticalThreshold) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  if (value > 0) return IncomingTalentHealthSignalSeverity.watch;
  return IncomingTalentHealthSignalSeverity.stable;
}

IncomingTalentHealthStatus incomingTalentHealthStatus(
  int score,
  List<IncomingTalentHealthSignal> signals,
) {
  if (score < 60 ||
      signals.any(
        (signal) =>
            signal.severity == IncomingTalentHealthSignalSeverity.critical,
      )) {
    return IncomingTalentHealthStatus.critical;
  }
  if (score < 82 ||
      signals.any(
        (signal) => signal.severity == IncomingTalentHealthSignalSeverity.watch,
      )) {
    return IncomingTalentHealthStatus.watch;
  }
  return IncomingTalentHealthStatus.strong;
}

double incomingTalentAverageReadiness(
  IncomingTalentDevelopmentRoadmapSummary roadmapSummary,
  IncomingTalentDevelopmentPortfolioSummary portfolioSummary,
) {
  final totalCount = roadmapSummary.totalCount + portfolioSummary.totalCount;
  if (totalCount == 0) return 0;
  final total =
      roadmapSummary.averageReadinessScore * roadmapSummary.totalCount +
      portfolioSummary.averageReadinessScore * portfolioSummary.totalCount;
  return total / totalCount;
}

String incomingTalentHealthNextAction(
  int score,
  List<IncomingTalentHealthSignal> signals,
) {
  final criticalSignals =
      signals
          .where(
            (signal) =>
                signal.severity == IncomingTalentHealthSignalSeverity.critical,
          )
          .length;
  final watchSignals =
      signals
          .where(
            (signal) =>
                signal.severity == IncomingTalentHealthSignalSeverity.watch,
          )
          .length;

  if (criticalSignals > 0) {
    return 'Resolve $criticalSignals critical talent health signals.';
  }
  if (score < 82 || watchSignals > 0) {
    return 'Review $watchSignals watch talent health signals.';
  }
  return 'Keep talent development health on cadence.';
}

IncomingTalentHealthSignalSeverity _careerSupportSeverity(
  IncomingTalentCareerPathSupportActionSummary actionSummary,
  IncomingTalentCareerPathSupportOutcomeSummary outcomeSummary,
) {
  if (actionSummary.criticalCount > 0 || outcomeSummary.escalateCount > 0) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  final watchCount =
      actionSummary.openCount +
      actionSummary.dueSoonCount +
      outcomeSummary.monitorCount +
      outcomeSummary.attentionCount;
  return incomingTalentHealthSeverity(watchCount, criticalThreshold: 3);
}

IncomingTalentHealthSignalSeverity _programMilestoneSeverity(
  IncomingTalentDevelopmentProgramMilestoneSummary milestoneSummary,
) {
  if (milestoneSummary.revisionCount >= 2) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  if (milestoneSummary.revisionCount > 0 ||
      milestoneSummary.averageScore > 0 && milestoneSummary.averageScore < 70) {
    return IncomingTalentHealthSignalSeverity.watch;
  }
  return incomingTalentHealthSeverity(
    milestoneSummary.dueSoonCount,
    criticalThreshold: 4,
  );
}

IncomingTalentHealthSignalSeverity _programCompletionSeverity(
  IncomingTalentDevelopmentProgramCompletionSummary completionSummary,
) {
  if (completionSummary.extensionCount > 0) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  if (completionSummary.averageScore > 0 &&
      completionSummary.averageScore < 70) {
    return IncomingTalentHealthSignalSeverity.watch;
  }
  return incomingTalentHealthSeverity(
    completionSummary.renewalDueCount,
    criticalThreshold: 4,
  );
}

IncomingTalentHealthSignalSeverity _interventionSeverity(
  IncomingTalentDevelopmentInterventionSummary interventionSummary,
  IncomingTalentDevelopmentInterventionOutcomeSummary outcomeSummary,
  IncomingTalentDevelopmentInterventionOutcomeFollowUpSummary followUpSummary,
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary
  followUpResolutionSummary,
) {
  if (interventionSummary.criticalCount > 0 ||
      interventionSummary.releaseEvidenceRiskCount > 0 ||
      outcomeSummary.escalateCount > 0 ||
      outcomeSummary.releaseRiskCount > 0 ||
      followUpSummary.escalatedCount > 0 ||
      followUpSummary.overdueCount > 0 ||
      followUpResolutionSummary.escalateCount > 0) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  return incomingTalentHealthSeverity(
    interventionSummary.openCount +
        outcomeSummary.attentionCount +
        followUpSummary.openCount +
        followUpSummary.dueSoonCount +
        followUpResolutionSummary.attentionCount,
    criticalThreshold: 3,
  );
}

IncomingTalentHealthSignalSeverity _promotionStabilizationSeverity(
  IncomingTalentPromotionStabilizationReviewSummary summary,
) {
  if (summary.escalatedCount > 0 ||
      summary.averageConfidence > 0 && summary.averageConfidence < 3) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  return incomingTalentHealthSeverity(
    summary.attentionCount + summary.dueFollowUpCount,
    criticalThreshold: 3,
  );
}

IncomingTalentHealthSignalSeverity _promotionFollowUpSeverity(
  IncomingTalentPromotionStabilizationFollowUpActionSummary summary,
) {
  if (summary.escalatedCount > 0 || summary.criticalCount > 0) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  return incomingTalentHealthSeverity(
    summary.attentionCount + summary.dueSoonCount + summary.openCount,
    criticalThreshold: 4,
  );
}

IncomingTalentHealthSignalSeverity _promotionResolutionSeverity(
  IncomingTalentPromotionStabilizationFollowUpResolutionSummary summary,
) {
  if (summary.escalatedCount > 0 ||
      summary.reopenedCount > 0 ||
      summary.averageConfidenceAfter > 0 &&
          summary.averageConfidenceAfter < 3) {
    return IncomingTalentHealthSignalSeverity.critical;
  }
  return incomingTalentHealthSeverity(
    summary.attentionCount + summary.monitorCount,
    criticalThreshold: 3,
  );
}
