import 'incoming_talent_development_portfolio_models.dart';
import 'incoming_talent_development_program_enrollment.dart';
import 'incoming_talent_development_program_enrollment_draft.dart';

extension IncomingTalentDevelopmentProgramEnrollmentDraftCopy
    on IncomingTalentDevelopmentProgramEnrollmentDraft {
  IncomingTalentDevelopmentProgramEnrollmentDraft copyWith({
    String? programId,
    String? programTitle,
    String? portfolioId,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? mentorName,
    String? milestone,
    String? evidencePlan,
    IncomingTalentDevelopmentProgramEnrollmentStatus? status,
    int? progressScore,
    DateTime? enrolledAt,
    DateTime? nextReviewDate,
    DateTime? targetCompletionDate,
    IncomingTalentDevelopmentPortfolioStage? sourcePortfolioStage,
    IncomingTalentDevelopmentPortfolioPriority? sourcePortfolioPriority,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentProgramEnrollmentDraft(
      programId: programId ?? this.programId,
      programTitle: programTitle ?? this.programTitle,
      portfolioId: portfolioId ?? this.portfolioId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      mentorName: mentorName ?? this.mentorName,
      milestone: milestone ?? this.milestone,
      evidencePlan: evidencePlan ?? this.evidencePlan,
      status: status ?? this.status,
      progressScore: progressScore ?? this.progressScore,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      sourcePortfolioStage: sourcePortfolioStage ?? this.sourcePortfolioStage,
      sourcePortfolioPriority:
          sourcePortfolioPriority ?? this.sourcePortfolioPriority,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
