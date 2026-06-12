import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_calibration_models.dart';
import 'incoming_talent_career_path_support_action_models.dart';
import 'incoming_talent_career_path_support_outcome_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention_models.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_models.dart';
import 'incoming_talent_development_intervention_outcome_follow_up_resolution_models.dart';
import 'incoming_talent_development_intervention_outcome_models.dart';
import 'incoming_talent_development_program_models.dart';
import 'incoming_talent_development_roadmap_models.dart';
import 'incoming_talent_profile_timeline.dart';
import 'incoming_talent_profile_timeline_event_factory.dart';
import 'incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'incoming_talent_promotion_stabilization_review_models.dart';

IncomingTalentProfileTimeline buildIncomingTalentProfileTimeline({
  required List<IncomingTalentActivationOutcomeReview> outcomes,
  required List<IncomingTalentDevelopmentRoadmap> roadmaps,
  required List<IncomingTalentDevelopmentCheckIn> checkIns,
  required List<IncomingTalentDevelopmentInterventionAction> interventions,
  required List<IncomingTalentDevelopmentInterventionOutcome>
  interventionOutcomes,
  required List<IncomingTalentDevelopmentInterventionOutcomeFollowUp>
  interventionOutcomeFollowUps,
  required List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
  interventionOutcomeFollowUpResolutions,
  required List<IncomingTalentCalibrationReview> reviews,
  required List<IncomingTalentCareerPathSupportAction> careerSupportActions,
  required List<IncomingTalentCareerPathSupportOutcome> careerSupportOutcomes,
  required List<IncomingTalentDevelopmentProgramMilestone> programMilestones,
  required List<IncomingTalentDevelopmentProgramCompletion> programCompletions,
  required List<IncomingTalentPromotionStabilizationReview>
  promotionStabilizationReviews,
  required List<IncomingTalentPromotionStabilizationFollowUpAction>
  promotionFollowUpActions,
  required List<IncomingTalentPromotionStabilizationFollowUpResolution>
  promotionFollowUpResolutions,
  required DateTime asOfDate,
}) {
  final sortedOutcomes = [...outcomes]
    ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
  final baseOutcome = sortedOutcomes.first;
  final outcomeIds = sortedOutcomes.map((outcome) => outcome.id).toSet();

  final candidateRoadmaps =
      roadmaps
          .where(
            (roadmap) =>
                roadmap.candidateId == baseOutcome.candidateId ||
                outcomeIds.contains(roadmap.outcomeReviewId),
          )
          .toList();
  final candidateCheckIns =
      checkIns
          .where(
            (checkIn) =>
                checkIn.candidateId == baseOutcome.candidateId ||
                outcomeIds.contains(checkIn.outcomeReviewId),
          )
          .toList();
  final candidateInterventions =
      interventions
          .where(
            (action) =>
                action.candidateId == baseOutcome.candidateId ||
                outcomeIds.contains(action.outcomeReviewId),
          )
          .toList();
  final candidateInterventionIds =
      candidateInterventions.map((action) => action.id).toSet();
  final candidateInterventionOutcomes =
      interventionOutcomes
          .where(
            (outcome) =>
                outcome.candidateId == baseOutcome.candidateId ||
                candidateInterventionIds.contains(outcome.interventionId),
          )
          .toList();
  final candidateInterventionOutcomeIds =
      candidateInterventionOutcomes.map((outcome) => outcome.id).toSet();
  final candidateInterventionOutcomeFollowUps =
      interventionOutcomeFollowUps
          .where(
            (followUp) =>
                followUp.candidateId == baseOutcome.candidateId ||
                candidateInterventionOutcomeIds.contains(followUp.outcomeId),
          )
          .toList();
  final candidateInterventionOutcomeFollowUpIds =
      candidateInterventionOutcomeFollowUps
          .map((followUp) => followUp.id)
          .toSet();
  final candidateInterventionOutcomeFollowUpResolutions =
      interventionOutcomeFollowUpResolutions
          .where(
            (resolution) =>
                resolution.candidateId == baseOutcome.candidateId ||
                candidateInterventionOutcomeFollowUpIds.contains(
                  resolution.followUpId,
                ) ||
                candidateInterventionOutcomeIds.contains(resolution.outcomeId),
          )
          .toList();
  final reviewedInterventionOutcomeFollowUpIds =
      candidateInterventionOutcomeFollowUpResolutions
          .map((resolution) => resolution.followUpId)
          .toSet();
  final candidateReviews =
      reviews
          .where(
            (review) =>
                review.candidateId == baseOutcome.candidateId ||
                outcomeIds.contains(review.outcomeReviewId),
          )
          .toList();
  final candidateSupportActions =
      careerSupportActions
          .where((action) => action.candidateId == baseOutcome.candidateId)
          .toList();
  final candidateSupportOutcomes =
      careerSupportOutcomes
          .where((outcome) => outcome.candidateId == baseOutcome.candidateId)
          .toList();
  final candidateProgramMilestones =
      programMilestones
          .where(
            (milestone) => milestone.candidateId == baseOutcome.candidateId,
          )
          .toList();
  final candidateProgramCompletions =
      programCompletions
          .where(
            (completion) => completion.candidateId == baseOutcome.candidateId,
          )
          .toList();
  final candidatePromotionStabilizationReviews =
      promotionStabilizationReviews
          .where((review) => review.candidateId == baseOutcome.candidateId)
          .toList();
  final candidatePromotionStabilizationReviewIds =
      candidatePromotionStabilizationReviews.map((review) => review.id).toSet();
  final candidatePromotionFollowUpActions =
      promotionFollowUpActions
          .where(
            (action) =>
                action.candidateId == baseOutcome.candidateId ||
                candidatePromotionStabilizationReviewIds.contains(
                  action.reviewId,
                ),
          )
          .toList();
  final candidatePromotionFollowUpActionIds =
      candidatePromotionFollowUpActions.map((action) => action.id).toSet();
  final candidatePromotionFollowUpResolutions =
      promotionFollowUpResolutions
          .where(
            (resolution) =>
                resolution.candidateId == baseOutcome.candidateId ||
                candidatePromotionFollowUpActionIds.contains(
                  resolution.actionId,
                ) ||
                candidatePromotionStabilizationReviewIds.contains(
                  resolution.reviewId,
                ),
          )
          .toList();
  final reviewedPromotionFollowUpActionIds =
      candidatePromotionFollowUpResolutions
          .map((resolution) => resolution.actionId)
          .toSet();

  final latestCheckIn = latestProfileTimelineItemByDate(
    candidateCheckIns,
    (checkIn) => checkIn.checkInDate,
  );
  final latestReview = latestProfileTimelineItemByDate(
    candidateReviews,
    (review) => review.reviewDate,
  );
  final openInterventionCount =
      candidateInterventions.where(isOpenProfileTimelineIntervention).length;
  final watchDevelopmentOutcomeCount =
      candidateInterventionOutcomes
          .where((outcome) => outcome.needsAttention)
          .length;
  final openDevelopmentFollowUpCount =
      candidateInterventionOutcomeFollowUps
          .where(
            (followUp) =>
                !followUp.isClosed &&
                !reviewedInterventionOutcomeFollowUpIds.contains(followUp.id),
          )
          .length;
  final watchDevelopmentFollowUpCount =
      candidateInterventionOutcomeFollowUps
          .where(
            (followUp) =>
                followUp.needsAttention(asOfDate) &&
                !reviewedInterventionOutcomeFollowUpIds.contains(followUp.id),
          )
          .length;
  final watchDevelopmentResolutionCount =
      candidateInterventionOutcomeFollowUpResolutions
          .where((resolution) => resolution.needsAttention)
          .length;
  final openCareerSupportCount =
      candidateSupportActions
          .where(isOpenProfileTimelineCareerSupportAction)
          .length;
  final watchCareerSupportOutcomeCount =
      candidateSupportOutcomes
          .where((outcome) => outcome.needsAttention)
          .length;
  final programMilestoneRevisionCount =
      candidateProgramMilestones
          .where(
            (milestone) =>
                milestone.status ==
                IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision,
          )
          .length;
  final programCompletionExtensionCount =
      candidateProgramCompletions
          .where(
            (completion) =>
                completion.decision ==
                IncomingTalentDevelopmentProgramCompletionDecision
                    .extendProgram,
          )
          .length;
  final watchPromotionStabilizationCount =
      candidatePromotionStabilizationReviews
          .where((review) => review.needsAttention)
          .length;
  final openPromotionFollowUpCount =
      candidatePromotionFollowUpActions
          .where(
            (action) =>
                isOpenProfileTimelinePromotionFollowUpAction(action) &&
                !reviewedPromotionFollowUpActionIds.contains(action.id),
          )
          .length;
  final watchPromotionFollowUpCount =
      candidatePromotionFollowUpActions
          .where(
            (action) =>
                action.needsAttention &&
                !reviewedPromotionFollowUpActionIds.contains(action.id),
          )
          .length;
  final watchPromotionResolutionCount =
      candidatePromotionFollowUpResolutions
          .where((resolution) => resolution.needsAttention)
          .length;
  final events = [
    for (final outcome in sortedOutcomes) profileTimelineOutcomeEvent(outcome),
    for (final roadmap in candidateRoadmaps)
      profileTimelineRoadmapEvent(roadmap),
    for (final checkIn in candidateCheckIns)
      profileTimelineCheckInEvent(checkIn),
    for (final action in candidateInterventions)
      profileTimelineInterventionEvent(action),
    for (final outcome in candidateInterventionOutcomes)
      profileTimelineInterventionOutcomeEvent(outcome),
    for (final followUp in candidateInterventionOutcomeFollowUps)
      profileTimelineInterventionOutcomeFollowUpEvent(followUp),
    for (final resolution in candidateInterventionOutcomeFollowUpResolutions)
      profileTimelineInterventionOutcomeFollowUpResolutionEvent(resolution),
    for (final review in candidateReviews)
      profileTimelineCalibrationEvent(review),
    for (final action in candidateSupportActions)
      profileTimelineCareerSupportActionEvent(action),
    for (final outcome in candidateSupportOutcomes)
      profileTimelineCareerSupportOutcomeEvent(outcome),
    for (final milestone in candidateProgramMilestones)
      profileTimelineProgramMilestoneEvent(milestone),
    for (final completion in candidateProgramCompletions)
      profileTimelineProgramCompletionEvent(completion),
    for (final review in candidatePromotionStabilizationReviews)
      profileTimelinePromotionStabilizationEvent(review),
    for (final action in candidatePromotionFollowUpActions)
      profileTimelinePromotionFollowUpEvent(action),
    for (final resolution in candidatePromotionFollowUpResolutions)
      profileTimelinePromotionFollowUpResolutionEvent(resolution),
  ]..sort((a, b) => b.eventDate.compareTo(a.eventDate));

  return IncomingTalentProfileTimeline(
    candidateId: baseOutcome.candidateId,
    candidateName: baseOutcome.candidateName,
    role: baseOutcome.role,
    department: baseOutcome.department,
    readinessScore: baseOutcome.readinessScore,
    confidenceScore:
        latestCheckIn?.confidenceScore ??
        profileTimelineReadinessToConfidence(baseOutcome.readinessScore),
    openInterventionCount: openInterventionCount,
    watchDevelopmentOutcomeCount: watchDevelopmentOutcomeCount,
    openDevelopmentFollowUpCount: openDevelopmentFollowUpCount,
    watchDevelopmentFollowUpCount: watchDevelopmentFollowUpCount,
    watchDevelopmentResolutionCount: watchDevelopmentResolutionCount,
    openCareerSupportCount: openCareerSupportCount,
    watchCareerSupportOutcomeCount: watchCareerSupportOutcomeCount,
    programMilestoneRevisionCount: programMilestoneRevisionCount,
    programCompletionExtensionCount: programCompletionExtensionCount,
    watchPromotionStabilizationCount: watchPromotionStabilizationCount,
    openPromotionFollowUpCount: openPromotionFollowUpCount,
    watchPromotionFollowUpCount: watchPromotionFollowUpCount,
    watchPromotionResolutionCount: watchPromotionResolutionCount,
    latestCalibrationDecisionLabel:
        latestReview?.decision.label ?? 'Not calibrated',
    nextAction: profileTimelineNextAction(
      latestReview: latestReview,
      latestCheckIn: latestCheckIn,
      roadmaps: candidateRoadmaps,
      openInterventionCount: openInterventionCount,
      watchDevelopmentOutcomeCount: watchDevelopmentOutcomeCount,
      openDevelopmentFollowUpCount: openDevelopmentFollowUpCount,
      watchDevelopmentFollowUpCount: watchDevelopmentFollowUpCount,
      watchDevelopmentResolutionCount: watchDevelopmentResolutionCount,
      openCareerSupportCount: openCareerSupportCount,
      watchCareerSupportOutcomeCount: watchCareerSupportOutcomeCount,
      programMilestoneRevisionCount: programMilestoneRevisionCount,
      programCompletionExtensionCount: programCompletionExtensionCount,
      watchPromotionStabilizationCount: watchPromotionStabilizationCount,
      openPromotionFollowUpCount: openPromotionFollowUpCount,
      watchPromotionFollowUpCount: watchPromotionFollowUpCount,
      watchPromotionResolutionCount: watchPromotionResolutionCount,
    ),
    events: events,
  );
}

String profileTimelineNextAction({
  required IncomingTalentCalibrationReview? latestReview,
  required IncomingTalentDevelopmentCheckIn? latestCheckIn,
  required List<IncomingTalentDevelopmentRoadmap> roadmaps,
  required int openInterventionCount,
  required int watchDevelopmentOutcomeCount,
  required int openDevelopmentFollowUpCount,
  required int watchDevelopmentFollowUpCount,
  required int watchDevelopmentResolutionCount,
  required int openCareerSupportCount,
  required int watchCareerSupportOutcomeCount,
  required int programMilestoneRevisionCount,
  required int programCompletionExtensionCount,
  required int watchPromotionStabilizationCount,
  required int openPromotionFollowUpCount,
  required int watchPromotionFollowUpCount,
  required int watchPromotionResolutionCount,
}) {
  if (openInterventionCount > 0) {
    final noun = openInterventionCount == 1 ? 'intervention' : 'interventions';
    return 'Close $openInterventionCount open $noun.';
  }
  if (watchDevelopmentResolutionCount > 0) {
    final noun = watchDevelopmentResolutionCount == 1 ? 'review' : 'reviews';
    return 'Resolve $watchDevelopmentResolutionCount intervention follow-up resolution $noun.';
  }
  if (watchDevelopmentFollowUpCount > 0) {
    final noun =
        watchDevelopmentFollowUpCount == 1 ? 'follow-up' : 'follow-ups';
    return 'Resolve $watchDevelopmentFollowUpCount intervention outcome $noun.';
  }
  if (openDevelopmentFollowUpCount > 0) {
    final noun = openDevelopmentFollowUpCount == 1 ? 'follow-up' : 'follow-ups';
    return 'Close $openDevelopmentFollowUpCount intervention outcome $noun.';
  }
  if (watchDevelopmentOutcomeCount > 0) {
    final noun = watchDevelopmentOutcomeCount == 1 ? 'outcome' : 'outcomes';
    return 'Follow up $watchDevelopmentOutcomeCount development intervention $noun.';
  }
  if (openCareerSupportCount > 0) {
    final noun = openCareerSupportCount == 1 ? 'action' : 'actions';
    return 'Close $openCareerSupportCount career support $noun.';
  }
  if (programMilestoneRevisionCount > 0) {
    final noun = programMilestoneRevisionCount == 1 ? 'revision' : 'revisions';
    return 'Resolve $programMilestoneRevisionCount program milestone $noun.';
  }
  if (programCompletionExtensionCount > 0) {
    final noun =
        programCompletionExtensionCount == 1 ? 'decision' : 'decisions';
    return 'Resolve $programCompletionExtensionCount program extension $noun.';
  }
  if (watchPromotionFollowUpCount > 0) {
    final noun = watchPromotionFollowUpCount == 1 ? 'action' : 'actions';
    return 'Resolve $watchPromotionFollowUpCount promotion follow-up $noun.';
  }
  if (openPromotionFollowUpCount > 0) {
    final noun = openPromotionFollowUpCount == 1 ? 'action' : 'actions';
    return 'Close $openPromotionFollowUpCount promotion follow-up $noun.';
  }
  if (watchPromotionResolutionCount > 0) {
    final noun = watchPromotionResolutionCount == 1 ? 'review' : 'reviews';
    return 'Resolve $watchPromotionResolutionCount promotion resolution $noun.';
  }
  if (watchPromotionStabilizationCount > 0) {
    final noun = watchPromotionStabilizationCount == 1 ? 'review' : 'reviews';
    return 'Resolve $watchPromotionStabilizationCount promotion stabilization $noun.';
  }
  if (watchCareerSupportOutcomeCount > 0) {
    return 'Follow up $watchCareerSupportOutcomeCount career support outcomes.';
  }
  if (latestReview == null) {
    return 'Schedule calibration review.';
  }
  if (latestReview.needsAttention) {
    return 'Follow up ${latestReview.decision.label.toLowerCase()} decision.';
  }
  if (latestCheckIn != null && latestCheckIn.needsAttention) {
    return latestCheckIn.nextAction;
  }
  final latestRoadmap = latestProfileTimelineItemByDate(
    roadmaps,
    (roadmap) => roadmap.startDate,
  );
  if (latestRoadmap != null && latestRoadmap.needsAttention) {
    return 'Stabilize ${latestRoadmap.focusArea}.';
  }
  return 'Maintain development cadence.';
}

int profileTimelineReadinessToConfidence(int readinessScore) {
  final confidence = (readinessScore / 20).round();
  if (confidence < 1) return 1;
  if (confidence > 5) return 5;
  return confidence;
}

T? latestProfileTimelineItemByDate<T>(
  List<T> items,
  DateTime Function(T item) dateOf,
) {
  if (items.isEmpty) return null;
  final sortedItems = [...items]
    ..sort((a, b) => dateOf(b).compareTo(dateOf(a)));
  return sortedItems.first;
}

int compareIncomingTalentProfileTimelines(
  IncomingTalentProfileTimeline a,
  IncomingTalentProfileTimeline b,
) {
  final attentionCompare = (b.needsAttention ? 1 : 0).compareTo(
    a.needsAttention ? 1 : 0,
  );
  if (attentionCompare != 0) return attentionCompare;
  final actionCompare = b.openTalentActionCount.compareTo(
    a.openTalentActionCount,
  );
  if (actionCompare != 0) return actionCompare;
  final latestDateCompare = (b.latestEventDate ?? DateTime(1900)).compareTo(
    a.latestEventDate ?? DateTime(1900),
  );
  if (latestDateCompare != 0) return latestDateCompare;
  return a.candidateName.compareTo(b.candidateName);
}
