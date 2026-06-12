import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_roadmap.dart';

enum IncomingTalentDevelopmentPortfolioStage {
  designing('Designing'),
  active('Active'),
  watch('Watch'),
  graduated('Graduated');

  final String label;

  const IncomingTalentDevelopmentPortfolioStage(this.label);
}

enum IncomingTalentDevelopmentPortfolioPriority {
  focused('Focused'),
  accelerated('Accelerated'),
  recovery('Recovery');

  final String label;

  const IncomingTalentDevelopmentPortfolioPriority(this.label);
}

enum IncomingTalentDevelopmentPortfolioCadence {
  weekly('Weekly'),
  biweekly('Biweekly'),
  monthly('Monthly'),
  quarterly('Quarterly');

  final String label;

  const IncomingTalentDevelopmentPortfolioCadence(this.label);
}

class IncomingTalentDevelopmentPortfolio {
  final String id;
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
  final IncomingTalentDevelopmentPortfolioStage stage;
  final IncomingTalentDevelopmentPortfolioPriority priority;
  final IncomingTalentDevelopmentPortfolioCadence reviewCadence;
  final DateTime startDate;
  final DateTime nextReviewDate;
  final DateTime targetCompletionDate;
  final IncomingTalentDevelopmentRoadmapStatus sourceRoadmapStatus;
  final IncomingTalentActivationRetentionRisk sourceRetentionRisk;
  final int sourceReadinessScore;
  final DateTime createdAt;

  const IncomingTalentDevelopmentPortfolio({
    required this.id,
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
    required this.createdAt,
  });

  bool get needsAttention {
    return stage == IncomingTalentDevelopmentPortfolioStage.watch ||
        priority == IncomingTalentDevelopmentPortfolioPriority.recovery ||
        sourceRetentionRisk == IncomingTalentActivationRetentionRisk.high ||
        sourceReadinessScore < 70;
  }

  double get readinessRatio => sourceReadinessScore / 100;

  int get durationDays {
    final days = targetCompletionDate.difference(startDate).inDays;
    return days < 0 ? 0 : days;
  }
}
