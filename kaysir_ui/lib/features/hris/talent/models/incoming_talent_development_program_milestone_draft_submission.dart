import 'incoming_talent_development_program_milestone.dart';
import 'incoming_talent_development_program_milestone_draft.dart';
import 'incoming_talent_development_program_milestone_policy.dart';

extension IncomingTalentDevelopmentProgramMilestoneDraftSubmission
    on IncomingTalentDevelopmentProgramMilestoneDraft {
  double get completionRatio {
    final completed =
        [
          enrollmentId.trim().isNotEmpty,
          reviewerName.trim().isNotEmpty,
          title.trim().length >= 12,
          evidenceSummary.trim().length >= 12,
          reviewNotes.trim().length >= 12,
          type != null,
          status != null,
          score >= 0 && score <= 100,
          dueDate != null,
          sourceEnrollmentStatus != null,
        ].where((item) => item).length;

    return completed / 10;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentProgramMilestoneRequired(
            enrollmentId,
            'a program enrollment',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneRequired(
            reviewerName,
            'a reviewer',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneLongText(title, 'title')
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneLongText(
            evidenceSummary,
            'evidence summary',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneLongText(
            reviewNotes,
            'review notes',
          )
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneType(type) case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneStatus(status)
          case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneScore(score) case final error?)
        error,
      if (validateIncomingTalentProgramMilestoneDueDate(dueDate, asOfDate)
          case final error?)
        error,
      if (sourceEnrollmentStatus == null) 'Select source enrollment status',
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentDevelopmentProgramMilestone toMilestone({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentDevelopmentProgramMilestone(
      id: id,
      enrollmentId: enrollmentId,
      programId: programId,
      programTitle: programTitle.trim(),
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      role: role.trim(),
      department: department.trim(),
      reviewerName: reviewerName.trim(),
      title: title.trim(),
      evidenceSummary: evidenceSummary.trim(),
      reviewNotes: reviewNotes.trim(),
      type: type!,
      status: status!,
      score: score,
      dueDate: dueDate!,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt,
      sourceEnrollmentStatus: sourceEnrollmentStatus!,
      createdAt: createdAt,
    );
  }
}
