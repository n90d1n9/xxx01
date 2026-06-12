import 'incoming_talent_development_portfolio.dart';

enum IncomingTalentCareerPathStatus {
  draft('Draft'),
  active('Active'),
  blocked('Blocked'),
  achieved('Achieved');

  final String label;

  const IncomingTalentCareerPathStatus(this.label);
}

enum IncomingTalentCareerPathPriority {
  standard('Standard'),
  accelerated('Accelerated'),
  critical('Critical');

  final String label;

  const IncomingTalentCareerPathPriority(this.label);
}

class IncomingTalentCareerPath {
  final String id;
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
  final IncomingTalentCareerPathStatus status;
  final IncomingTalentCareerPathPriority priority;
  final String developmentAction;
  final String evidenceRequirement;
  final DateTime reviewDate;
  final IncomingTalentDevelopmentPortfolioPriority sourcePortfolioPriority;
  final IncomingTalentDevelopmentPortfolioStage sourcePortfolioStage;
  final DateTime createdAt;

  const IncomingTalentCareerPath({
    required this.id,
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
    required this.createdAt,
  });

  int get levelGap {
    final gap = targetLevel - currentLevel;
    return gap < 0 ? 0 : gap;
  }

  double get progressRatio {
    if (targetLevel <= 0) return 1;
    final ratio = currentLevel / targetLevel;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get needsAttention {
    return status == IncomingTalentCareerPathStatus.blocked ||
        priority == IncomingTalentCareerPathPriority.critical ||
        levelGap >= 2 ||
        sourcePortfolioStage == IncomingTalentDevelopmentPortfolioStage.watch;
  }
}
