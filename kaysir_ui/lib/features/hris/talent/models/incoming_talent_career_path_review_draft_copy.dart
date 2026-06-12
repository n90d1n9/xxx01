import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_review_draft.dart';

extension IncomingTalentCareerPathReviewDraftCopy
    on IncomingTalentCareerPathReviewDraft {
  IncomingTalentCareerPathReviewDraft copyWith({
    String? careerPathId,
    String? portfolioId,
    String? roadmapId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? targetRole,
    String? competencyName,
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentCareerPathReviewDecision? decision,
    int? previousLevel,
    int? reviewedLevel,
    int? targetLevel,
    String? evidenceNote,
    String? blockerNote,
    String? nextAction,
    DateTime? nextReviewDate,
    IncomingTalentCareerPathStatus? sourceStatus,
    IncomingTalentCareerPathPriority? sourcePriority,
    DateTime? asOfDate,
  }) {
    return IncomingTalentCareerPathReviewDraft(
      careerPathId: careerPathId ?? this.careerPathId,
      portfolioId: portfolioId ?? this.portfolioId,
      roadmapId: roadmapId ?? this.roadmapId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      targetRole: targetRole ?? this.targetRole,
      competencyName: competencyName ?? this.competencyName,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      decision: decision ?? this.decision,
      previousLevel: previousLevel ?? this.previousLevel,
      reviewedLevel: reviewedLevel ?? this.reviewedLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      evidenceNote: evidenceNote ?? this.evidenceNote,
      blockerNote: blockerNote ?? this.blockerNote,
      nextAction: nextAction ?? this.nextAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      sourceStatus: sourceStatus ?? this.sourceStatus,
      sourcePriority: sourcePriority ?? this.sourcePriority,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
