import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';
import 'incoming_talent_career_path_support_outcome.dart';
import 'incoming_talent_career_path_support_outcome_policy.dart';

class IncomingTalentCareerPathSupportOutcomeDraft {
  final String actionId;
  final String reviewId;
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String targetRole;
  final String competencyName;
  final IncomingTalentCareerPathSupportActionType? actionType;
  final IncomingTalentCareerPathSupportActionPriority? actionPriority;
  final IncomingTalentCareerPathSupportActionStatus? actionStatus;
  final String actionOwnerName;
  final String actionPlan;
  final String successCriteria;
  final IncomingTalentCareerPathReviewDecision? sourceDecision;
  final int reviewedLevelBefore;
  final int targetLevel;
  final int sourceLevelGap;
  final String reviewerName;
  final DateTime? outcomeDate;
  final IncomingTalentCareerPathSupportOutcomeDecision? decision;
  final IncomingTalentCareerPathSupportOutcomeResidualRisk? residualRisk;
  final int verifiedLevel;
  final String evidenceSummary;
  final String managerNote;
  final String nextReviewAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentCareerPathSupportOutcomeDraft({
    required this.actionId,
    required this.reviewId,
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.targetRole,
    required this.competencyName,
    required this.actionType,
    required this.actionPriority,
    required this.actionStatus,
    required this.actionOwnerName,
    required this.actionPlan,
    required this.successCriteria,
    required this.sourceDecision,
    required this.reviewedLevelBefore,
    required this.targetLevel,
    required this.sourceLevelGap,
    required this.reviewerName,
    required this.outcomeDate,
    required this.decision,
    required this.residualRisk,
    required this.verifiedLevel,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextReviewAction,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentCareerPathSupportOutcomeDraft.empty(DateTime asOfDate) {
    return IncomingTalentCareerPathSupportOutcomeDraft(
      actionId: '',
      reviewId: '',
      careerPathId: '',
      portfolioId: '',
      roadmapId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      targetRole: '',
      competencyName: '',
      actionType: null,
      actionPriority: null,
      actionStatus: null,
      actionOwnerName: '',
      actionPlan: '',
      successCriteria: '',
      sourceDecision: null,
      reviewedLevelBefore: 0,
      targetLevel: 0,
      sourceLevelGap: 0,
      reviewerName: '',
      outcomeDate: null,
      decision: null,
      residualRisk: null,
      verifiedLevel: 0,
      evidenceSummary: '',
      managerNote: '',
      nextReviewAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCareerPathSupportOutcomeDraft.fromAction({
    required IncomingTalentCareerPathSupportAction action,
    required DateTime asOfDate,
  }) {
    final decision = defaultIncomingTalentCareerPathSupportOutcomeDecision(
      action,
    );

    return IncomingTalentCareerPathSupportOutcomeDraft(
      actionId: action.id,
      reviewId: action.reviewId,
      careerPathId: action.careerPathId,
      portfolioId: action.portfolioId,
      roadmapId: action.roadmapId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      department: action.department,
      targetRole: action.targetRole,
      competencyName: action.competencyName,
      actionType: action.actionType,
      actionPriority: action.priority,
      actionStatus: action.status,
      actionOwnerName: action.ownerName,
      actionPlan: action.actionPlan,
      successCriteria: action.successCriteria,
      sourceDecision: action.sourceDecision,
      reviewedLevelBefore: action.reviewedLevel,
      targetLevel: action.targetLevel,
      sourceLevelGap: action.sourceLevelGap,
      reviewerName: action.ownerName,
      outcomeDate: asOfDate,
      decision: decision,
      residualRisk: defaultIncomingTalentCareerPathSupportOutcomeResidualRisk(
        action,
      ),
      verifiedLevel: defaultIncomingTalentCareerPathSupportOutcomeVerifiedLevel(
        action,
      ),
      evidenceSummary: defaultIncomingTalentCareerPathSupportOutcomeEvidence(
        action,
      ),
      managerNote: defaultIncomingTalentCareerPathSupportOutcomeManagerNote(
        action,
      ),
      nextReviewAction: defaultIncomingTalentCareerPathSupportOutcomeNextAction(
        decision,
      ),
      nextReviewDate:
          defaultIncomingTalentCareerPathSupportOutcomeNextReviewDate(
            decision: decision,
            asOfDate: asOfDate,
          ),
      asOfDate: asOfDate,
    );
  }
}
