import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';
import 'incoming_talent_career_path_support_action_draft.dart';

extension IncomingTalentCareerPathSupportActionDraftCopy
    on IncomingTalentCareerPathSupportActionDraft {
  IncomingTalentCareerPathSupportActionDraft copyWith({
    String? reviewId,
    String? careerPathId,
    String? portfolioId,
    String? roadmapId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? targetRole,
    String? competencyName,
    String? ownerName,
    IncomingTalentCareerPathSupportActionType? actionType,
    IncomingTalentCareerPathSupportActionPriority? priority,
    IncomingTalentCareerPathSupportActionStatus? status,
    DateTime? dueDate,
    String? actionPlan,
    String? successCriteria,
    String? escalationNote,
    IncomingTalentCareerPathReviewDecision? sourceDecision,
    int? reviewedLevel,
    int? targetLevel,
    int? sourceLevelGap,
    DateTime? asOfDate,
  }) {
    return IncomingTalentCareerPathSupportActionDraft(
      reviewId: reviewId ?? this.reviewId,
      careerPathId: careerPathId ?? this.careerPathId,
      portfolioId: portfolioId ?? this.portfolioId,
      roadmapId: roadmapId ?? this.roadmapId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      competencyName: competencyName ?? this.competencyName,
      ownerName: ownerName ?? this.ownerName,
      actionType: actionType ?? this.actionType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      actionPlan: actionPlan ?? this.actionPlan,
      successCriteria: successCriteria ?? this.successCriteria,
      escalationNote: escalationNote ?? this.escalationNote,
      sourceDecision: sourceDecision ?? this.sourceDecision,
      reviewedLevel: reviewedLevel ?? this.reviewedLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      sourceLevelGap: sourceLevelGap ?? this.sourceLevelGap,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
