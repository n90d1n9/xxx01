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
import 'incoming_talent_promotion_stabilization_follow_up_action_models.dart';
import 'incoming_talent_promotion_stabilization_follow_up_resolution_models.dart';
import 'incoming_talent_promotion_stabilization_review_models.dart';

IncomingTalentProfileTimelineEvent profileTimelineOutcomeEvent(
  IncomingTalentActivationOutcomeReview outcome,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'outcome:${outcome.id}',
    candidateId: outcome.candidateId,
    candidateName: outcome.candidateName,
    role: outcome.role,
    department: outcome.department,
    type: IncomingTalentProfileTimelineEventType.outcome,
    tone: _outcomeTone(outcome),
    title: outcome.decision.label,
    description: outcome.decisionNote,
    eventDate: outcome.reviewDate,
    statusLabel: outcome.retentionRisk.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineRoadmapEvent(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'roadmap:${roadmap.id}',
    candidateId: roadmap.candidateId,
    candidateName: roadmap.candidateName,
    role: roadmap.role,
    department: roadmap.department,
    type: IncomingTalentProfileTimelineEventType.roadmap,
    tone: _roadmapTone(roadmap),
    title: roadmap.focusArea,
    description: roadmap.learningObjective,
    eventDate: roadmap.startDate,
    statusLabel: roadmap.status.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineCheckInEvent(
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'check-in:${checkIn.id}',
    candidateId: checkIn.candidateId,
    candidateName: checkIn.candidateName,
    role: checkIn.role,
    department: checkIn.department,
    type: IncomingTalentProfileTimelineEventType.checkIn,
    tone: _checkInTone(checkIn),
    title: checkIn.trend.label,
    description:
        checkIn.blockerNote.isEmpty ? checkIn.nextAction : checkIn.blockerNote,
    eventDate: checkIn.checkInDate,
    statusLabel: '${checkIn.confidenceScore}/5 confidence',
  );
}

IncomingTalentProfileTimelineEvent profileTimelineInterventionEvent(
  IncomingTalentDevelopmentInterventionAction action,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'intervention:${action.id}',
    candidateId: action.candidateId,
    candidateName: action.candidateName,
    role: action.role,
    department: action.department,
    type: IncomingTalentProfileTimelineEventType.intervention,
    tone: _interventionTone(action),
    title: action.actionType.label,
    description: action.action,
    eventDate: action.dueDate,
    statusLabel: action.status.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineInterventionOutcomeEvent(
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'intervention-outcome:${outcome.id}',
    candidateId: outcome.candidateId,
    candidateName: outcome.candidateName,
    role: outcome.role,
    department: outcome.department,
    type: IncomingTalentProfileTimelineEventType.interventionOutcome,
    tone: _interventionOutcomeTone(outcome),
    title: outcome.decision.label,
    description:
        outcome.nextAction.isEmpty
            ? outcome.learningSummary
            : outcome.nextAction,
    eventDate: outcome.reviewDate,
    statusLabel: '${outcome.confidenceAfter}/5 confidence',
  );
}

IncomingTalentProfileTimelineEvent
profileTimelineInterventionOutcomeFollowUpEvent(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'intervention-outcome-follow-up:${followUp.id}',
    candidateId: followUp.candidateId,
    candidateName: followUp.candidateName,
    role: followUp.role,
    department: followUp.department,
    type: IncomingTalentProfileTimelineEventType.interventionOutcomeFollowUp,
    tone: _interventionOutcomeFollowUpTone(followUp),
    title: followUp.status.label,
    description: followUp.action,
    eventDate: followUp.completedAt ?? followUp.dueDate,
    statusLabel: followUp.sourceDecision.label,
  );
}

IncomingTalentProfileTimelineEvent
profileTimelineInterventionOutcomeFollowUpResolutionEvent(
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution resolution,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'intervention-outcome-follow-up-resolution:${resolution.id}',
    candidateId: resolution.candidateId,
    candidateName: resolution.candidateName,
    role: resolution.role,
    department: resolution.department,
    type:
        IncomingTalentProfileTimelineEventType
            .interventionOutcomeFollowUpResolution,
    tone: _interventionOutcomeFollowUpResolutionTone(resolution),
    title: resolution.decision.label,
    description:
        resolution.nextAction.isEmpty
            ? resolution.evidenceSummary
            : resolution.nextAction,
    eventDate: resolution.reviewDate,
    statusLabel: '${resolution.confidenceAfter}/5 confidence',
  );
}

IncomingTalentProfileTimelineEvent profileTimelineCalibrationEvent(
  IncomingTalentCalibrationReview review,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'calibration:${review.id}',
    candidateId: review.candidateId,
    candidateName: review.candidateName,
    role: review.role,
    department: review.department,
    type: IncomingTalentProfileTimelineEventType.calibration,
    tone: _calibrationTone(review),
    title: review.decision.label,
    description: review.decisionNote,
    eventDate: review.reviewDate,
    statusLabel: review.potential.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineCareerSupportActionEvent(
  IncomingTalentCareerPathSupportAction action,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'career-support:${action.id}',
    candidateId: action.candidateId,
    candidateName: action.candidateName,
    role: action.targetRole,
    department: action.department,
    type: IncomingTalentProfileTimelineEventType.careerSupportAction,
    tone: _careerSupportActionTone(action),
    title: action.actionType.label,
    description: action.actionPlan,
    eventDate: action.dueDate,
    statusLabel: action.status.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineCareerSupportOutcomeEvent(
  IncomingTalentCareerPathSupportOutcome outcome,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'career-support-outcome:${outcome.id}',
    candidateId: outcome.candidateId,
    candidateName: outcome.candidateName,
    role: outcome.targetRole,
    department: outcome.department,
    type: IncomingTalentProfileTimelineEventType.careerSupportOutcome,
    tone: _careerSupportOutcomeTone(outcome),
    title: outcome.decision.label,
    description: outcome.nextReviewAction,
    eventDate: outcome.outcomeDate,
    statusLabel: outcome.residualRisk.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineProgramMilestoneEvent(
  IncomingTalentDevelopmentProgramMilestone milestone,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'program-milestone:${milestone.id}',
    candidateId: milestone.candidateId,
    candidateName: milestone.candidateName,
    role: milestone.role,
    department: milestone.department,
    type: IncomingTalentProfileTimelineEventType.programMilestone,
    tone: _programMilestoneTone(milestone),
    title: milestone.title,
    description: milestone.reviewNotes,
    eventDate:
        milestone.reviewedAt ?? milestone.submittedAt ?? milestone.dueDate,
    statusLabel: milestone.status.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelineProgramCompletionEvent(
  IncomingTalentDevelopmentProgramCompletion completion,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'program-completion:${completion.id}',
    candidateId: completion.candidateId,
    candidateName: completion.candidateName,
    role: completion.role,
    department: completion.department,
    type: IncomingTalentProfileTimelineEventType.programCompletion,
    tone: _programCompletionTone(completion),
    title: completion.decision.label,
    description: completion.managerRecommendation,
    eventDate: completion.completedAt,
    statusLabel: completion.credentialLevel.label,
  );
}

IncomingTalentProfileTimelineEvent profileTimelinePromotionStabilizationEvent(
  IncomingTalentPromotionStabilizationReview review,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'promotion-stabilization:${review.id}',
    candidateId: review.candidateId,
    candidateName: review.candidateName,
    role: review.newRole,
    department: review.department,
    type: IncomingTalentProfileTimelineEventType.promotionStabilization,
    tone: _promotionStabilizationTone(review),
    title: review.outcome.label,
    description: review.supportPlan,
    eventDate: review.reviewDate,
    statusLabel: '${review.confidenceScore}/5 confidence',
  );
}

IncomingTalentProfileTimelineEvent profileTimelinePromotionFollowUpEvent(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'promotion-follow-up:${action.id}',
    candidateId: action.candidateId,
    candidateName: action.candidateName,
    role: action.newRole,
    department: action.department,
    type: IncomingTalentProfileTimelineEventType.promotionFollowUp,
    tone: _promotionFollowUpTone(action),
    title: action.actionType.label,
    description:
        action.isClosed && action.resolutionNote.isNotEmpty
            ? action.resolutionNote
            : action.actionPlan,
    eventDate: action.dueDate,
    statusLabel: action.status.label,
  );
}

IncomingTalentProfileTimelineEvent
profileTimelinePromotionFollowUpResolutionEvent(
  IncomingTalentPromotionStabilizationFollowUpResolution resolution,
) {
  return IncomingTalentProfileTimelineEvent(
    id: 'promotion-follow-up-resolution:${resolution.id}',
    candidateId: resolution.candidateId,
    candidateName: resolution.candidateName,
    role: resolution.newRole,
    department: resolution.department,
    type: IncomingTalentProfileTimelineEventType.promotionFollowUpResolution,
    tone: _promotionFollowUpResolutionTone(resolution),
    title: resolution.outcome.label,
    description:
        resolution.nextAction.isEmpty
            ? resolution.evidenceSummary
            : resolution.nextAction,
    eventDate: resolution.reviewDate,
    statusLabel: '${resolution.confidenceAfter}/5 confidence',
  );
}

bool isOpenProfileTimelineIntervention(
  IncomingTalentDevelopmentInterventionAction action,
) {
  return action.status == IncomingTalentDevelopmentInterventionStatus.open ||
      action.status == IncomingTalentDevelopmentInterventionStatus.inProgress;
}

bool isOpenProfileTimelineCareerSupportAction(
  IncomingTalentCareerPathSupportAction action,
) {
  return action.status == IncomingTalentCareerPathSupportActionStatus.open ||
      action.status == IncomingTalentCareerPathSupportActionStatus.inProgress;
}

bool isOpenProfileTimelinePromotionFollowUpAction(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  return action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.open ||
      action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.inProgress;
}

IncomingTalentProfileTimelineEventTone _outcomeTone(
  IncomingTalentActivationOutcomeReview outcome,
) {
  if (outcome.decision ==
          IncomingTalentActivationOutcomeDecision.escalateRisk ||
      outcome.retentionRisk == IncomingTalentActivationRetentionRisk.high) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (outcome.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.positive;
}

IncomingTalentProfileTimelineEventTone _roadmapTone(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.atRisk) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (roadmap.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.completed) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _checkInTone(
  IncomingTalentDevelopmentCheckIn checkIn,
) {
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.blocked) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (checkIn.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (checkIn.trend == IncomingTalentDevelopmentCheckInTrend.improving) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _interventionTone(
  IncomingTalentDevelopmentInterventionAction action,
) {
  if (action.status == IncomingTalentDevelopmentInterventionStatus.resolved) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  if (action.priority ==
      IncomingTalentDevelopmentInterventionPriority.critical) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (action.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _interventionOutcomeTone(
  IncomingTalentDevelopmentInterventionOutcome outcome,
) {
  if (outcome.decision ==
      IncomingTalentDevelopmentInterventionOutcomeDecision.escalate) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (outcome.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (outcome.decision ==
          IncomingTalentDevelopmentInterventionOutcomeDecision.improved ||
      outcome.decision ==
          IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _interventionOutcomeFollowUpTone(
  IncomingTalentDevelopmentInterventionOutcomeFollowUp followUp,
) {
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.escalated) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.completed) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  if (followUp.remainingReleaseRiskCount > 0 ||
      followUp.sourceDecision ==
          IncomingTalentDevelopmentInterventionOutcomeDecision.escalate) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (followUp.status ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus.inProgress) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone
_interventionOutcomeFollowUpResolutionTone(
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution resolution,
) {
  if (resolution.decision ==
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
          .escalate) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (resolution.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.positive;
}

IncomingTalentProfileTimelineEventTone _calibrationTone(
  IncomingTalentCalibrationReview review,
) {
  if (review.decision ==
      IncomingTalentCalibrationDecision.retentionEscalation) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (review.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (review.decision == IncomingTalentCalibrationDecision.accelerateGrowth) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _careerSupportActionTone(
  IncomingTalentCareerPathSupportAction action,
) {
  if (action.status == IncomingTalentCareerPathSupportActionStatus.resolved) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  if (action.priority ==
      IncomingTalentCareerPathSupportActionPriority.critical) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (action.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _careerSupportOutcomeTone(
  IncomingTalentCareerPathSupportOutcome outcome,
) {
  if (outcome.decision ==
      IncomingTalentCareerPathSupportOutcomeDecision.escalate) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (outcome.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.positive;
}

IncomingTalentProfileTimelineEventTone _programMilestoneTone(
  IncomingTalentDevelopmentProgramMilestone milestone,
) {
  if (milestone.status ==
      IncomingTalentDevelopmentProgramMilestoneStatus.accepted) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  if (milestone.status ==
      IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (milestone.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _programCompletionTone(
  IncomingTalentDevelopmentProgramCompletion completion,
) {
  if (completion.decision ==
      IncomingTalentDevelopmentProgramCompletionDecision.extendProgram) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (completion.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (completion.decision ==
          IncomingTalentDevelopmentProgramCompletionDecision.roleReady ||
      completion.decision ==
          IncomingTalentDevelopmentProgramCompletionDecision.credentialed) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _promotionStabilizationTone(
  IncomingTalentPromotionStabilizationReview review,
) {
  if (review.status == IncomingTalentPromotionStabilizationStatus.escalated ||
      review.outcome == IncomingTalentPromotionStabilizationOutcome.roleReset) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (review.needsAttention) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  if (review.status == IncomingTalentPromotionStabilizationStatus.closed ||
      review.outcome ==
          IncomingTalentPromotionStabilizationOutcome.stableInRole) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _promotionFollowUpTone(
  IncomingTalentPromotionStabilizationFollowUpAction action,
) {
  if (action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.escalated ||
      action.priority ==
          IncomingTalentPromotionStabilizationFollowUpPriority.critical) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (action.status ==
      IncomingTalentPromotionStabilizationFollowUpStatus.resolved) {
    return IncomingTalentProfileTimelineEventTone.positive;
  }
  if (action.needsAttention ||
      action.status ==
          IncomingTalentPromotionStabilizationFollowUpStatus.inProgress) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.neutral;
}

IncomingTalentProfileTimelineEventTone _promotionFollowUpResolutionTone(
  IncomingTalentPromotionStabilizationFollowUpResolution resolution,
) {
  if (resolution.outcome ==
          IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
              .peoplePanelEscalation ||
      resolution.outcome ==
          IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
              .reopenFollowUp) {
    return IncomingTalentProfileTimelineEventTone.critical;
  }
  if (resolution.needsAttention ||
      resolution.outcome ==
          IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
              .monitor) {
    return IncomingTalentProfileTimelineEventTone.watch;
  }
  return IncomingTalentProfileTimelineEventTone.positive;
}
