import 'incoming_talent_development_program_enrollment.dart';

enum IncomingTalentDevelopmentProgramMilestoneStatus {
  planned('Planned'),
  submitted('Submitted'),
  accepted('Accepted'),
  needsRevision('Needs revision');

  final String label;

  const IncomingTalentDevelopmentProgramMilestoneStatus(this.label);
}

enum IncomingTalentDevelopmentProgramMilestoneType {
  skillEvidence('Skill evidence'),
  managerReview('Manager review'),
  capstone('Capstone'),
  placementReadiness('Placement readiness');

  final String label;

  const IncomingTalentDevelopmentProgramMilestoneType(this.label);
}

class IncomingTalentDevelopmentProgramMilestone {
  final String id;
  final String enrollmentId;
  final String programId;
  final String programTitle;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final String title;
  final String evidenceSummary;
  final String reviewNotes;
  final IncomingTalentDevelopmentProgramMilestoneType type;
  final IncomingTalentDevelopmentProgramMilestoneStatus status;
  final int score;
  final DateTime dueDate;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final IncomingTalentDevelopmentProgramEnrollmentStatus sourceEnrollmentStatus;
  final DateTime createdAt;

  const IncomingTalentDevelopmentProgramMilestone({
    required this.id,
    required this.enrollmentId,
    required this.programId,
    required this.programTitle,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.title,
    required this.evidenceSummary,
    required this.reviewNotes,
    required this.type,
    required this.status,
    required this.score,
    required this.dueDate,
    required this.submittedAt,
    required this.reviewedAt,
    required this.sourceEnrollmentStatus,
    required this.createdAt,
  });

  bool get isClosed {
    return status == IncomingTalentDevelopmentProgramMilestoneStatus.accepted;
  }

  bool get needsAttention {
    return status ==
            IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision ||
        score < 70 ||
        sourceEnrollmentStatus ==
            IncomingTalentDevelopmentProgramEnrollmentStatus.watch;
  }

  double get scoreRatio => score / 100;
}
