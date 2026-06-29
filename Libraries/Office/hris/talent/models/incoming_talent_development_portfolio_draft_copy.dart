import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_portfolio.dart';
import 'incoming_talent_development_portfolio_draft.dart';
import 'incoming_talent_development_roadmap.dart';

extension IncomingTalentDevelopmentPortfolioDraftCopy
    on IncomingTalentDevelopmentPortfolioDraft {
  IncomingTalentDevelopmentPortfolioDraft copyWith({
    String? roadmapId,
    String? outcomeReviewId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? portfolioOwnerName,
    String? mentorName,
    String? competencyFocus,
    String? growthGoal,
    String? learningPath,
    String? evidencePlan,
    IncomingTalentDevelopmentPortfolioStage? stage,
    IncomingTalentDevelopmentPortfolioPriority? priority,
    IncomingTalentDevelopmentPortfolioCadence? reviewCadence,
    DateTime? startDate,
    DateTime? nextReviewDate,
    DateTime? targetCompletionDate,
    IncomingTalentDevelopmentRoadmapStatus? sourceRoadmapStatus,
    IncomingTalentActivationRetentionRisk? sourceRetentionRisk,
    int? sourceReadinessScore,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentPortfolioDraft(
      roadmapId: roadmapId ?? this.roadmapId,
      outcomeReviewId: outcomeReviewId ?? this.outcomeReviewId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      portfolioOwnerName: portfolioOwnerName ?? this.portfolioOwnerName,
      mentorName: mentorName ?? this.mentorName,
      competencyFocus: competencyFocus ?? this.competencyFocus,
      growthGoal: growthGoal ?? this.growthGoal,
      learningPath: learningPath ?? this.learningPath,
      evidencePlan: evidencePlan ?? this.evidencePlan,
      stage: stage ?? this.stage,
      priority: priority ?? this.priority,
      reviewCadence: reviewCadence ?? this.reviewCadence,
      startDate: startDate ?? this.startDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      sourceRoadmapStatus: sourceRoadmapStatus ?? this.sourceRoadmapStatus,
      sourceRetentionRisk: sourceRetentionRisk ?? this.sourceRetentionRisk,
      sourceReadinessScore: sourceReadinessScore ?? this.sourceReadinessScore,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
