import 'incoming_talent_development_program_enrollment.dart';
import 'incoming_talent_development_program_milestone.dart';
import 'incoming_talent_development_program_milestone_draft.dart';

extension IncomingTalentDevelopmentProgramMilestoneDraftCopy
    on IncomingTalentDevelopmentProgramMilestoneDraft {
  IncomingTalentDevelopmentProgramMilestoneDraft copyWith({
    String? enrollmentId,
    String? programId,
    String? programTitle,
    String? candidateId,
    String? candidateName,
    String? role,
    String? department,
    String? reviewerName,
    String? title,
    String? evidenceSummary,
    String? reviewNotes,
    IncomingTalentDevelopmentProgramMilestoneType? type,
    IncomingTalentDevelopmentProgramMilestoneStatus? status,
    int? score,
    DateTime? dueDate,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    IncomingTalentDevelopmentProgramEnrollmentStatus? sourceEnrollmentStatus,
    DateTime? asOfDate,
  }) {
    return IncomingTalentDevelopmentProgramMilestoneDraft(
      enrollmentId: enrollmentId ?? this.enrollmentId,
      programId: programId ?? this.programId,
      programTitle: programTitle ?? this.programTitle,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      role: role ?? this.role,
      department: department ?? this.department,
      reviewerName: reviewerName ?? this.reviewerName,
      title: title ?? this.title,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      type: type ?? this.type,
      status: status ?? this.status,
      score: score ?? this.score,
      dueDate: dueDate ?? this.dueDate,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      sourceEnrollmentStatus:
          sourceEnrollmentStatus ?? this.sourceEnrollmentStatus,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}
