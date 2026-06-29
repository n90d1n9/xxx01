import 'incoming_talent_development_portfolio_models.dart';
import 'incoming_talent_development_program.dart';
import 'incoming_talent_development_program_enrollment.dart';

class IncomingTalentDevelopmentProgramEnrollmentDraft {
  final String programId;
  final String programTitle;
  final String portfolioId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String mentorName;
  final String milestone;
  final String evidencePlan;
  final IncomingTalentDevelopmentProgramEnrollmentStatus? status;
  final int progressScore;
  final DateTime? enrolledAt;
  final DateTime? nextReviewDate;
  final DateTime? targetCompletionDate;
  final IncomingTalentDevelopmentPortfolioStage? sourcePortfolioStage;
  final IncomingTalentDevelopmentPortfolioPriority? sourcePortfolioPriority;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentProgramEnrollmentDraft({
    required this.programId,
    required this.programTitle,
    required this.portfolioId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.mentorName,
    required this.milestone,
    required this.evidencePlan,
    required this.status,
    required this.progressScore,
    required this.enrolledAt,
    required this.nextReviewDate,
    required this.targetCompletionDate,
    required this.sourcePortfolioStage,
    required this.sourcePortfolioPriority,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentProgramEnrollmentDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentProgramEnrollmentDraft(
      programId: '',
      programTitle: '',
      portfolioId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      mentorName: '',
      milestone: '',
      evidencePlan: '',
      status: null,
      progressScore: 0,
      enrolledAt: asOfDate,
      nextReviewDate: asOfDate.add(const Duration(days: 14)),
      targetCompletionDate: asOfDate.add(const Duration(days: 60)),
      sourcePortfolioStage: null,
      sourcePortfolioPriority: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentProgramEnrollmentDraft.fromProgramPortfolio({
    required IncomingTalentDevelopmentProgram program,
    required IncomingTalentDevelopmentPortfolio portfolio,
    required DateTime asOfDate,
  }) {
    final status =
        portfolio.needsAttention
            ? IncomingTalentDevelopmentProgramEnrollmentStatus.watch
            : IncomingTalentDevelopmentProgramEnrollmentStatus.active;
    final reviewOffset =
        program.intensity ==
                    IncomingTalentDevelopmentProgramIntensity.accelerated ||
                portfolio.needsAttention
            ? const Duration(days: 7)
            : const Duration(days: 14);
    final targetCompletionDate =
        program.endDate.isBefore(portfolio.targetCompletionDate)
            ? program.endDate
            : portfolio.targetCompletionDate;

    return IncomingTalentDevelopmentProgramEnrollmentDraft(
      programId: program.id,
      programTitle: program.title,
      portfolioId: portfolio.id,
      candidateId: portfolio.candidateId,
      candidateName: portfolio.candidateName,
      role: portfolio.role,
      department: portfolio.department,
      mentorName: portfolio.mentorName,
      milestone:
          'Complete ${program.skillFocus} milestone for ${portfolio.role}.',
      evidencePlan:
          'Submit ${program.expectedOutcome} evidence with ${portfolio.portfolioOwnerName} sign-off.',
      status: status,
      progressScore: portfolio.sourceReadinessScore,
      enrolledAt: asOfDate,
      nextReviewDate: asOfDate.add(reviewOffset),
      targetCompletionDate: targetCompletionDate,
      sourcePortfolioStage: portfolio.stage,
      sourcePortfolioPriority: portfolio.priority,
      asOfDate: asOfDate,
    );
  }
}
