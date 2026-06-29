import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_draft.dart';
import 'incoming_talent_development_portfolio.dart';

extension IncomingTalentCareerPathDraftCopy on IncomingTalentCareerPathDraft {
  IncomingTalentCareerPathDraft copyWith({
    String? portfolioId,
    String? roadmapId,
    String? candidateId,
    String? candidateName,
    String? department,
    String? currentRole,
    String? targetRole,
    String? ownerName,
    String? mentorName,
    String? competencyName,
    int? currentLevel,
    int? targetLevel,
    IncomingTalentCareerPathStatus? status,
    IncomingTalentCareerPathPriority? priority,
    String? developmentAction,
    String? evidenceRequirement,
    DateTime? reviewDate,
    IncomingTalentDevelopmentPortfolioPriority? sourcePortfolioPriority,
    IncomingTalentDevelopmentPortfolioStage? sourcePortfolioStage,
    DateTime? asOfDate,
  }) {
    return IncomingTalentCareerPathDraft(
      portfolioId: portfolioId ?? this.portfolioId,
      roadmapId: roadmapId ?? this.roadmapId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      department: department ?? this.department,
      currentRole: currentRole ?? this.currentRole,
      targetRole: targetRole ?? this.targetRole,
      ownerName: ownerName ?? this.ownerName,
      mentorName: mentorName ?? this.mentorName,
      competencyName: competencyName ?? this.competencyName,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel ?? this.targetLevel,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      developmentAction: developmentAction ?? this.developmentAction,
      evidenceRequirement: evidenceRequirement ?? this.evidenceRequirement,
      reviewDate: reviewDate ?? this.reviewDate,
      sourcePortfolioPriority:
          sourcePortfolioPriority ?? this.sourcePortfolioPriority,
      sourcePortfolioStage: sourcePortfolioStage ?? this.sourcePortfolioStage,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
