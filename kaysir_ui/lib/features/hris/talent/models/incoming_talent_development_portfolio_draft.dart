import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_portfolio.dart';
import 'incoming_talent_development_portfolio_policy.dart';
import 'incoming_talent_development_roadmap.dart';

class IncomingTalentDevelopmentPortfolioDraft {
  final String roadmapId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String portfolioOwnerName;
  final String mentorName;
  final String competencyFocus;
  final String growthGoal;
  final String learningPath;
  final String evidencePlan;
  final IncomingTalentDevelopmentPortfolioStage? stage;
  final IncomingTalentDevelopmentPortfolioPriority? priority;
  final IncomingTalentDevelopmentPortfolioCadence? reviewCadence;
  final DateTime? startDate;
  final DateTime? nextReviewDate;
  final DateTime? targetCompletionDate;
  final IncomingTalentDevelopmentRoadmapStatus? sourceRoadmapStatus;
  final IncomingTalentActivationRetentionRisk? sourceRetentionRisk;
  final int sourceReadinessScore;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentPortfolioDraft({
    required this.roadmapId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.portfolioOwnerName,
    required this.mentorName,
    required this.competencyFocus,
    required this.growthGoal,
    required this.learningPath,
    required this.evidencePlan,
    required this.stage,
    required this.priority,
    required this.reviewCadence,
    required this.startDate,
    required this.nextReviewDate,
    required this.targetCompletionDate,
    required this.sourceRoadmapStatus,
    required this.sourceRetentionRisk,
    required this.sourceReadinessScore,
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentPortfolioDraft.empty(DateTime asOfDate) {
    return IncomingTalentDevelopmentPortfolioDraft(
      roadmapId: '',
      outcomeReviewId: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      portfolioOwnerName: '',
      mentorName: '',
      competencyFocus: '',
      growthGoal: '',
      learningPath: '',
      evidencePlan: '',
      stage: null,
      priority: null,
      reviewCadence: null,
      startDate: null,
      nextReviewDate: null,
      targetCompletionDate: null,
      sourceRoadmapStatus: null,
      sourceRetentionRisk: null,
      sourceReadinessScore: 0,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentPortfolioDraft.fromRoadmap({
    required IncomingTalentDevelopmentRoadmap roadmap,
    required DateTime asOfDate,
  }) {
    final defaults = IncomingTalentDevelopmentPortfolioDefaults.fromRoadmap(
      roadmap,
    );
    final startDate =
        roadmap.startDate.isBefore(asOfDate) ? asOfDate : roadmap.startDate;

    return IncomingTalentDevelopmentPortfolioDraft(
      roadmapId: roadmap.id,
      outcomeReviewId: roadmap.outcomeReviewId,
      candidateId: roadmap.candidateId,
      candidateName: roadmap.candidateName,
      role: roadmap.role,
      department: roadmap.department,
      portfolioOwnerName: roadmap.ownerName,
      mentorName: roadmap.mentorName,
      competencyFocus: defaults.competencyFocus,
      growthGoal: defaults.growthGoal,
      learningPath: defaults.learningPath,
      evidencePlan: defaults.evidencePlan,
      stage: defaults.stage,
      priority: defaults.priority,
      reviewCadence: defaults.cadence,
      startDate: startDate,
      nextReviewDate: startDate.add(defaults.nextReviewOffset),
      targetCompletionDate: roadmap.targetCompletionDate,
      sourceRoadmapStatus: roadmap.status,
      sourceRetentionRisk: roadmap.retentionRisk,
      sourceReadinessScore: roadmap.readinessScore,
      asOfDate: asOfDate,
    );
  }
}
