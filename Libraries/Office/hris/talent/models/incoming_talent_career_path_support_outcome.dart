import 'incoming_talent_career_path_review.dart';
import 'incoming_talent_career_path_support_action.dart';

enum IncomingTalentCareerPathSupportOutcomeDecision {
  resolved('Resolved'),
  improved('Improved'),
  monitor('Monitor'),
  escalate('Escalate');

  final String label;

  const IncomingTalentCareerPathSupportOutcomeDecision(this.label);
}

enum IncomingTalentCareerPathSupportOutcomeResidualRisk {
  low('Low'),
  moderate('Moderate'),
  high('High');

  final String label;

  const IncomingTalentCareerPathSupportOutcomeResidualRisk(this.label);
}

class IncomingTalentCareerPathSupportOutcome {
  final String id;
  final String actionId;
  final String reviewId;
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String targetRole;
  final String competencyName;
  final IncomingTalentCareerPathSupportActionType actionType;
  final IncomingTalentCareerPathSupportActionPriority actionPriority;
  final IncomingTalentCareerPathSupportActionStatus actionStatus;
  final String actionOwnerName;
  final String actionPlan;
  final String successCriteria;
  final IncomingTalentCareerPathReviewDecision sourceDecision;
  final int reviewedLevelBefore;
  final int targetLevel;
  final int sourceLevelGap;
  final String reviewerName;
  final DateTime outcomeDate;
  final IncomingTalentCareerPathSupportOutcomeDecision decision;
  final IncomingTalentCareerPathSupportOutcomeResidualRisk residualRisk;
  final int verifiedLevel;
  final String evidenceSummary;
  final String managerNote;
  final String nextReviewAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentCareerPathSupportOutcome({
    required this.id,
    required this.actionId,
    required this.reviewId,
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.targetRole,
    required this.competencyName,
    required this.actionType,
    required this.actionPriority,
    required this.actionStatus,
    required this.actionOwnerName,
    required this.actionPlan,
    required this.successCriteria,
    required this.sourceDecision,
    required this.reviewedLevelBefore,
    required this.targetLevel,
    required this.sourceLevelGap,
    required this.reviewerName,
    required this.outcomeDate,
    required this.decision,
    required this.residualRisk,
    required this.verifiedLevel,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextReviewAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  int get levelGain {
    final gain = verifiedLevel - reviewedLevelBefore;
    return gain < 0 ? 0 : gain;
  }

  double get progressRatio {
    if (targetLevel <= 0) return 1;
    final ratio = verifiedLevel / targetLevel;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get needsAttention {
    return decision == IncomingTalentCareerPathSupportOutcomeDecision.monitor ||
        decision == IncomingTalentCareerPathSupportOutcomeDecision.escalate ||
        residualRisk ==
            IncomingTalentCareerPathSupportOutcomeResidualRisk.high ||
        verifiedLevel < targetLevel;
  }
}
