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
import 'incoming_talent_health_dashboard_calculator.dart';
import 'incoming_talent_health_signal.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_summary.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_summary.dart';
import 'incoming_talent_promotion_stabilization_review_summary.dart';

/// Aggregated HRIS health view for talent development and promotion stability.
class IncomingTalentHealthDashboard {
  final IncomingTalentHealthStatus status;
  final int healthScore;
  final int totalRoadmaps;
  final int atRiskRoadmaps;
  final int totalPortfolios;
  final int watchPortfolios;
  final int duePortfolioReviews;
  final int totalCheckIns;
  final int blockedCheckIns;
  final int lowConfidenceCheckIns;
  final int openInterventions;
  final int criticalInterventions;
  final int dueInterventions;
  final int releaseEvidenceInterventions;
  final int developmentOutcomeAttentionCount;
  final int developmentOutcomeReleaseRiskCount;
  final double averageDevelopmentOutcomeConfidence;
  final int developmentFollowUpOpenCount;
  final int developmentFollowUpDueSoonCount;
  final int developmentFollowUpOverdueCount;
  final int developmentFollowUpEscalatedCount;
  final int developmentFollowUpResolutionAttentionCount;
  final int developmentFollowUpResolutionEscalatedCount;
  final double averageDevelopmentFollowUpResolutionConfidence;
  final int totalCareerPaths;
  final int blockedCareerPaths;
  final int criticalCareerPaths;
  final double averageCareerPathGap;
  final int totalCareerSupportActions;
  final int openCareerSupportActions;
  final int criticalCareerSupportActions;
  final int dueCareerSupportActions;
  final int totalCareerSupportOutcomes;
  final int monitorCareerSupportOutcomes;
  final int escalatedCareerSupportOutcomes;
  final double averageCareerSupportOutcomeLevel;
  final int totalProgramMilestones;
  final int programMilestoneRevisions;
  final int dueProgramMilestones;
  final double averageProgramMilestoneScore;
  final int totalProgramCompletions;
  final int roleReadyProgramCompletions;
  final int programCompletionExtensions;
  final int renewalDueProgramCompletions;
  final double averageProgramCompletionScore;
  final int totalPromotionStabilizationReviews;
  final int promotionStabilizationAttentionCount;
  final int promotionStabilizationEscalatedCount;
  final int promotionStabilizationDueFollowUps;
  final double averagePromotionStabilizationConfidence;
  final int totalPromotionFollowUpActions;
  final int openPromotionFollowUpActions;
  final int promotionFollowUpAttentionCount;
  final int criticalPromotionFollowUpActions;
  final int promotionFollowUpDueSoonCount;
  final int promotionFollowUpEscalatedCount;
  final double averagePromotionFollowUpProgress;
  final int totalPromotionFollowUpResolutions;
  final int promotionResolutionAttentionCount;
  final int promotionResolutionMonitorCount;
  final int promotionResolutionReopenedCount;
  final int promotionResolutionEscalatedCount;
  final double averagePromotionResolutionConfidence;
  final double averagePromotionResolutionConfidenceDelta;
  final double averageReadinessScore;
  final double averageConfidenceScore;
  final List<IncomingTalentHealthSignal> signals;
  final String nextAction;

  const IncomingTalentHealthDashboard({
    required this.status,
    required this.healthScore,
    required this.totalRoadmaps,
    required this.atRiskRoadmaps,
    required this.totalPortfolios,
    required this.watchPortfolios,
    required this.duePortfolioReviews,
    required this.totalCheckIns,
    required this.blockedCheckIns,
    required this.lowConfidenceCheckIns,
    required this.openInterventions,
    required this.criticalInterventions,
    required this.dueInterventions,
    required this.releaseEvidenceInterventions,
    required this.developmentOutcomeAttentionCount,
    required this.developmentOutcomeReleaseRiskCount,
    required this.averageDevelopmentOutcomeConfidence,
    required this.developmentFollowUpOpenCount,
    required this.developmentFollowUpDueSoonCount,
    required this.developmentFollowUpOverdueCount,
    required this.developmentFollowUpEscalatedCount,
    required this.developmentFollowUpResolutionAttentionCount,
    required this.developmentFollowUpResolutionEscalatedCount,
    required this.averageDevelopmentFollowUpResolutionConfidence,
    required this.totalCareerPaths,
    required this.blockedCareerPaths,
    required this.criticalCareerPaths,
    required this.averageCareerPathGap,
    required this.totalCareerSupportActions,
    required this.openCareerSupportActions,
    required this.criticalCareerSupportActions,
    required this.dueCareerSupportActions,
    required this.totalCareerSupportOutcomes,
    required this.monitorCareerSupportOutcomes,
    required this.escalatedCareerSupportOutcomes,
    required this.averageCareerSupportOutcomeLevel,
    required this.totalProgramMilestones,
    required this.programMilestoneRevisions,
    required this.dueProgramMilestones,
    required this.averageProgramMilestoneScore,
    required this.totalProgramCompletions,
    required this.roleReadyProgramCompletions,
    required this.programCompletionExtensions,
    required this.renewalDueProgramCompletions,
    required this.averageProgramCompletionScore,
    required this.totalPromotionStabilizationReviews,
    required this.promotionStabilizationAttentionCount,
    required this.promotionStabilizationEscalatedCount,
    required this.promotionStabilizationDueFollowUps,
    required this.averagePromotionStabilizationConfidence,
    required this.totalPromotionFollowUpActions,
    required this.openPromotionFollowUpActions,
    required this.promotionFollowUpAttentionCount,
    required this.criticalPromotionFollowUpActions,
    required this.promotionFollowUpDueSoonCount,
    required this.promotionFollowUpEscalatedCount,
    required this.averagePromotionFollowUpProgress,
    required this.totalPromotionFollowUpResolutions,
    required this.promotionResolutionAttentionCount,
    required this.promotionResolutionMonitorCount,
    required this.promotionResolutionReopenedCount,
    required this.promotionResolutionEscalatedCount,
    required this.averagePromotionResolutionConfidence,
    required this.averagePromotionResolutionConfidenceDelta,
    required this.averageReadinessScore,
    required this.averageConfidenceScore,
    required this.signals,
    required this.nextAction,
  });

  factory IncomingTalentHealthDashboard.fromSummaries({
    required IncomingTalentDevelopmentRoadmapSummary roadmapSummary,
    required IncomingTalentDevelopmentPortfolioSummary portfolioSummary,
    required IncomingTalentCareerPathSummary careerPathSummary,
    required IncomingTalentCareerPathSupportActionSummary supportActionSummary,
    required IncomingTalentCareerPathSupportOutcomeSummary
    supportOutcomeSummary,
    required IncomingTalentDevelopmentProgramMilestoneSummary milestoneSummary,
    required IncomingTalentDevelopmentProgramCompletionSummary
    completionSummary,
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
    final score = incomingTalentHealthScore(
      roadmapSummary: roadmapSummary,
      portfolioSummary: portfolioSummary,
      careerPathSummary: careerPathSummary,
      supportActionSummary: supportActionSummary,
      supportOutcomeSummary: supportOutcomeSummary,
      milestoneSummary: milestoneSummary,
      completionSummary: completionSummary,
      checkInSummary: checkInSummary,
      interventionSummary: interventionSummary,
      interventionOutcomeSummary: interventionOutcomeSummary,
      interventionOutcomeFollowUpSummary: interventionOutcomeFollowUpSummary,
      interventionOutcomeFollowUpResolutionSummary:
          interventionOutcomeFollowUpResolutionSummary,
      promotionStabilizationSummary: promotionStabilizationSummary,
      promotionFollowUpSummary: promotionFollowUpSummary,
      promotionResolutionSummary: promotionResolutionSummary,
    );
    final signals = incomingTalentHealthSignals(
      roadmapSummary: roadmapSummary,
      portfolioSummary: portfolioSummary,
      careerPathSummary: careerPathSummary,
      supportActionSummary: supportActionSummary,
      supportOutcomeSummary: supportOutcomeSummary,
      milestoneSummary: milestoneSummary,
      completionSummary: completionSummary,
      checkInSummary: checkInSummary,
      interventionSummary: interventionSummary,
      interventionOutcomeSummary: interventionOutcomeSummary,
      interventionOutcomeFollowUpSummary: interventionOutcomeFollowUpSummary,
      interventionOutcomeFollowUpResolutionSummary:
          interventionOutcomeFollowUpResolutionSummary,
      promotionStabilizationSummary: promotionStabilizationSummary,
      promotionFollowUpSummary: promotionFollowUpSummary,
      promotionResolutionSummary: promotionResolutionSummary,
    );

    return IncomingTalentHealthDashboard(
      status: incomingTalentHealthStatus(score, signals),
      healthScore: score,
      totalRoadmaps: roadmapSummary.totalCount,
      atRiskRoadmaps: roadmapSummary.atRiskCount,
      totalPortfolios: portfolioSummary.totalCount,
      watchPortfolios: portfolioSummary.watchCount,
      duePortfolioReviews: portfolioSummary.dueSoonCount,
      totalCheckIns: checkInSummary.totalCount,
      blockedCheckIns: checkInSummary.blockedCount,
      lowConfidenceCheckIns: checkInSummary.lowConfidenceCount,
      openInterventions: interventionSummary.openCount,
      criticalInterventions: interventionSummary.criticalCount,
      dueInterventions: interventionSummary.dueSoonCount,
      releaseEvidenceInterventions:
          interventionSummary.releaseEvidenceRiskCount,
      developmentOutcomeAttentionCount:
          interventionOutcomeSummary.attentionCount,
      developmentOutcomeReleaseRiskCount:
          interventionOutcomeSummary.releaseRiskCount,
      averageDevelopmentOutcomeConfidence:
          interventionOutcomeSummary.averageConfidenceAfter,
      developmentFollowUpOpenCount:
          interventionOutcomeFollowUpSummary.openCount,
      developmentFollowUpDueSoonCount:
          interventionOutcomeFollowUpSummary.dueSoonCount,
      developmentFollowUpOverdueCount:
          interventionOutcomeFollowUpSummary.overdueCount,
      developmentFollowUpEscalatedCount:
          interventionOutcomeFollowUpSummary.escalatedCount,
      developmentFollowUpResolutionAttentionCount:
          interventionOutcomeFollowUpResolutionSummary.attentionCount,
      developmentFollowUpResolutionEscalatedCount:
          interventionOutcomeFollowUpResolutionSummary.escalateCount,
      averageDevelopmentFollowUpResolutionConfidence:
          interventionOutcomeFollowUpResolutionSummary.averageConfidenceAfter,
      totalCareerPaths: careerPathSummary.totalCount,
      blockedCareerPaths: careerPathSummary.blockedCount,
      criticalCareerPaths: careerPathSummary.criticalCount,
      averageCareerPathGap: careerPathSummary.averageGap,
      totalCareerSupportActions: supportActionSummary.totalCount,
      openCareerSupportActions: supportActionSummary.openCount,
      criticalCareerSupportActions: supportActionSummary.criticalCount,
      dueCareerSupportActions: supportActionSummary.dueSoonCount,
      totalCareerSupportOutcomes: supportOutcomeSummary.totalCount,
      monitorCareerSupportOutcomes: supportOutcomeSummary.monitorCount,
      escalatedCareerSupportOutcomes: supportOutcomeSummary.escalateCount,
      averageCareerSupportOutcomeLevel:
          supportOutcomeSummary.averageVerifiedLevel,
      totalProgramMilestones: milestoneSummary.totalCount,
      programMilestoneRevisions: milestoneSummary.revisionCount,
      dueProgramMilestones: milestoneSummary.dueSoonCount,
      averageProgramMilestoneScore: milestoneSummary.averageScore,
      totalProgramCompletions: completionSummary.totalCount,
      roleReadyProgramCompletions: completionSummary.roleReadyCount,
      programCompletionExtensions: completionSummary.extensionCount,
      renewalDueProgramCompletions: completionSummary.renewalDueCount,
      averageProgramCompletionScore: completionSummary.averageScore,
      totalPromotionStabilizationReviews:
          promotionStabilizationSummary.totalCount,
      promotionStabilizationAttentionCount:
          promotionStabilizationSummary.attentionCount,
      promotionStabilizationEscalatedCount:
          promotionStabilizationSummary.escalatedCount,
      promotionStabilizationDueFollowUps:
          promotionStabilizationSummary.dueFollowUpCount,
      averagePromotionStabilizationConfidence:
          promotionStabilizationSummary.averageConfidence,
      totalPromotionFollowUpActions: promotionFollowUpSummary.totalCount,
      openPromotionFollowUpActions: promotionFollowUpSummary.openCount,
      promotionFollowUpAttentionCount: promotionFollowUpSummary.attentionCount,
      criticalPromotionFollowUpActions: promotionFollowUpSummary.criticalCount,
      promotionFollowUpDueSoonCount: promotionFollowUpSummary.dueSoonCount,
      promotionFollowUpEscalatedCount: promotionFollowUpSummary.escalatedCount,
      averagePromotionFollowUpProgress:
          promotionFollowUpSummary.averageProgress,
      totalPromotionFollowUpResolutions: promotionResolutionSummary.totalCount,
      promotionResolutionAttentionCount:
          promotionResolutionSummary.attentionCount,
      promotionResolutionMonitorCount: promotionResolutionSummary.monitorCount,
      promotionResolutionReopenedCount:
          promotionResolutionSummary.reopenedCount,
      promotionResolutionEscalatedCount:
          promotionResolutionSummary.escalatedCount,
      averagePromotionResolutionConfidence:
          promotionResolutionSummary.averageConfidenceAfter,
      averagePromotionResolutionConfidenceDelta:
          promotionResolutionSummary.averageConfidenceDelta,
      averageReadinessScore: incomingTalentAverageReadiness(
        roadmapSummary,
        portfolioSummary,
      ),
      averageConfidenceScore: checkInSummary.averageConfidenceScore,
      signals: signals,
      nextAction: incomingTalentHealthNextAction(score, signals),
    );
  }

  double get healthRatio => healthScore / 100;

  int get attentionSignalCount {
    return signals
        .where(
          (signal) =>
              signal.severity != IncomingTalentHealthSignalSeverity.stable,
        )
        .length;
  }
}
