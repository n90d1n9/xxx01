import 'incoming_talent_career_framework_level.dart';
import 'incoming_talent_career_path.dart';
import 'incoming_talent_promotion_readiness.dart';
import 'incoming_talent_promotion_readiness_draft.dart';

extension IncomingTalentPromotionReadinessDraftCopy
    on IncomingTalentPromotionReadinessDraft {
  IncomingTalentPromotionReadinessDraft copyWith({
    String? careerPathId,
    String? frameworkLevelId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? targetRole,
    String? frameworkFamilyName,
    String? frameworkLevelCode,
    IncomingTalentCareerFrameworkLevelScope? frameworkScope,
    IncomingTalentCareerFrameworkReviewCadence? frameworkReviewCadence,
    String? assessorName,
    IncomingTalentPromotionReadinessRating? rating,
    IncomingTalentPromotionReadinessStatus? status,
    String? competencyName,
    String? evidenceSummary,
    String? gapSummary,
    String? panelRecommendation,
    DateTime? reviewDate,
    DateTime? nextReviewDate,
    IncomingTalentCareerPathStatus? sourceCareerPathStatus,
    IncomingTalentCareerPathPriority? sourceCareerPathPriority,
    DateTime? asOfDate,
  }) {
    return IncomingTalentPromotionReadinessDraft(
      careerPathId: careerPathId ?? this.careerPathId,
      frameworkLevelId: frameworkLevelId ?? this.frameworkLevelId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      targetRole: targetRole ?? this.targetRole,
      frameworkFamilyName: frameworkFamilyName ?? this.frameworkFamilyName,
      frameworkLevelCode: frameworkLevelCode ?? this.frameworkLevelCode,
      frameworkScope: frameworkScope ?? this.frameworkScope,
      frameworkReviewCadence:
          frameworkReviewCadence ?? this.frameworkReviewCadence,
      assessorName: assessorName ?? this.assessorName,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      competencyName: competencyName ?? this.competencyName,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      gapSummary: gapSummary ?? this.gapSummary,
      panelRecommendation: panelRecommendation ?? this.panelRecommendation,
      reviewDate: reviewDate ?? this.reviewDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      sourceCareerPathStatus:
          sourceCareerPathStatus ?? this.sourceCareerPathStatus,
      sourceCareerPathPriority:
          sourceCareerPathPriority ?? this.sourceCareerPathPriority,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
