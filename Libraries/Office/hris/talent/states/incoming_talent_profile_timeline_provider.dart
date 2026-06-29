import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incoming_talent_activation_outcome_models.dart';
import '../models/incoming_talent_profile_timeline_models.dart';
import 'incoming_talent_activation_outcome_provider.dart';
import 'incoming_talent_calibration_provider.dart';
import 'incoming_talent_career_path_support_action_provider.dart';
import 'incoming_talent_career_path_support_outcome_provider.dart';
import 'incoming_talent_development_check_in_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_provider.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_provider.dart';
import 'incoming_talent_development_intervention_outcome_provider.dart';
import 'incoming_talent_development_intervention_provider.dart';
import 'incoming_talent_development_program_completion_provider.dart';
import 'incoming_talent_development_program_milestone_provider.dart';
import 'incoming_talent_development_roadmap_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_provider.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_provider.dart';
import 'incoming_talent_promotion_stabilization_review_provider.dart';
import 'talent_provider.dart';

final incomingTalentProfileTimelinesProvider =
    Provider<List<IncomingTalentProfileTimeline>>((ref) {
      final outcomesByCandidate = _groupOutcomesByCandidate(
        ref.watch(incomingTalentActivationOutcomeReviewsProvider),
      );
      final roadmaps = ref.watch(incomingTalentDevelopmentRoadmapsProvider);
      final checkIns = ref.watch(incomingTalentDevelopmentCheckInsProvider);
      final interventions = ref.watch(
        incomingTalentDevelopmentInterventionsProvider,
      );
      final interventionOutcomes = ref.watch(
        incomingTalentDevelopmentInterventionOutcomesProvider,
      );
      final interventionOutcomeFollowUps = ref.watch(
        incomingTalentDevelopmentInterventionOutcomeFollowUpsProvider,
      );
      final interventionOutcomeFollowUpResolutions = ref.watch(
        incomingTalentDevelopmentInterventionOutcomeFollowUpResolutionsProvider,
      );
      final reviews = ref.watch(incomingTalentCalibrationReviewsProvider);
      final careerSupportActions = ref.watch(
        incomingTalentCareerPathSupportActionsProvider,
      );
      final careerSupportOutcomes = ref.watch(
        incomingTalentCareerPathSupportOutcomesProvider,
      );
      final programMilestones = ref.watch(
        incomingTalentDevelopmentProgramMilestonesProvider,
      );
      final programCompletions = ref.watch(
        incomingTalentDevelopmentProgramCompletionsProvider,
      );
      final promotionStabilizationReviews = ref.watch(
        incomingTalentPromotionStabilizationReviewsProvider,
      );
      final promotionFollowUpActions = ref.watch(
        incomingTalentPromotionStabilizationFollowUpActionsProvider,
      );
      final promotionFollowUpResolutions = ref.watch(
        incomingTalentPromotionStabilizationFollowUpResolutionsProvider,
      );

      final timelines =
          outcomesByCandidate.values
              .map(
                (outcomes) => buildIncomingTalentProfileTimeline(
                  outcomes: outcomes,
                  roadmaps: roadmaps,
                  checkIns: checkIns,
                  interventions: interventions,
                  interventionOutcomes: interventionOutcomes,
                  interventionOutcomeFollowUps: interventionOutcomeFollowUps,
                  interventionOutcomeFollowUpResolutions:
                      interventionOutcomeFollowUpResolutions,
                  reviews: reviews,
                  careerSupportActions: careerSupportActions,
                  careerSupportOutcomes: careerSupportOutcomes,
                  programMilestones: programMilestones,
                  programCompletions: programCompletions,
                  promotionStabilizationReviews: promotionStabilizationReviews,
                  promotionFollowUpActions: promotionFollowUpActions,
                  promotionFollowUpResolutions: promotionFollowUpResolutions,
                  asOfDate: ref.watch(talentAsOfDateProvider),
                ),
              )
              .toList()
            ..sort(compareIncomingTalentProfileTimelines);

      return timelines;
    });

final filteredIncomingTalentProfileTimelinesProvider =
    Provider<List<IncomingTalentProfileTimeline>>((ref) {
      final selectedDepartment = ref.watch(talentDepartmentProvider);
      final attentionOnly = ref.watch(talentNeedsAttentionProvider);

      return ref
          .watch(incomingTalentProfileTimelinesProvider)
          .where(
            (timeline) =>
                (selectedDepartment == talentAllDepartments ||
                    timeline.department == selectedDepartment) &&
                (!attentionOnly || timeline.needsAttention),
          )
          .toList();
    });

final incomingTalentProfileTimelineSummaryProvider =
    Provider<IncomingTalentProfileTimelineSummary>((ref) {
      return IncomingTalentProfileTimelineSummary.fromTimelines(
        ref.watch(filteredIncomingTalentProfileTimelinesProvider),
      );
    });

Map<String, List<IncomingTalentActivationOutcomeReview>>
_groupOutcomesByCandidate(
  List<IncomingTalentActivationOutcomeReview> outcomes,
) {
  final outcomesByCandidate =
      <String, List<IncomingTalentActivationOutcomeReview>>{};
  for (final outcome in outcomes) {
    outcomesByCandidate.putIfAbsent(outcome.candidateId, () => []);
    outcomesByCandidate[outcome.candidateId]!.add(outcome);
  }
  return outcomesByCandidate;
}
