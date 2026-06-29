import 'incoming_talent_development_program_enrollment.dart';
import 'incoming_talent_development_program_milestone.dart';

class IncomingTalentDevelopmentProgramMilestoneDraft {
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
  final IncomingTalentDevelopmentProgramMilestoneType? type;
  final IncomingTalentDevelopmentProgramMilestoneStatus? status;
  final int score;
  final DateTime? dueDate;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final IncomingTalentDevelopmentProgramEnrollmentStatus?
  sourceEnrollmentStatus;
  final DateTime asOfDate;

  const IncomingTalentDevelopmentProgramMilestoneDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentDevelopmentProgramMilestoneDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentDevelopmentProgramMilestoneDraft(
      enrollmentId: '',
      programId: '',
      programTitle: '',
      candidateId: '',
      candidateName: '',
      role: '',
      department: '',
      reviewerName: '',
      title: '',
      evidenceSummary: '',
      reviewNotes: '',
      type: null,
      status: null,
      score: 0,
      dueDate: asOfDate.add(const Duration(days: 14)),
      submittedAt: null,
      reviewedAt: null,
      sourceEnrollmentStatus: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentDevelopmentProgramMilestoneDraft.fromEnrollment({
    required IncomingTalentDevelopmentProgramEnrollment enrollment,
    required DateTime asOfDate,
  }) {
    final dueDate =
        enrollment.nextReviewDate.isBefore(asOfDate)
            ? asOfDate.add(const Duration(days: 7))
            : enrollment.nextReviewDate;
    final status =
        enrollment.needsAttention
            ? IncomingTalentDevelopmentProgramMilestoneStatus.needsRevision
            : IncomingTalentDevelopmentProgramMilestoneStatus.submitted;

    return IncomingTalentDevelopmentProgramMilestoneDraft(
      enrollmentId: enrollment.id,
      programId: enrollment.programId,
      programTitle: enrollment.programTitle,
      candidateId: enrollment.candidateId,
      candidateName: enrollment.candidateName,
      role: enrollment.role,
      department: enrollment.department,
      reviewerName: enrollment.mentorName,
      title: enrollment.milestone,
      evidenceSummary: enrollment.evidencePlan,
      reviewNotes:
          enrollment.needsAttention
              ? 'Review blockers and define corrective evidence before acceptance.'
              : 'Validate milestone evidence and readiness lift with mentor sign-off.',
      type: IncomingTalentDevelopmentProgramMilestoneType.skillEvidence,
      status: status,
      score: enrollment.progressScore,
      dueDate: dueDate,
      submittedAt:
          status == IncomingTalentDevelopmentProgramMilestoneStatus.submitted
              ? asOfDate
              : null,
      reviewedAt: null,
      sourceEnrollmentStatus: enrollment.status,
      asOfDate: asOfDate,
    );
  }
}
