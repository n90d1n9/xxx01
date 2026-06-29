import 'incoming_talent_career_path.dart';
import 'incoming_talent_career_path_policy.dart';
import 'incoming_talent_development_portfolio.dart';

class IncomingTalentCareerPathDraft {
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String ownerName;
  final String mentorName;
  final String competencyName;
  final int currentLevel;
  final int targetLevel;
  final IncomingTalentCareerPathStatus? status;
  final IncomingTalentCareerPathPriority? priority;
  final String developmentAction;
  final String evidenceRequirement;
  final DateTime? reviewDate;
  final IncomingTalentDevelopmentPortfolioPriority? sourcePortfolioPriority;
  final IncomingTalentDevelopmentPortfolioStage? sourcePortfolioStage;
  final DateTime asOfDate;

  const IncomingTalentCareerPathDraft({
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.targetRole,
    required this.ownerName,
    required this.mentorName,
    required this.competencyName,
    required this.currentLevel,
    required this.targetLevel,
    required this.status,
    required this.priority,
    required this.developmentAction,
    required this.evidenceRequirement,
    required this.reviewDate,
    required this.sourcePortfolioPriority,
    required this.sourcePortfolioStage,
    required this.asOfDate,
  });

  factory IncomingTalentCareerPathDraft.empty(DateTime asOfDate) {
    return IncomingTalentCareerPathDraft(
      portfolioId: '',
      roadmapId: '',
      candidateId: '',
      candidateName: '',
      department: '',
      currentRole: '',
      targetRole: '',
      ownerName: '',
      mentorName: '',
      competencyName: '',
      currentLevel: 1,
      targetLevel: 1,
      status: null,
      priority: null,
      developmentAction: '',
      evidenceRequirement: '',
      reviewDate: null,
      sourcePortfolioPriority: null,
      sourcePortfolioStage: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentCareerPathDraft.fromPortfolio({
    required IncomingTalentDevelopmentPortfolio portfolio,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentCareerPathDefaults.fromPortfolio(portfolio);

    return IncomingTalentCareerPathDraft(
      portfolioId: portfolio.id,
      roadmapId: portfolio.roadmapId,
      candidateId: portfolio.candidateId,
      candidateName: portfolio.candidateName,
      department: portfolio.department,
      currentRole: portfolio.role,
      targetRole: defaults.targetRole,
      ownerName: portfolio.portfolioOwnerName,
      mentorName: portfolio.mentorName,
      competencyName: defaults.competencyName,
      currentLevel: defaults.currentLevel,
      targetLevel: defaults.targetLevel,
      status: defaults.status,
      priority: defaults.priority,
      developmentAction: defaults.developmentAction,
      evidenceRequirement: defaults.evidenceRequirement,
      reviewDate: asOfDate.add(defaults.reviewOffset),
      sourcePortfolioPriority: portfolio.priority,
      sourcePortfolioStage: portfolio.stage,
      asOfDate: asOfDate,
    );
  }
}
