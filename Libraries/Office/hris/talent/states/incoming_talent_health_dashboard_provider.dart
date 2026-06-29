import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_health_dashboard_models.dart';
import 'incoming_talent_career_path_provider.dart';
import 'incoming_talent_career_path_support_action_provider.dart';
import 'incoming_talent_career_path_support_outcome_provider.dart';
import 'incoming_talent_development_check_in_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'incoming_talent_development_intervention_outcome_provider.dart';
import 'incoming_talent_development_intervention_provider.dart';
import 'incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_program_completion_provider.dart';
import 'incoming_talent_development_program_milestone_provider.dart';
import 'incoming_talent_development_roadmap_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'incoming_talent_promotion_stabilization_review_provider.dart';

final incomingTalentHealthDashboardProvider = Provider<
  IncomingTalentHealthDashboard
>((ref) {
  return IncomingTalentHealthDashboard.fromSummaries(
    roadmapSummary: ref.watch(incomingTalentDevelopmentRoadmapSummaryProvider),
    portfolioSummary: ref.watch(
      incomingTalentDevelopmentPortfolioSummaryProvider,
    ),
    careerPathSummary: ref.watch(incomingTalentCareerPathSummaryProvider),
    supportActionSummary: ref.watch(
      incomingTalentCareerPathSupportActionSummaryProvider,
    ),
    supportOutcomeSummary: ref.watch(
      incomingTalentCareerPathSupportOutcomeSummaryProvider,
    ),
    milestoneSummary: ref.watch(
      incomingTalentDevelopmentProgramMilestoneSummaryProvider,
    ),
    completionSummary: ref.watch(
      incomingTalentDevelopmentProgramCompletionSummaryProvider,
    ),
    checkInSummary: ref.watch(incomingTalentDevelopmentCheckInSummaryProvider),
    interventionSummary: ref.watch(
      incomingTalentDevelopmentInterventionSummaryProvider,
    ),
    interventionOutcomeSummary: ref.watch(
      incomingTalentDevelopmentInterventionOutcomeSummaryProvider,
    ),
    interventionOutcomeFollowUpSummary: ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpSummaryProvider,
    ),
    interventionOutcomeFollowUpResolutionSummary: ref.watch(
      incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummaryProvider,
    ),
    promotionStabilizationSummary: ref.watch(
      incomingTalentPromotionStabilizationReviewSummaryProvider,
    ),
    promotionFollowUpSummary: ref.watch(
      incomingTalentPromotionStabilizationFollowUpActionSummaryProvider,
    ),
    promotionResolutionSummary: ref.watch(
      incomingTalentPromotionStabilizationFollowUpResolutionSummaryProvider,
    ),
  );
});
