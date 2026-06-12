import 'incoming_talent_development_intervention_outcome.dart';
import 'incoming_talent_development_intervention_outcome_draft.dart';

extension IncomingTalentDevelopmentInterventionOutcomeDraftCopy
    on IncomingTalentDevelopmentInterventionOutcomeDraft {
  IncomingTalentDevelopmentInterventionOutcomeDraft copyWith({
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentDevelopmentInterventionOutcomeDecision? decision,
    int? confidenceAfter,
    int? remainingReleaseRiskCount,
    String? evidenceSummary,
    String? learningSummary,
    String? nextAction,
    DateTime? nextReviewDate,
  }) {
    return IncomingTalentDevelopmentInterventionOutcomeDraft(
      interventionId: interventionId,
      checkInId: checkInId,
      activationFollowUpId: activationFollowUpId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      ownerName: ownerName,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      source: source,
      interventionType: interventionType,
      priority: priority,
      confidenceBefore: confidenceBefore,
      confidenceAfter: confidenceAfter ?? this.confidenceAfter,
      releaseEvidenceCount: releaseEvidenceCount,
      remainingReleaseRiskCount:
          remainingReleaseRiskCount ?? this.remainingReleaseRiskCount,
      decision: decision ?? this.decision,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      learningSummary: learningSummary ?? this.learningSummary,
      nextAction: nextAction ?? this.nextAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate,
    );
  }
}
