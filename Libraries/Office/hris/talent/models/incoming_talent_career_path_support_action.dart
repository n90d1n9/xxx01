import 'incoming_talent_career_path_review.dart';

enum IncomingTalentCareerPathSupportActionType {
  coaching('Coaching'),
  learningAssignment('Learning assignment'),
  mentorReview('Mentor review'),
  managerUnblocker('Manager unblocker');

  final String label;

  const IncomingTalentCareerPathSupportActionType(this.label);
}

enum IncomingTalentCareerPathSupportActionPriority {
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;

  const IncomingTalentCareerPathSupportActionPriority(this.label);
}

enum IncomingTalentCareerPathSupportActionStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved'),
  cancelled('Cancelled');

  final String label;

  const IncomingTalentCareerPathSupportActionStatus(this.label);
}

class IncomingTalentCareerPathSupportAction {
  final String id;
  final String reviewId;
  final String careerPathId;
  final String portfolioId;
  final String roadmapId;
  final String candidateId;
  final String candidateName;
  final String department;
  final String targetRole;
  final String competencyName;
  final String ownerName;
  final IncomingTalentCareerPathSupportActionType actionType;
  final IncomingTalentCareerPathSupportActionPriority priority;
  final IncomingTalentCareerPathSupportActionStatus status;
  final DateTime dueDate;
  final String actionPlan;
  final String successCriteria;
  final String escalationNote;
  final IncomingTalentCareerPathReviewDecision sourceDecision;
  final int reviewedLevel;
  final int targetLevel;
  final int sourceLevelGap;
  final DateTime createdAt;

  const IncomingTalentCareerPathSupportAction({
    required this.id,
    required this.reviewId,
    required this.careerPathId,
    required this.portfolioId,
    required this.roadmapId,
    required this.candidateId,
    required this.candidateName,
    required this.department,
    required this.targetRole,
    required this.competencyName,
    required this.ownerName,
    required this.actionType,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.actionPlan,
    required this.successCriteria,
    required this.escalationNote,
    required this.sourceDecision,
    required this.reviewedLevel,
    required this.targetLevel,
    required this.sourceLevelGap,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentCareerPathSupportActionStatus.resolved ||
        status == IncomingTalentCareerPathSupportActionStatus.cancelled;
  }

  bool get needsAttention {
    return !isClosed &&
        (priority == IncomingTalentCareerPathSupportActionPriority.high ||
            priority ==
                IncomingTalentCareerPathSupportActionPriority.critical ||
            sourceDecision == IncomingTalentCareerPathReviewDecision.blocked ||
            sourceDecision ==
                IncomingTalentCareerPathReviewDecision.needsSupport ||
            sourceLevelGap >= 2);
  }
}
