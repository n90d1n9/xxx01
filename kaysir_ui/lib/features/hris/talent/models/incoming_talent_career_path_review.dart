import 'incoming_talent_career_path.dart';

enum IncomingTalentCareerPathReviewDecision {
  progressing('Progressing'),
  needsSupport('Needs support'),
  blocked('Blocked'),
  achieved('Achieved');

  final String label;

  const IncomingTalentCareerPathReviewDecision(this.label);
}

class IncomingTalentCareerPathReview {
  final String id;
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String currentRole;
  final String targetRole;
  final String competencyName;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentCareerPathReviewDecision decision;
  final int previousLevel;
  final int reviewedLevel;
  final int targetLevel;
  final String evidenceNote;
  final String blockerNote;
  final String nextAction;
  final DateTime nextReviewDate;
  final IncomingTalentCareerPathStatus sourceStatus;
  final IncomingTalentCareerPathPriority sourcePriority;
  final DateTime createdAt;

  const IncomingTalentCareerPathReview({
    required this.id,
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.currentRole,
    required this.targetRole,
    required this.competencyName,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.previousLevel,
    required this.reviewedLevel,
    required this.targetLevel,
    required this.evidenceNote,
    required this.blockerNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.sourceStatus,
    required this.sourcePriority,
    required this.createdAt,
  });

  int get levelGain {
    final gain = reviewedLevel - previousLevel;
    return gain < 0 ? 0 : gain;
  }

  int get levelGap {
    final gap = targetLevel - reviewedLevel;
    return gap < 0 ? 0 : gap;
  }

  double get progressRatio {
    if (targetLevel <= 0) return 1;
    final ratio = reviewedLevel / targetLevel;
    if (ratio > 1) return 1;
    return ratio;
  }

  bool get needsAttention {
    return decision == IncomingTalentCareerPathReviewDecision.blocked ||
        decision == IncomingTalentCareerPathReviewDecision.needsSupport ||
        sourceStatus == IncomingTalentCareerPathStatus.blocked ||
        sourcePriority == IncomingTalentCareerPathPriority.critical ||
        levelGap >= 2;
  }
}
