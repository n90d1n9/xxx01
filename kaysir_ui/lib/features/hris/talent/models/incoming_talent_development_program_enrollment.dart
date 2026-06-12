import 'incoming_talent_development_portfolio_models.dart';

enum IncomingTalentDevelopmentProgramEnrollmentStatus {
  planned('Planned'),
  active('Active'),
  watch('Watch'),
  completed('Completed'),
  withdrawn('Withdrawn');

  final String label;

  const IncomingTalentDevelopmentProgramEnrollmentStatus(this.label);
}

class IncomingTalentDevelopmentProgramEnrollment {
  final String id;
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
  final IncomingTalentDevelopmentProgramEnrollmentStatus status;
  final int progressScore;
  final DateTime enrolledAt;
  final DateTime nextReviewDate;
  final DateTime targetCompletionDate;
  final IncomingTalentDevelopmentPortfolioStage sourcePortfolioStage;
  final IncomingTalentDevelopmentPortfolioPriority sourcePortfolioPriority;
  final DateTime createdAt;

  const IncomingTalentDevelopmentProgramEnrollment({
    required this.id,
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
    required this.createdAt,
  });

  bool get isClosed {
    return status ==
            IncomingTalentDevelopmentProgramEnrollmentStatus.completed ||
        status == IncomingTalentDevelopmentProgramEnrollmentStatus.withdrawn;
  }

  bool get needsAttention {
    return status == IncomingTalentDevelopmentProgramEnrollmentStatus.watch ||
        progressScore < 60 ||
        sourcePortfolioStage == IncomingTalentDevelopmentPortfolioStage.watch ||
        sourcePortfolioPriority ==
            IncomingTalentDevelopmentPortfolioPriority.recovery;
  }

  double get progressRatio => progressScore / 100;
}
